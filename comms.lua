------------------------------------------------------------
-- DressUp by Sonaza
-- All rights reserved
-- http://sonaza.com
------------------------------------------------------------

local ADDON_NAME, Addon = ...;
local ADDON_CHANNEL_PREFIX = ADDON_NAME;

local ADDON_MESSAGE_SENT = {};
local ADDON_MESSAGE_CALLBACKS = {};

local MESSAGE_TYPES = {
	QUERY_VERSION		= 0x001,
	SEND_PREVIEW_ITEMS	= 0x002,
};

local AceSerializer = LibStub("AceSerializer-3.0");

PENDING_PREVIEWS = {};

function Addon:PreviewReceivedListID(previewID)
	if(not PENDING_PREVIEWS[previewID]) then return end
	
	local preview = PENDING_PREVIEWS[previewID];
	Addon:LoadItemList(preview.items);
end

StaticPopupDialogs["DRESSUP_VIEW_WHISPERED_PREVIEW"] = {
	text = "%s sent you their previewed items. Click accept if you wish to preview them.",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		-- Get newest preview
		Addon:PreviewReceivedListID(#PENDING_PREVIEWS);
	end,
	timeout = 0,
	exclusive = 0,
	hideOnEscape = 1,
};

local function CapitalizeWord(word)
	if(strlen(word) <= 1) then return string.upper(word) end
	return string.upper(word:sub(1, 1)) .. string.lower(word:sub(2));
end

local function Capitalize(str)
	if(strlen(str) <= 1) then return string.upper(str) end
	
	str = string.gsub(str, "-", " ");
	
	local resultwords = {};
	local words = { strsplit(" ", str) };
	for _, word in ipairs(words) do
		tinsert(resultwords, CapitalizeWord(word));
	end
	
	if(#resultwords == 1) then
		return resultwords[1];
	end
	
	local result = table.concat(resultwords, "-", 1, 2);
	
	if(#resultwords >= 3) then
		result = result .. " " .. table.concat(resultwords, " ", 3);
	end
	
	return result;
end

StaticPopupDialogs["DRESSUP_ASK_WHISPER_TARGET"] = {
	text = "Give outfit preview recipient's name (with realm if needed):",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self, data)
		local recipient = Capitalize(strtrim(self.editBox:GetText()));
		if(strlen(recipient) > 0) then
			Addon:SendPreviewedItems(recipient);
		end
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		local recipient = Capitalize(strtrim(parent.editBox:GetText()));
		if(strlen(recipient) > 0) then
			Addon:SendPreviewedItems(recipient);
		end
		parent:Hide();
	end,
	OnShow = function(self, data)
		self.editBox:SetFocus();
	end,
	OnHide = function(self, data)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 0,
	hideOnEscape = 1,
};

function Addon:InitializeComms()
	Addon:RegisterEvent("CHAT_MSG_ADDON");
	Addon:RegisterEvent("CHAT_MSG_SYSTEM");
	RegisterAddonMessagePrefix("DressUp");
	
	Addon:RegisterMessageCallback(MESSAGE_TYPES.QUERY_VERSION, function(payload, sender)
		Addon:ReplyToMessage(payload, {
			version = GetAddOnMetadata("DressUp", "Version"),
		});
	end);
	
	Addon:RegisterMessageCallback(MESSAGE_TYPES.SEND_PREVIEW_ITEMS, function(payload, sender)
		tinsert(PENDING_PREVIEWS, {
			from = sender,
			items = payload.items,
		});
		local previewID = #PENDING_PREVIEWS;
		
		Addon:AddMessage("Received preview from %s: |Hdressup:%d|h|cffffc809[View]|r|h.", sender, previewID);
		
		if(Addon.db.global.PromptForPreviews and not InCombatLockdown()) then
			StaticPopup_Show("DRESSUP_VIEW_WHISPERED_PREVIEW", sender);
		end
	end);
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(self, ...)
		return Addon:FilterWhispers(...);
	end);
end

local ShouldHideWhisper = false;
function Addon:FilterWhispers(event, message, target)
	if(ShouldHideWhisper) then
		-- if(strfind(string.lower(target), string.lower(ShouldHideWhisper)) ~= nil) then
		-- 	ShouldHideWhisper = false;
			return true;
		-- end
	end
	return false;
end

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(self, link, text, button)
	if(link and link:sub(0, 7) ~= "dressup") then
		return;
	end
	
	if(IsShiftKeyDown()) then
		return;
	end
	
	local link, previewID = strsplit(":", link);
	previewID = tonumber(previewID);
	if(previewID) then
		Addon:PreviewReceivedListID(previewID);
	end
end);

local OriginalSetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
	if(link and link:sub(0, 7) == "dressup") then
		return;
	end
	return OriginalSetHyperlink(self, link, ...);
end

local OriginalHandleModifiedItemClick = HandleModifiedItemClick
function HandleModifiedItemClick(link, ...)
	if(link and link:find("|Hdressup")) then
		return;
	end
	return OriginalHandleModifiedItemClick(link, ...);
end

local ERR_CHAT_PLAYER_NOT_FOUND_PATTERN = string.gsub(ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(%%a+)");
function Addon:CHAT_MSG_SYSTEM(event, msg)
	local playerName = string.match(msg, ERR_CHAT_PLAYER_NOT_FOUND_PATTERN);
	if(playerName) then
		for id, data in pairs(ADDON_MESSAGE_SENT) do
			if(string.lower(data.target) == string.lower(playerName)) then
				ADDON_MESSAGE_SENT[id] = nil;
				return;
			end
		end
	end
end

function Addon:GetUniqueMessageID()
	local messageID;
	repeat
		messageID = random(100, 999);
	until(ADDON_MESSAGE_SENT[messageID] == nil);
	return messageID;
end

function Addon:ReplyToMessage(oldpayload, newpayload, callbacks)
	newpayload.replyID = oldpayload.messageID;
	Addon:SendAddonMessage(oldpayload.sender, newpayload, callbacks);
end

function Addon:SendAddonMessage(target, payload, callbacks)
	if(not target or not payload) then return end
	
	local messageID = Addon:GetUniqueMessageID();
	payload.messageID = messageID;
	
	local serialized = AceSerializer:Serialize(payload);
	if(strlen(serialized) > 250) then
		error(("Serialized string length exceeds message limit."), 2)
	end
	
	if(callbacks) then
		ADDON_MESSAGE_SENT[messageID] = {
			tag = payload.tag,
			payload = serialized,
			target = target,
			timestamp = GetTime(),
			callbacks = {
				onReply = callbacks.onReply,
				onTimeout = callbacks.onTimeout,
			},
		};
	end
	
	SendAddonMessage(ADDON_CHANNEL_PREFIX, serialized, "WHISPER", target);
	
	C_Timer.After(1.0, function()
		-- If message still exists on the table then it time outed
		local data = ADDON_MESSAGE_SENT[messageID];
		if(data) then
			if(data.callbacks.onTimeout) then
				pcall(data.callbacks.onTimeout, target);
			end
			ADDON_MESSAGE_SENT[messageID] = nil;
		end
	end);
	
	return messageID;
end

function DressUpFrameWhisperButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:AddLine("Send Outfit");
	
	if(self:GetID() == 1) then
		GameTooltip:AddLine("Send currently previewed items to another player.", 1, 1, 1, true);
	elseif(self:GetID() == 2) then
		GameTooltip:AddLine("Send current transmog to another player.", 1, 1, 1, true);
	end
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("Note: target recipient must have DressUp for this feature to work.", 1, 1, 1, true);
	GameTooltip:Show();
end

function DressUpFrameWhisperButton_OnClick(self)
	if(not DressUpFrame:IsVisible()) then
		DressUpFrame_Show();
	end
	
	if(self:GetID() == 1) then
		DressUpPreviewWhisperButtonAlertCloseButton_OnClick();
	end
	
	StaticPopup_Show("DRESSUP_ASK_WHISPER_TARGET");
	GameTooltip:Hide();
end

function Addon:SendPreviewedItems(target)
	-- Check for target version first
	Addon:PokeForVersion(target,
	{
		onReply = function(payload, sender)
			Addon:DoSendPreviewedItems(target);
			Addon:AddMessage("Sent currently previewed items to %s.", target);
		end,
		onTimeout = function()
			ShouldHideWhisper = true;
			
			local msg = ("%s wishes to whisper their previewed items to you but you do not have DressUp or it is outdated. "..
				         "Get the addon from http://wow.curseforge.com/addons/dressup/"):format(UnitName("player"));
			SendChatMessage(msg, "WHISPER", nil, target);
			
			Addon:AddMessage("%s doesn't have DressUp or it is outdated. They were notified of it.", target);
		end,
	});
end

function Addon:PokeForVersion(target, callbacks)
	Addon:SendAddonMessage(target, {
		tag = MESSAGE_TYPES.QUERY_VERSION
	}, callbacks);
end

function Addon:DoSendPreviewedItems(target)
	local itemlist = Addon:GetPreviewedItemsList();
	Addon:SendAddonMessage(target, {
		tag = MESSAGE_TYPES.SEND_PREVIEW_ITEMS,
		items = itemlist,
	});
end

function Addon:CHAT_MSG_ADDON(event, prefix, message, msgtype, sender)
	if(prefix ~= ADDON_CHANNEL_PREFIX) then return end
	
	local deserializeSuccess, payload = AceSerializer:Deserialize(message);
	if(not deserializeSuccess) then
		return;
	end
	
	payload.sender = sender;
	
	if(payload.replyID) then
		-- Execute reply callback
		local data = ADDON_MESSAGE_SENT[payload.replyID];
		if(data.callbacks.onReply) then
			pcall(data.callbacks.onReply, payload, sender);
		end
		ADDON_MESSAGE_SENT[payload.replyID] = nil;
	end
	
	if(payload.tag) then
		local callback = ADDON_MESSAGE_CALLBACKS[payload.tag];
		if(callback) then
			pcall(callback, payload, sender);
		end
	end
end

function Addon:RegisterMessageCallback(tag, func)
	if(not tag) then 
		error("DressUp:RegisterMessageCallback(tag, func): Invalid tag.", 2)
	end
	
	if(ADDON_MESSAGE_CALLBACKS[tag]) then 
		error(("DressUp:RegisterMessageCallback(tag, func): %s is already registered."):format(tag), 2)
	end
	
	if(not func) then 
		error("DressUp:RegisterMessageCallback(tag, func): Missing callback function.", 2)
	end
	
	ADDON_MESSAGE_CALLBACKS[tag] = func;
end
