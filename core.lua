------------------------------------------------------------
-- DressUp by Sonaza (https://sonaza.com)
-- Licensed under MIT License
-- See attached license text in file LICENSE
------------------------------------------------------------

local ADDON_NAME = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), ADDON_NAME, "AceEvent-3.0", "AceHook-3.0");
_G[ADDON_NAME] = Addon;

local AceDB = LibStub("AceDB-3.0");

local _;

-- A bunch of evil trickery, sorry!
BlizzDressUpFrame               = DressUpFrame;
BlizzDressUpModel               = DressUpModel;
BlizzDressUpFrameResetButton    = DressUpFrameResetButton;
BlizzDressUpFrameCancelButton   = DressUpFrameCancelButton;
BlizzDressUpFrameOutfitDropDown = DressUpFrameOutfitDropDown;

DressUpFrame                    = CustomDressUpFrame;
DressUpModel                    = CustomDressUpModel;
DressUpFrameResetButton         = CustomDressUpFrameResetButton;
DressUpFrameCancelButton        = CustomDressUpFrameCancelButton;
DressUpFrameOutfitDropDown      = CustomDressUpFrameOutfitDropDown;

DRESSUP_WHISPER_TUTORIAL_TEXT = "Click here to whisper your previewed outfit to other players.|n|nNote: For the feature to work they must also have an up to date version of DressUp.";

tinsert(UISpecialFrames, "CustomDressUpFrame");
UIPanelWindows["CustomDressUpFrame"] = { area = "left", pushable = 2 };

local paperDollSlots = {
	["CharacterHeadSlot"]			= 1,
	["CharacterNeckSlot"]			= 2,
	["CharacterShoulderSlot"]		= 3,
	["CharacterBackSlot"]			= 15,
	["CharacterChestSlot"]			= 5,
	["CharacterWristSlot"]			= 9,
	["CharacterHandsSlot"]			= 10,
	["CharacterWaistSlot"]			= 6,
	["CharacterLegsSlot"]			= 7,
	["CharacterFeetSlot"]			= 8,
	["CharacterFinger0Slot"]		= 11,
	["CharacterFinger1Slot"]		= 12,
	["CharacterTrinket0Slot"]		= 13,
	["CharacterTrinket1Slot"]		= 14,
	["CharacterMainHandSlot"]		= 16,
	["CharacterSecondaryHandSlot"]	= 17,
	["CharacterRangedSlot"]			= 18,
};

local INVENTORY_SLOTS = {
	["INVTYPE_HEAD"] = 1,
	["INVTYPE_NECK"] = nil,
	["INVTYPE_SHOULDER"] = 3,
	["INVTYPE_BODY"] = 4,
	["INVTYPE_CHEST"] = 5,
	["INVTYPE_ROBE"] = 5,
	["INVTYPE_WAIST"] = 6,
	["INVTYPE_LEGS"] = 7,
	["INVTYPE_FEET"] = 8,
	["INVTYPE_WRIST"] = 9,
	["INVTYPE_HAND"] = 10,
	["INVTYPE_FINGER"] = nil,
	["INVTYPE_TRINKET"] = nil,
	["INVTYPE_CLOAK"] = 15,
	["INVTYPE_WEAPON"] = 16,-- offhand 17,
	["INVTYPE_SHIELD"] = 17,
	["INVTYPE_2HWEAPON"] = 16,
	["INVTYPE_WEAPONMAINHAND"] = 16,
	["INVTYPE_WEAPONOFFHAND"] = 17,
	["INVTYPE_HOLDABLE"] = 17,
	["INVTYPE_RANGED"] = 18,
	["INVTYPE_THROWN"] = 18,
	["INVTYPE_RANGEDRIGHT"] = 18,
	["INVTYPE_RELIC"] = 18,
	["INVTYPE_TABARD"] = 19,
};

local INVENTORY_SLOT_NAMES = {
	[1]  = "HEADSLOT",
	[3]  = "SHOULDERSLOT",
	[4]  = "SHIRTSLOT",
	[5]  = "CHESTSLOT",
	[6]  = "WAISTSLOT",
	[7]  = "LEGSSLOT",
	[8]  = "FEETSLOT",
	[9]  = "WRISTSLOT",
	[10] = "HANDSSLOT",
	[15] = "BACKSLOT",
	[16] = "MAINHANDSLOT",
	[17] = "SECONDARYHANDSLOT",
	[18] = "RANGEDSLOT",
	[19] = "TABARDSLOT",
	
	["HEADSLOT"]          = 1,
	["SHOULDERSLOT"]      = 3,
	["SHIRTSLOT"]         = 4,
	["CHESTSLOT"]         = 5,
	["WAISTSLOT"]         = 6,
	["LEGSSLOT"]          = 7,
	["FEETSLOT"]          = 8,
	["WRISTSLOT"]         = 9,
	["HANDSSLOT"]         = 10,
	["BACKSLOT"]          = 15,
	["MAINHANDSLOT"]      = 16,
	["SECONDARYHANDSLOT"] = 17,
	["RANGEDSLOT"]        = 18,
	["TABARDSLOT"]        = 19,
};

local VISIBLE_SLOTS = {
	1, 3, 4, 5, 6, 7, 8, 9, 10, 15, 16, 17, 19,
};

-- 1 - Human
-- 2 - Orc
-- 3 - Dwarf
-- 4 - Nightelf
-- 5 - Undead
-- 6 - Tauren
-- 7 - Gnome
-- 8 - Troll

local RACES = {
	"Human", "Dwarf", "Night Elf", "Gnome",
	"Orc", "Undead", "Tauren", "Troll",
};

local RACE_IDS = {
	1, 3, 4, 7,
	2, 5, 6, 8,
};
local NUM_RACE_IDS = 8;
local NUM_ALLIANCE_RACES = 4;
local NUM_HORDE_RACES = 4;
	
local CLASS_BACKGROUNDS = {
	"Interface\\DRESSUPFRAME\\DressingRoomPaladin",
	"Interface\\DRESSUPFRAME\\DressingRoomWarrior",
	"Interface\\DRESSUPFRAME\\DressingRoomShaman",
	"Interface\\DRESSUPFRAME\\DressingRoomRogue",
	"Interface\\DRESSUPFRAME\\DressingRoomWarlock",
	"Interface\\DRESSUPFRAME\\DressingRoomPriest",
	"Interface\\DRESSUPFRAME\\DressingRoomMage",
	"Interface\\DRESSUPFRAME\\DressingRoomHunter",
	"Interface\\DRESSUPFRAME\\DressingRoomDruid",
};
local NUM_CLASS_BACKGROUNDS = 9;

local NUM_MAX_BACKGROUNDS = NUM_RACE_IDS + NUM_CLASS_BACKGROUNDS;

local RACE_NAMES = {
	[1]	 = "Human",
	[3]	 = "Dwarf",
	[4]	 = "NightElf",
	[7]	 = "Gnome",
	[2]	 = "Orc",
	[5]	 = "Scourge",
	[6]	 = "Tauren",
	[8]	 = "Troll",
	[0]	 = "Pet",
	
	["Human"]		= 1,
	["Dwarf"]		= 3,
	["NightElf"]	= 4,
	["Gnome"]		= 7,
	["Orc"]			= 2,
	["Scourge"]		= 5,
	["Tauren"]		= 6,
	["Troll"]		= 8,
	["Pet"]			= 0,
}

function DressUpRaceDropdown_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:AddLine("Change Preview Race");
	GameTooltip:AddLine("View your character as a different race. There is no way to control specific racial features.", 1, 1, 1, true);
	GameTooltip:AddLine("Due to insanity related to weapon slot previews, they are just reset when swapping race or sex.", 1, 1, 1, true);
	GameTooltip:Show();
end

function DressUpRaceDropdown_OnLeave(self)
	GameTooltip:Hide();
end

local tooltip = nil;

function Addon:GetRealItemLevel(itemLink, itemSlotId)
	if(not itemLink) then return 0, 0; end
	
	if(not DressUpInternalTooltip) then
		tooltip = CreateFrame("GameTooltip", "DressUpInternalTooltip", UIParent, "GameTooltipTemplate");
	end
	
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	if(itemSlotId) then
		tooltip:SetInventoryItem("player", itemSlotId);
	else
		tooltip:SetHyperlink(itemLink);
	end
	tooltip:Show();
	
	local _, _, _, itemLevel = GetItemInfo(itemLink);
	
	local numLines = math.min(5, tooltip:NumLines());
	for row_index = 2, numLines do
		local left = _G[tooltip:GetName() .. "TextLeft" .. row_index];
		
		if(left) then
			local currentItemLevel, defaultItemLevel = string.match(strtrim(left:GetText() or ""), "Item Level (%d+) ?%(?(%d*)%)?");
			if(currentItemLevel ~= nil) then
				currentItemLevel, defaultItemLevel = tonumber(currentItemLevel), tonumber(defaultItemLevel);
				return currentItemLevel, defaultItemLevel or itemLevel;
			end
		end
	end
	
	return itemLevel, itemLevel;
end

local ILVL_MIN_COLOR = {255, 191, 116};
local ILVL_MAX_COLOR = {147, 231, 255};
local ILVL_COLOR_DIFF = {
	ILVL_MAX_COLOR[1] - ILVL_MIN_COLOR[1],
	ILVL_MAX_COLOR[2] - ILVL_MIN_COLOR[2],
	ILVL_MAX_COLOR[3] - ILVL_MIN_COLOR[3],
};

function Addon:GetRangeColor(value, minvalue, maxvalue)
	if(not value) then return "ffffff" end
	
	local progress = (value - minvalue) / math.max(1, maxvalue - minvalue);
	return string.format("%02x%02x%02x",
		ILVL_MIN_COLOR[1] + ILVL_COLOR_DIFF[1] * progress,
		ILVL_MIN_COLOR[2] + ILVL_COLOR_DIFF[2] * progress,
		ILVL_MIN_COLOR[3] + ILVL_COLOR_DIFF[3] * progress
	);
end

local MESSAGE_PATTERN = "|cffffae12DressUp|r %s";
function Addon:AddMessage(pattern, ...)
	DEFAULT_CHAT_FRAME:AddMessage(MESSAGE_PATTERN:format(string.format(pattern, ...)));
end

function Addon:UpdatePaperDollItemLevels()
	local itemlevels = {};
	
	local lowest = 999999;
	local highest = 0;
	
	for slotName, slotId in pairs(paperDollSlots) do
		local realSlotId = slotId;
		local link = GetInventoryItemLink("player", slotId);
		if(link) then
			local itemLevel, defaultItemLevel = Addon:GetRealItemLevel(link, realSlotId);
			if(itemLevel) then
				itemlevels[realSlotId] = itemLevel;
				lowest = math.min(lowest, itemLevel or 1);
				highest = math.max(highest, itemLevel or 1);
			end
		end
	end
	
	for slotName, slotId in pairs(paperDollSlots) do
		local frame = _G[slotName .. "ItemLevel"];
		local itemLevel = itemlevels[slotId];
		if(itemLevel) then
			if(self.db.global.ColorizedItemLevels) then
				frame.value:SetText(("|cff%s%d|r"):format(Addon:GetRangeColor(itemLevel, lowest, highest), itemLevel));
			else
				frame.value:SetText(("%d"):format(itemLevel));
			end
		else
			frame.value:SetText("");
		end
	end
end

function Addon:ShowItemLevels()
	for slotName, slotId in pairs(paperDollSlots) do
		local frame = _G[slotName .. "ItemLevel"];
		frame:Show();
	end
	
	if (CharacterRangedSlotCount) then
		CharacterRangedSlotCount:ClearAllPoints();
		CharacterRangedSlotCount:SetPoint("TOPRIGHT", CharacterRangedSlot, "TOPRIGHT", -5, -4);
	end
end

function Addon:HideItemLevels()
	for slotName, slotId in pairs(paperDollSlots) do
		local frame = _G[slotName .. "ItemLevel"];
		frame:Hide();
	end
	
	if (CharacterRangedSlotCount) then
		CharacterRangedSlotCount:ClearAllPoints();
		CharacterRangedSlotCount:SetPoint("BOTTOMRIGHT", CharacterRangedSlot, "BOTTOMRIGHT", -5, 2);
	end
end

local ITEMLEVEL_VISIBILITY_HIDE  = 0;
local ITEMLEVEL_VISIBILITY_ONALT = 1;
local ITEMLEVEL_VISIBILITY_SHOW  = 2;

function Addon:MODIFIER_STATE_CHANGED()
	if(self.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_HIDE) then
		Addon:HideItemLevels();
		return;
	end
	
	if(self.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_SHOW) then
		Addon:ShowItemLevels();
		return;
	end
	
	if(self.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_ONALT) then
		if(IsAltKeyDown()) then
			Addon:ShowItemLevels();
		else
			Addon:HideItemLevels();
		end
	end
end

function Addon:OnInitialize()
	local defaults = {
		global = {
			DimBackground = true,
			HideGizmo = true,
			DisableSidePanel = true,
			
			ItemLevelVisibility = ITEMLEVEL_VISIBILITY_ONALT,
			ColorizedItemLevels = true,
			
			HideTabard = false,
			HideWeapons = false,
			HideShirt = false,
			StartUndressed = false,
			
			SaveCustomBackground = false,
			CustomBackground = nil,
			
			WhisperAlertShown = false,
			
			ShowPanelButtons = true,
			
			Size = {
				Width = 384,
				Height = 474,
			},
		},
	};
	
	self.db = AceDB:New("DressupDB", defaults);
	
	if(self.db.global.HideItemLevel == true) then
		self.db.global.ItemLevelVisibility = ITEMLEVEL_VISIBILITY_HIDE;
		self.db.global.HideItemLevel = nil;
	end
	
	if(self.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_SHOW) then
		Addon:ShowItemLevels();
	elseif(self.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_HIDE) then
		Addon:HideItemLevels();
	end
end

local DressUpModelOnEnter;
local DressUpModelOnLeave;

SLASH_DRESSUP1	= "/dressup";
SLASH_DRESSUP2	= "/dressingroom";
SlashCmdList["DRESSUP"] = function(msg)
	local msg = strtrim(strlower(msg or ""));
	if (msg == "reset" or msg == "resetsize") then
		Addon:ResetWindowSize();
	end
	DressUpFrame_Show();
end

function Addon:OnEnable()
	DressUpFrame:SetClampedToScreen(true);
	DressUpFrame:SetMinResize(384, 474);
	DressUpFrame:SetMaxResize(
		min(GetScreenWidth() - 50, 950),
		min(GetScreenHeight() - 50, 950)
	);
	
	local maxWidth, maxHeight = DressUpFrame:GetMaxResize();
	if (self.db.global.Size.Width > maxWidth or self.db.global.Size.Height > maxHeight) then
		Addon:ResetWindowSize();
	else
		DressUpFrame:SetSize(self.db.global.Size.Width, self.db.global.Size.Height);
	end
	
	DressUpModelOnEnter = DressUpModel:GetScript("OnEnter");
	DressUpModelOnLeave = DressUpModel:GetScript("OnLeave");

	Addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	Addon:RegisterEvent("MODIFIER_STATE_CHANGED");
	
	Addon.DualWieldIndex = 0;
	
	Addon.ItemButtons = {};
	
	Addon:InitializeItemButtons();
	Addon:ResetItemButtons(true);
	
	Addon:InitializeRaceMenu();
	
	Addon:ToggleGizmo();
	Addon:UpdateBackgroundDim();
	
	-- Initialize hooks
	Addon:HookScript(PaperDollFrame, "OnShow", function()
		Addon:PAPERDOLL_OPENED()
	end);
	
	DressUpModel:SetScript("OnMouseWheel", function(self, delta)
		if(not IsControlKeyDown()) then
			Model_OnMouseWheel(self, delta);
		else
			Addon:SwitchBackground(delta);
		end
	end);
	
	Addon:HookScript(DressUpModel, "OnMouseDown", function(self, button)
		if(IsControlKeyDown() and button == "MiddleButton") then
			Addon:SwitchBackground(0);
		end
	end);
	
	Addon:HookScript(DressUpFrame, "OnShow", function()
		Addon.DualWieldBullshit = true;
		Addon:ResetRaceSelect();
		Addon:ResetItemButtons(true);
	end);
	
	Addon:HookScript(DressUpFrameResetButton, "OnClick", function()
		Addon.DualWieldIndex = 0;
		Addon.DualWieldBullshit = true;
		Addon:ResetItemButtons(true);
		Addon:ResetRaceSelect();
	end);
	
	hooksecurefunc(DressUpModel, "TryOn", function(self, ...) Addon:TryOn(...) end);
	
	hooksecurefunc("DressUpFrame_Show", function()
		Addon:HideConditionalSlots();
	end);
	
	hooksecurefunc(DressUpModel, "Dress", function()
		Addon:HideConditionalSlots();
	end);
end

function Addon:UpdateButtonsVisibility()
	if (Addon.db.global.ShowPanelButtons) then
		DressupCharacterPanelSettingsButton:Show();
		DressUpCharacterPanelWhisperButton:Show();
	else
		DressupCharacterPanelSettingsButton:Hide();
		DressUpCharacterPanelWhisperButton:Hide();
	end
end

function CustomDressUpFrameResize_OnEnter(self)
	self.handle:SetTexCoord(0.5, 1, 0, 1);
	SetCursor("Interface\\Cursor\\UI-Cursor-SizeRight");
end

function CustomDressUpFrameResize_OnLeave(self)
	self.handle:SetTexCoord(0, 0.5, 0, 1);
	SetCursor(nil);
end

function CustomDressUpFrameResize_OnUpdate(self, elapsed)
	if(CustomDressUpFrame.sizing) then
		Addon:UpdateBackgroundTexCoords();
	end
end

function CustomDressUpFrameResize_OnMouseDown(self, button)
	CustomDressUpFrame:StartSizing();
	CustomDressUpFrame.sizing = true;
end

function CustomDressUpFrameResize_OnMouseUp(self, button)
	CustomDressUpFrame:StopMovingOrSizing();
	CustomDressUpFrame.sizing = false;
	
	local width, height = CustomDressUpFrame:GetSize();
	Addon.db.global.Size.Width = width;
	Addon.db.global.Size.Height = height;
end

function Addon:ResetWindowSize()
	CustomDressUpFrame:SetSize(384, 474);
	
	local width, height = CustomDressUpFrame:GetSize();
	Addon.db.global.Size.Width = width;
	Addon.db.global.Size.Height = height;
end

function Addon:ToggleGizmo()
	if(self.db.global.HideGizmo) then
		DressUpModel:SetScript("OnEnter", nil);
		DressUpModel:SetScript("OnLeave", nil);
		--DressUpModelControlFrame:Hide();
	else
		DressUpModel:SetScript("OnEnter", DressUpModelOnEnter);
		DressUpModel:SetScript("OnLeave", DressUpModelOnLeave);
	end
end

function DressupSettingsButton_OnLoad(self)
	self:SetFrameLevel(self:GetParent():GetFrameLevel()+2);
end

function DressupSettingsButton_OnClick(self)
	if(not Addon.ContextMenu) then
		Addon.ContextMenu = CreateFrame("Frame", ADDON_NAME .. "ContextMenuFrame", UIParent, "UIDropDownMenuTemplate");
	end
	
	local contextMenuData = {
		{
			text = "DressUp Options", isTitle = true, notCheckable = true,
		},
		{
			text = "Dim the preview background",
			func = function()
				Addon.db.global.DimBackground = not Addon.db.global.DimBackground;
				Addon:UpdateBackgroundDim();
			end,
			checked = function() return Addon.db.global.DimBackground end,
			isNotRadio = true,
		},
		{
			text = "Save custom background",
			func = function()
				Addon.db.global.SaveCustomBackground = not Addon.db.global.SaveCustomBackground;
				if(not Addon.db.global.SaveCustomBackground) then
					Addon.db.global.CustomBackground = nil;
				elseif(Addon.CustomBackground) then
					Addon.db.global.CustomBackground = Addon.CustomBackground;
				end
			end,
			checked = function() return Addon.db.global.SaveCustomBackground end,
			isNotRadio = true,
		},
		{
			text = "Hide model control gizmo",
			func = function() Addon.db.global.HideGizmo = not Addon.db.global.HideGizmo; Addon:ToggleGizmo(); end,
			checked = function() return Addon.db.global.HideGizmo end,
			isNotRadio = true,
		},
		{
			text = "Disable side panel preview",
			func = function() Addon.db.global.DisableSidePanel = not Addon.db.global.DisableSidePanel; end,
			checked = function() return Addon.db.global.DisableSidePanel end,
			isNotRadio = true,
		},
		{
			text = " ", isTitle = true, notCheckable = true,
		},
		{
			text = "Slot visibility", isTitle = true, notCheckable = true,
		},
		{
			text = "Always start undressed",
			func = function() Addon.db.global.StartUndressed = not Addon.db.global.StartUndressed; end,
			checked = function() return Addon.db.global.StartUndressed end,
			isNotRadio = true,
		},
		{
			text = "Always hide tabard",
			func = function() Addon.db.global.HideTabard = not Addon.db.global.HideTabard; end,
			checked = function() return Addon.db.global.HideTabard end,
			isNotRadio = true,
		},
		{
			text = "Always hide weapons",
			func = function() Addon.db.global.HideWeapons = not Addon.db.global.HideWeapons; end,
			checked = function() return Addon.db.global.HideWeapons end,
			isNotRadio = true,
		},
		{
			text = "Always hide shirt",
			func = function() Addon.db.global.HideShirt = not Addon.db.global.HideShirt; end,
			checked = function() return Addon.db.global.HideShirt end,
			isNotRadio = true,
		},
		{
			text = " ", isTitle = true, notCheckable = true,
		},
		{
			text = "Character Panel", isTitle = true, notCheckable = true,
		},
		{
			text = "Show buttons on character panel",
			func = function()
				Addon.db.global.ShowPanelButtons = not Addon.db.global.ShowPanelButtons;
				Addon:UpdateButtonsVisibility();
			end,
			isNotRadio = true,
			checked = function() return Addon.db.global.ShowPanelButtons end,
		},
		{
			text = "Always hide item levels",
			func = function()
				Addon.db.global.ItemLevelVisibility = ITEMLEVEL_VISIBILITY_HIDE;
				Addon:HideItemLevels();
			end,
			checked = function() return Addon.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_HIDE  end,
		},
		{
			text = "Show item level when holding alt",
			func = function()
				Addon.db.global.ItemLevelVisibility = ITEMLEVEL_VISIBILITY_ONALT;
				Addon:MODIFIER_STATE_CHANGED();
			end,
			checked = function() return Addon.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_ONALT  end,
		},
		{
			text = "Always show item levels",
			func = function()
				Addon.db.global.ItemLevelVisibility = ITEMLEVEL_VISIBILITY_SHOW;
				Addon:ShowItemLevels();
			end,
			checked = function() return Addon.db.global.ItemLevelVisibility == ITEMLEVEL_VISIBILITY_SHOW end,
		},
		{
			text = "Colorize item level numbers",
			func = function()
				Addon.db.global.ColorizedItemLevels = not Addon.db.global.ColorizedItemLevels;
				Addon:UpdatePaperDollItemLevels()
			end,
			checked = function() return Addon.db.global.ColorizedItemLevels end,
			isNotRadio = true,
		},
		{
			text = " ", isTitle = true, notCheckable = true,
		},
		{
			text = "Reset window size",
			func = function()
				Addon:ResetWindowSize()
			end,
			notCheckable = true,
		},
	};
	
	Addon.ContextMenu:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	EasyMenu(contextMenuData, Addon.ContextMenu, "cursor", 0, 0, "MENU");
	
	DropDownList1:ClearAllPoints();
	DropDownList1:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	DropDownList1:SetClampedToScreen(true);
end

function Addon:SetDressUpBackground(frame, fileName, classBackground)
	local imageWidth = 318;
	local imageHeight = 332;
	if(not classBackground) then
		fileName = fileName or "Orc";
		frame.background:SetTexture("Interface\\AddOns\\DressUp\\media\\Background-" .. fileName);
	else
		imageWidth = 480;
		imageHeight = 502;
		frame.background:SetTexture(fileName);
	end
	
	Addon:UpdateBackgroundTexCoords(imageWidth, imageHeight);
	Addon:UpdateBackgroundDim();
end

function Addon:UpdateBackgroundTexCoords(imageWidth, imageHeight)
	if(imageWidth) then Addon.CurrentImageWidth = imageWidth end
	if(imageHeight) then Addon.CurrentImageHeight = imageHeight end
	if(not Addon.CurrentImageWidth or not Addon.CurrentImageHeight) then return end
	
	local width, height = CustomDressUpModel:GetSize();
	local ratio = width / height;
	
	local left = Addon.CurrentImageWidth / 512;
	local right = Addon.CurrentImageHeight / 512;
	local origRatio = left / right;
	
	local ow = left / 2;
	local oh = right / 2;
	
	local x, y = 1, 1;
	
	if(ratio <= origRatio) then
		x = ratio / origRatio;
	else
		y = origRatio / ratio;
	end
	
	local l, r, t, b = math.max(ow - ow * x, 0),
	                   math.min(ow + ow * x, left),
	                   math.max(oh - oh * y, 0),
	                   math.min(oh + oh * y, right);
	
	CustomDressUpBackground:SetTexCoord(l, r, t, b);
end

function Addon:UpdateBackgroundDim()
	if(self.db.global.DimBackground) then
		CustomDressUpBackground:SetVertexColor(0.52, 0.52, 0.52);
	else
		CustomDressUpBackground:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function Addon:ResetRaceSelect()
	local _, raceID = UnitRace("player");

	Addon.CustomBackground = nil;
	Addon.SelectedRace = -1;
	Addon.SelectedGender = UnitSex("player")-2;
	
	if(Addon.SelectedGender == 0) then
		DressUpGenderButtonMale:SetChecked(true);
		DressUpGenderButtonFemale:SetChecked(false);
	elseif(Addon.SelectedGender == 1) then
		DressUpGenderButtonMale:SetChecked(false);
		DressUpGenderButtonFemale:SetChecked(true);
	end
	
	DressUpModel:SetUnit("player");
	
	if(self.db.global.SaveCustomBackground and self.db.global.CustomBackground) then
		Addon.CustomBackground = self.db.global.CustomBackground;
		Addon:SetCustomBackground(self.db.global.CustomBackground);
	else
		Addon:SetDressUpBackground(DressUpFrame, raceID);
	end
	
	UIDropDownMenu_SetText(DressUpRaceDropdown, "Change Preview Race");
end

function Addon:GetRaceIndex(raceID)
	for k, id in ipairs(RACE_IDS) do
		if(id == raceID) then return k end
	end
	
	return nil;
end

function Addon:SetCustomBackground(background_id)
	if(not background_id) then return end
	
	if(background_id == 0) then
		Addon:SetDressUpBackground(DressUpFrame, "Pet");
	elseif(background_id > 0 and background_id <= NUM_RACE_IDS) then
		Addon:SetDressUpBackground(DressUpFrame, RACE_NAMES[RACE_IDS[background_id]]);
	elseif(background_id > NUM_RACE_IDS) then
		Addon:SetDressUpBackground(DressUpFrame, CLASS_BACKGROUNDS[background_id - NUM_RACE_IDS], true);
	end
end

function Addon:SwitchBackground(dir)
	if(dir == 0) then
		Addon.CustomBackground = 0;
	else
		if(Addon.CustomBackground == nil or Addon.CustomBackground == 0) then
			local id;
			if(Addon.SelectedRace == -1) then
				local _, raceId = UnitRace("player");
				id = RACE_NAMES[raceId];
			else
				id = Addon.SelectedRace;
			end
			
			Addon.CustomBackground = Addon:GetRaceIndex(id);
			dir = 0;
		end
		
		Addon.CustomBackground = Addon.CustomBackground - dir;
		if(Addon.CustomBackground > NUM_MAX_BACKGROUNDS) then Addon.CustomBackground = 1 end
		if(Addon.CustomBackground < 1) then Addon.CustomBackground = NUM_MAX_BACKGROUNDS end
	end
	
	if(self.db.global.SaveCustomBackground) then
		self.db.global.CustomBackground = Addon.CustomBackground;
	end
	
	Addon:SetCustomBackground(Addon.CustomBackground);
end

function SetDressUpAlpha(alpha, brightness, desaturate)
	local b = brightness;
	
	if(DressUpFrame.BGTopLeft) then
		DressUpFrame.BGTopLeft:SetVertexColor(b, b, b, alpha);
		DressUpFrame.BGTopLeft:SetDesaturated(desaturate);
	end
	
	if(DressUpFrame.BGTopRight) then
		DressUpFrame.BGTopRight:SetVertexColor(b, b, b, alpha);
		DressUpFrame.BGTopRight:SetDesaturated(desaturate);
	end
	
	if(DressUpFrame.BGBottomLeft) then
		DressUpFrame.BGBottomLeft:SetVertexColor(b, b, b, alpha);
		DressUpFrame.BGBottomLeft:SetDesaturated(desaturate);
	end
	
	if(DressUpFrame.BGBottomRight) then
		DressUpFrame.BGBottomRight:SetVertexColor(b, b, b, alpha);
		DressUpFrame.BGBottomRight:SetDesaturated(desaturate);
	end
end

function DressUpGenderButton_OnClick(self)
	local gender = self:GetID();
	
	CloseMenus();
	
	if(Addon.SelectedGender ~= gender) then
		DressUpModel:SetCustomRace(Addon.SelectedRace, gender);
		Addon:ReapplyPreviewItems();
	end
	
	if(gender == 0) then
		DressUpGenderButtonMale:SetChecked(true);
		DressUpGenderButtonFemale:SetChecked(false);
	elseif(gender == 1) then
		DressUpGenderButtonMale:SetChecked(false);
		DressUpGenderButtonFemale:SetChecked(true);
	end
	
	Addon.SelectedGender = gender;
end

function DressUpRaceDropdown_SelectOption(self)
	Addon.SelectedRace = self.value.id;
	
	DressUpModel:SetCustomRace(self.value.id, Addon.SelectedGender);
	if(Addon.CustomBackground == nil) then
		Addon:SetDressUpBackground(DressUpFrame, RACE_NAMES[self.value.id]);
	end
	
	UIDropDownMenu_SetText(DressUpRaceDropdown, self.value.name);
	
	Addon:ReapplyPreviewItems();
end

function Addon:GenerateRaceMenu()
	local menu = {};
	
	local HordeThreshold = 1 + NUM_ALLIANCE_RACES;
	local NeutralThreshold = HordeThreshold + NUM_HORDE_RACES;
	
	local factions = {
		[1]	= "Alliance",
		[HordeThreshold] = "Horde",
		[NeutralThreshold] = "Neutral",
	};
	
	for k, v in ipairs(RACES) do
		if(factions[k] ~= nil) then
			if(k > 1) then
				tinsert(menu, {
					text = " ", isTitle = true, notCheckable = true,
				});
			end
			
			tinsert(menu, {
				text = factions[k], isTitle = true, notCheckable = true,
			});
		end
		
		tinsert(menu, {
			text = v,
			value = {
				id = RACE_IDS[k],
				name = v,
			},
			func = DressUpRaceDropdown_SelectOption,
			notCheckable = true,
		});
	end
	
	return menu;
end

function DressUpRaceDropdown_OnClick()
	if(DropDownList1:IsVisible()) then 
		CloseMenus(); 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	return end
	
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	
	local menudata = Addon:GenerateRaceMenu();
	EasyMenu(menudata, DressUpRaceDropdown, DressUpRaceDropdown, 15, 8);
	DropDownList1:SetWidth(148);
	
	for i=1, 18 do
		_G["DropDownList1Button" .. i]:SetWidth(122);
	end
end

function Addon:InitializeRaceMenu()
	-- DressUpFrameOutfitDropDown:ClearAllPoints();
	-- DressUpFrameOutfitDropDown:SetPoint("BOTTOMLEFT", DressUpFrame, "BOTTOMLEFT", 29, 112);
	
	--DressUpFrameOutfitDropDown:SetFrameStrata(DressUpModel:GetFrameStrata());
	--DressUpFrameOutfitDropDown:SetFrameLevel(DressUpModel:GetFrameLevel()+1);
	
	DressUpRaceDropdownButton:SetScript("OnClick", DressUpRaceDropdown_OnClick);
	
	UIDropDownMenu_SetWidth(DressUpRaceDropdown, 132);
	-- UIDropDownMenu_SetButtonWidth(DressUpRaceDropdown, 132);
	UIDropDownMenu_JustifyText(DressUpRaceDropdown, "RIGHT");
	-- UIDropDownMenu_SetSelectedID(DressUpRaceDropdown, 1);
	
	UIDropDownMenu_SetText(DressUpRaceDropdown, "Change Preview Race");
end

function DressupPreviewItemButton_OnClick(self, button)
	local slot = self:GetID();
	
	if(button == "LeftButton" and IsShiftKeyDown()) then
		if(Addon.ItemButtons[slot].itemLink) then
			ChatEdit_InsertLink(Addon.ItemButtons[slot].itemLink)
		end
	elseif(button == "RightButton") then
		Addon:SetButtonItem(slot, nil);
		DressUpModel:UndressSlot(slot);
		
		GameTooltip:ClearLines();
		GameTooltip:AddLine(Addon.ItemButtons[slot].slotName);
		GameTooltip:Show();
	end
end

function DressupPreviewItemButton_OnEnter(self)
	local slot = self:GetID();
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 40);
	
	if(Addon.ItemButtons[slot].itemLink) then
		GameTooltip:SetHyperlink(Addon.ItemButtons[slot].itemLink);
	else
		GameTooltip:AddLine(Addon.ItemButtons[slot].slotName);
	end
	
	GameTooltip:Show();
	
	ShoppingTooltip1:Hide();
	ShoppingTooltip2:Hide();
	if(ShoppingTooltip3) then ShoppingTooltip3:Hide(); end
end

function DressupPreviewItemButton_OnLeave(self)
	GameTooltip:Hide();
end

function Addon:InitializeItemButtons()
	local buttons = {
		DressupPreviewButtonHead,
		DressupPreviewButtonShoulder,
		DressupPreviewButtonBack,
		DressupPreviewButtonChest,
		DressupPreviewButtonShirt,
		DressupPreviewButtonTabard,
		DressupPreviewButtonWrist,
		DressupPreviewButtonHands,
		DressupPreviewButtonWaist,
		DressupPreviewButtonLegs,
		DressupPreviewButtonFeet,
		DressupPreviewButtonMainHand,
		DressupPreviewButtonOffHand,
		DressupPreviewButtonRanged,
	};
	
	for _, buttonFrame in ipairs(buttons) do
		local slot = buttonFrame:GetID();
		
		local invslot = INVENTORY_SLOT_NAMES[slot];
		local _, slotTexture = GetInventorySlotInfo(invslot);
		
		buttonFrame.background:SetTexture(slotTexture);
		
		Addon.ItemButtons[slot] = {
			Frame = buttonFrame,
			itemLink = nil,
			slotName = _G[invslot],
		};
		
		buttonFrame.icon:Hide();
	end
end

function Addon:GetInfoForSlot(slot_id, transmogType)
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, pendingSourceID, pendingVisualID, hasPendingUndo = C_Transmog.GetSlotVisualInfo(slot_id, transmogType);
	if ( appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
		appliedSourceID = baseSourceID;
		appliedVisualID = baseVisualID;
	end
	local selectedSourceID, selectedVisualID;
	if ( pendingSourceID ~= REMOVE_TRANSMOG_ID ) then
		selectedSourceID = pendingSourceID;
		selectedVisualID = pendingVisualID;
	elseif ( hasPendingUndo ) then
		selectedSourceID = baseSourceID;
		selectedVisualID = baseVisualID;
	else
		selectedSourceID = appliedSourceID;
		selectedVisualID = appliedVisualID;
	end
	return appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID;
end

function Addon:HideConditionalSlots()
	if(not Addon.db.global.StartUndressed) then
		if(Addon.db.global.HideTabard) then
			DressUpModel:UndressSlot(19);
			Addon:SetButtonItem(19, nil);
		end
		
		if(Addon.db.global.HideShirt) then
			DressUpModel:UndressSlot(4);
			Addon:SetButtonItem(4, nil);
		end
		
		if(Addon.db.global.HideWeapons) then
			DressUpModel:UndressSlot(16);
			Addon:SetButtonItem(16, nil);
			
			DressUpModel:UndressSlot(17);
			Addon:SetButtonItem(17, nil);
		end
	else
		DressUpModel:Undress();
	end
end

function Addon:ResetItemButtons(setEquipment)
	for slot, button in pairs(Addon.ItemButtons) do
		local itemlink = nil;
		
		if(setEquipment and not Addon.db.global.StartUndressed) then
			local skip = false;
			if(slot == 19 and Addon.db.global.HideTabard) then skip = true; end
			if(slot == 4 and Addon.db.global.HideShirt) then skip = true; end
			if((slot == 16 or slot == 17) and Addon.db.global.HideWeapons) then skip = true; end
			
			-- Ranged weapon is never visible by default
			if (slot == 18) then skip = true end
			
			if(not Addon:IsSlotHidden(slot) and not skip) then
				itemlink = GetInventoryItemLink("player", slot);
			end
		end
		
		Addon:SetButtonItem(slot, itemlink);
	end
	
	Addon:HideConditionalSlots();
end

function Addon:ReapplyPreviewItems()
	DressUpModel:Undress();
	
	for slot = 1, 19 do
		-- Refresh the actual preview items
		local item = Addon:GetSlotItem(slot);
		if(item) then
			DressUpModel:TryOn(item, INVENTORY_SLOT_NAMES[slot]);
		else
			DressUpModel:UndressSlot(slot);
		end
	end
	
	DressUpModel:UndressSlot(16);
	Addon:SetButtonItem(16, nil);
	DressUpModel:UndressSlot(17);
	Addon:SetButtonItem(17, nil);
	DressUpModel:UndressSlot(18);
	Addon:SetButtonItem(18, nil);
end

function DressUpHideArmorButton_OnClick(self)
	Addon.DualWieldIndex = 0;
	Addon.DualWieldBullshit = true;
	DressUpModel:Undress();
	Addon:ResetItemButtons();
end

function Addon:IsSlotHidden(slot_id)
	if(slot_id == 1 and not ShowingHelm()) then return true end
	if(slot_id == 15 and not ShowingCloak()) then return true end
	return false;
end

-- Overwrite the blizz function
local _DressUpVisual = DressUpVisual;
function DressUpVisual(...)
	if ( not Addon.db.global.DisableSidePanel and SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown() ) then
		if ( not SideDressUpFrame:IsShown() or SideDressUpFrame.mode ~= "player" ) then
			SideDressUpFrame.mode = "player";
			SideDressUpFrame.ResetButton:Show();
	
		local race, fileName = UnitRace("player");
			SetDressUpBackground(SideDressUpFrame, fileName);

			ShowUIPanel(SideDressUpFrame);
			SideDressUpModel:SetUnit("player");
		end
		SideDressUpModel:TryOn(...);
	else
		if(not DressUpFrame:IsShown()) then
			DressUpFrame_Show();
		end
		DressUpModel:TryOn(...);
	end
	return true;
end

function Addon:TryOn(itemLink, previewSlot, enchantID)
	--print(itemLink, previewSlot, enchantID);
	
	local onlyMainhand = false;
	local onlyOffhand = false;
	
	local targetSlotID;
	if (itemLink ~= nil) then
		local _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemLink);
		
		-- Don't preview relics
		if (itemEquipLoc == "INVTYPE_RELIC") then
			return;
		end
		
		onlyMainhand = (itemEquipLoc == "INVTYPE_WEAPONMAINHAND");
		onlyOffhand = (itemEquipLoc == "INVTYPE_WEAPONOFFHAND");
		
		targetSlotID = previewSlot and GetInventorySlotInfo(previewSlot) or nil;
		if(not targetSlotID) then
			targetSlotID = Addon:GetInvSlot(itemEquipLoc);
		end
	end
	
	local canDualwield = IsSpellKnown(674);
	if (targetSlotID == 16 and canDualwield) then
		local currentItemMainhand = Addon:GetSlotItem(16);
		local currentItemOffhand = Addon:GetSlotItem(17);
		
		local slots = {
			16,
			17
		};
		
		--print(Addon.DualWieldIndex, targetSlotID);
		
		-- This is complete insanity
		-- Dual wield preview seems to put same item in main hand twice if:
		-- * slot was empty
		-- * dressup window was only just opened
		-- * character was undressed
		-- * who knows when
		if (onlyMainhand or onlyOffhand) then
			Addon.DualWieldIndex = 0;
		else
			if (currentItemMainhand ~= nil) then
				Addon.DualWieldBullshit = false;
			end
			
			if (currentItemMainhand == itemLink or Addon.DualWieldBullshit == false) then
				targetSlotID = slots[Addon.DualWieldIndex + 1];
				Addon.DualWieldIndex = (Addon.DualWieldIndex + 1) % 2;
			else
				Addon.DualWieldIndex = 0;
			end
		end
		
		Addon.DualWieldBullshit = false;
		
		--print(Addon.DualWieldIndex, targetSlotID);
	elseif (targetSlotID == 18 and canDualwield) then
		Addon.DualWieldIndex = 0;
		Addon.DualWieldBullshit = true;
		Addon:SetButtonItem(16, nil);
		Addon:SetButtonItem(17, nil);
	end
	
	if (targetSlotID == 16 or targetSlotID == 17) then
		Addon:SetButtonItem(18, nil);
	end
	
	if (targetSlotID ~= nil and itemLink ~= nil) then
		Addon:SetButtonItem(targetSlotID, itemLink);
	end
end

function Addon:GetInvSlot(equiploc)
	if(equiploc == "") then return nil end
	return INVENTORY_SLOTS[equiploc] or nil;
end

function Addon:SetButtonItem(slot, itemlink)
	if(not Addon.ItemButtons[slot]) then return end
	
	local rarity, texture = 0, nil;
	if(itemlink) then
		_, _, rarity, _, _, _, _, _, _, texture = GetItemInfo(itemlink);
	end
	
	Addon.ItemButtons[slot].itemLink = itemlink;
	
	if(texture) then
		Addon.ItemButtons[slot].Frame.icon:SetTexture(texture)
		Addon.ItemButtons[slot].Frame.icon:Show();
	else
		Addon.ItemButtons[slot].Frame.icon:Hide();
	end
	
	if(rarity and (rarity >= 2 and rarity <= 7)) then
		local c = ITEM_QUALITY_COLORS[rarity];
		Addon.ItemButtons[slot].Frame.border:SetBlendMode("ADD");
		Addon.ItemButtons[slot].Frame.border:SetVertexColor(c.r, c.g, c.b, 1.0);
	else
		Addon.ItemButtons[slot].Frame.border:SetBlendMode("BLEND");
		Addon.ItemButtons[slot].Frame.border:SetVertexColor(0, 0, 0, 0.5);
	end
end

function Addon:GetSlotItem(slot)
	if(Addon.ItemButtons[slot]) then
		return Addon.ItemButtons[slot].itemLink;
	end
	
	return nil;
end

function Addon:GetItemID(itemLink)
	if(not itemLink) then return end
	
	local itemID = strmatch(itemLink, "item:(%d+)");
	return itemID and tonumber(itemID) or nil;
end

function Addon:GetPreviewedItemsList()
	local items = {};
	for _, slotID in ipairs(VISIBLE_SLOTS) do
		local sourceID = Addon:GetItemSourceID(slotID);
		
		if(slotID == 19) then
			local link = Addon:GetSlotItem(19);
			sourceID = Addon:GetItemID(link);
		end
	end
	return items;
end

function Addon:PAPERDOLL_OPENED()
	Addon:UpdatePaperDollItemLevels();
end

function Addon:PLAYER_EQUIPMENT_CHANGED(event, slot, hasItem)
	Addon:UpdatePaperDollItemLevels()
end
