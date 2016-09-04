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

local PENDING_PREVIEWS = {};

StaticPopupDialogs["DRESSUP_VIEW_WHISPERED_PREVIEW"] = {
	text = "%s sent you their previewed items. Click accept if you wish to preview them.",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		-- Get newest preview
		local preview = PENDING_PREVIEWS[#PENDING_PREVIEWS];
		Addon:LoadItemList(preview.items);
	end,
	timeout = 0,
	exclusive = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["DRESSUP_ASK_WHISPER_TARGET"] = {
	text = "Give outfit preview recipient's name (with realm if needed):",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self, data)
		local recipient = strtrim(self.editBox:GetText());
		if(strlen(recipient) > 0) then
			Addon:SendPreviewedItems(recipient);
		end
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		local recipient = strtrim(parent.editBox:GetText());
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
		Addon:SendAddonMessage(sender, {
			replyID = payload.messageID,
			version = GetAddOnMetadata("DressUp", "Version"),
		});
	end);
	
	Addon:RegisterMessageCallback(MESSAGE_TYPES.SEND_PREVIEW_ITEMS, function(payload, sender)
		tinsert(PENDING_PREVIEWS, {
			from = sender,
			items = payload.items,
		});
		
		StaticPopup_Show("DRESSUP_VIEW_WHISPERED_PREVIEW", sender);
	end);
	
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(self, ...)
		return Addon:FilterWhispers(...);
	end);
end

local ShouldHideWhisperTo = false;
function Addon:FilterWhispers(event, message, target)
	if(ShouldHideWhisperTo) then
		if(strfind(target, ShouldHideWhisperTo) ~= nil) then
			ShouldHideWhisperTo = false;
			return true;
		end
	end
	return false;
end

local ERR_CHAT_PLAYER_NOT_FOUND_PATTERN = string.gsub(ERR_CHAT_PLAYER_NOT_FOUND_S, "%%s", "(%%a+)");
function Addon:CHAT_MSG_SYSTEM(event, msg)
	local playerName = string.match(msg, ERR_CHAT_PLAYER_NOT_FOUND_PATTERN);
	if(playerName) then
		for id, data in pairs(ADDON_MESSAGE_SENT) do
			if(data.target == playerName) then
				ADDON_MESSAGE_SENT[id] = nil;
				return;
			end
		end
	end
end

function Addon:GetUniqueMessageID()
	local messageID;
	repeat
		messageID = random(1, 20000);
	until(ADDON_MESSAGE_SENT[messageID] == nil);
	return messageID;
end

function Addon:SendAddonMessage(target, payload, callbacks)
	if(not target or not payload) then return end
	
	local messageID = Addon:GetUniqueMessageID();
	payload.messageID = messageID;
	
	local serialized = AceSerializer:Serialize(payload);
	
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
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine("Send Outfit")
	GameTooltip:AddLine("Send currently previewed items to another player.", 1, 1, 1, true);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("Note: target recipient must have DressUp for this feature to work.", 1, 1, 1, true);
	GameTooltip:Show();
end

function DressUpFrameWhisperButton_OnClick(self)
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
			ShouldHideWhisperTo = target;
			
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
		-- error("Deserialize failed", 2);
		return;
	end
	
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
		error("Addon:RegisterMessageCallback(tag, func): Invalid tag.", 2)
	end
	
	if(ADDON_MESSAGE_CALLBACKS[tag]) then 
		error(("Addon:RegisterMessageCallback(tag, func): %s is already registered."):format(tag), 2)
	end
	
	if(not func) then 
		error("Addon:RegisterMessageCallback(tag, func): Missing callback function.", 2)
	end
	
	ADDON_MESSAGE_CALLBACKS[tag] = func;
end
