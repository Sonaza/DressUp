------------------------------------------------------------
-- DressUp by Sonaza
-- All rights reserved
-- http://sonaza.com
------------------------------------------------------------

local ADDON_NAME = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), ADDON_NAME, "AceEvent-3.0", "AceHook-3.0");
_G[ADDON_NAME] = Addon;

local AceDB = LibStub("AceDB-3.0");

local _;

if(not CustomDressUpFrame) then
	error("You have updated the addon but only reloaded the interface. Please restart the game.", 1);
end

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
	["INVTYPE_RANGED"] = 16,
	["INVTYPE_THROWN"] = nil,
	["INVTYPE_RANGEDRIGHT"] = 16,
	["INVTYPE_RELIC"] = nil,
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
	["TABARDSLOT"]        = 19,
};

local VISIBLE_SLOTS = {
	1, 3, 4, 5, 6, 7, 8, 9, 10, 15, 16, 17, 19,
};

local HIDDEN_SOURCES_LIST = {
	[77343] = true, -- Shoulder
	[77344] = true, -- Helm
	[77345] = true, -- Cloak
};

-- 1 - Human
-- 2 - Orc
-- 3 - Dwarf
-- 4 - Nightelf
-- 5 - Undead
-- 6 - Tauren
-- 7 - Gnome
-- 8 - Troll
-- 9 - Goblin
-- 10 - Bloodelf
-- 11 - Draenei
-- 22 - Worgen
-- 24 - Pandaren
-- 25 - Alliance Pandaren
-- 26 - Horde Pandaren

-- 27 - Nightborne
-- 28 - Highmountain Tauren
-- 29 - Void Elf
-- 30 - Lightforged Draenei


local RACES = {
	"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen", "Void Elf", "Lightforged Draenei", --"Dark Iron Dwarf",
	"Orc", "Undead", "Tauren", "Troll", "Blood Elf", "Goblin", "Nightborne", "Highmountain Tauren", --"Zandalari Troll",
	"Pandaren",
};

local RACE_IDS = {
	1, 3, 4, 7, 11, 22, 29, 30,
	2, 5, 6, 8, 10, 9,  27, 28,
	24,
}

local RACE_NAMES = {
	[1]	 = "Human",
	[3]	 = "Dwarf",
	[4]	 = "NightElf",
	[7]	 = "Gnome",
	[11] = "Draenei",
	[22] = "Worgen",
	[2]	 = "Orc",
	[5]	 = "Scourge",
	[6]	 = "Tauren",
	[8]	 = "Troll",
	[10] = "BloodElf",
	[9]	 = "Goblin",
	[24] = "Pandaren",
	[0]	 = "Pet",
	
	["Human"]		= 1,
	["Dwarf"]		= 3,
	["NightElf"]	= 4,
	["Gnome"]		= 7,
	["Draenei"]		= 11,
	["Worgen"]		= 22,
	["Orc"]			= 2,
	["Scourge"]		= 5,
	["Tauren"]		= 6,
	["Troll"]		= 8,
	["BloodElf"]	= 10,
	["Goblin"]		= 9,
	["Pandaren"]	= 24,
	["Pet"]			= 0,
}

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

function Addon:GetArtifactItemLevel()
	local mainhand = GetInventoryItemLink("player", 16);
	local offhand = GetInventoryItemLink("player", 17);
	
	if(not mainhand) then return end
	
	local _, _, quality = GetItemInfo(mainhand);
	if(quality ~= 6) then return end
	
	local mainhandItemLevel = Addon:GetRealItemLevel(mainhand, 16);
	local offhandItemLevel = Addon:GetRealItemLevel(offhand, 17);
	
	return math.max(mainhandItemLevel, offhandItemLevel or 0);
end

function Addon:UpdatePaperDollItemLevels()
	local itemlevels = {};
	
	local lowest = 999999;
	local highest = 0;
	
	for slotName, slotId in pairs(paperDollSlots) do
		local realSlotId = slotId;
		local artifactItemLevel;
		if(realSlotId == 16 or realSlotId == 17) then
			artifactItemLevel = Addon:GetArtifactItemLevel();
		end
		
		local link = GetInventoryItemLink("player", slotId);
		if(link) then
			if(artifactItemLevel) then
				itemlevels[realSlotId] = artifactItemLevel;
				lowest = math.min(lowest, artifactItemLevel or 1);
				highest = math.max(highest, artifactItemLevel or 1);
			else
				local itemLevel, defaultItemLevel = Addon:GetRealItemLevel(link, realSlotId);
				if(itemLevel) then
					itemlevels[realSlotId] = itemLevel;
					lowest = math.min(lowest, itemLevel or 1);
					highest = math.max(highest, itemLevel or 1);
				end
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
end

function Addon:HideItemLevels()
	for slotName, slotId in pairs(paperDollSlots) do
		local frame = _G[slotName .. "ItemLevel"];
		frame:Hide();
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
			
			PromptForPreviews = true,
			
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
	
	if(not Addon.db.global.WhisperAlertShown) then
		DressUpPreviewWhisperButton.Alert:Show();
	end
	
	if(not Addon.InitializeComms) then
		error("You have updated the addon but only reloaded the interface. Please restart the game.", 1);
	end
	Addon:InitializeComms();
end

function DressUpPreviewWhisperButtonAlertCloseButton_OnClick(self)
	DressUpPreviewWhisperButton.Alert:Hide();
	Addon.db.global.WhisperAlertShown = true;
end

local DressUpModelOnEnter;
local DressUpModelOnLeave;

SLASH_DRESSUP1	= "/dressup";
SLASH_DRESSUP2	= "/dressingroom";
SlashCmdList["DRESSUP"] = function()
	DressUpFrame_Show();
end

function Addon:OnEnable()
	DressUpFrame:SetClampedToScreen(true);
	DressUpFrame:SetMinResize(384, 474);
	DressUpFrame:SetMaxResize(1000, 1000);
	
	DressUpFrame:SetSize(self.db.global.Size.Width, self.db.global.Size.Height);
	
	DressUpModelOnEnter = DressUpModel:GetScript("OnEnter");
	DressUpModelOnLeave = DressUpModel:GetScript("OnLeave");

	Addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	Addon:RegisterEvent("MODIFIER_STATE_CHANGED");
	
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
		Addon:ResetRaceSelect();
		Addon:ResetItemButtons(true);
	end);
	
	Addon:HookScript(DressUpFrameResetButton, "OnClick", function()
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

function Addon:ToggleGizmo()
	if(self.db.global.HideGizmo) then
		DressUpModel:SetScript("OnEnter", nil);
		DressUpModel:SetScript("OnLeave", nil);
		DressUpModelControlFrame:Hide();
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
			text = "Prompt when receiving preview whisper",
			func = function() Addon.db.global.PromptForPreviews = not Addon.db.global.PromptForPreviews; end,
			checked = function() return Addon.db.global.PromptForPreviews end,
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
	};
	
	Addon.ContextMenu:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	EasyMenu(contextMenuData, Addon.ContextMenu, "cursor", 0, 0, "MENU");
	
	DropDownList1:ClearAllPoints();
	DropDownList1:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	DropDownList1:SetClampedToScreen(true);
end

function Addon:SetDressUpBackground(frame, fileName)
	fileName = fileName or "Orc";
	frame.background:SetTexture("Interface\\AddOns\\DressUp\\media\\Background-" .. fileName);
	
	Addon:UpdateBackgroundTexCoords();
	Addon:UpdateBackgroundDim();
end

function Addon:UpdateBackgroundTexCoords()
	local width, height = CustomDressUpModel:GetSize();
	local ratio = width / height;
	
	-- local left = 0.578125;
	-- local right = 0.96875;
	local left = 0.62109375;
	local right = 0.6484375;
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
	else
		Addon:SetDressUpBackground(DressUpFrame, RACE_NAMES[RACE_IDS[Addon.CustomBackground]]);
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
		
		Addon.CustomBackground = Addon.CustomBackground + dir;
		if(Addon.CustomBackground > 13) then Addon.CustomBackground = 1 end
		if(Addon.CustomBackground < 1) then Addon.CustomBackground = 13 end
		
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
	
	local factions = {
		[1]	= "Alliance",
		[9] = "Horde",
		[17] = "Neutral",
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
	
	DressUpFrameOutfitDropDown:SetFrameStrata(DressUpModel:GetFrameStrata());
	DressUpFrameOutfitDropDown:SetFrameLevel(DressUpModel:GetFrameLevel()+1);
	
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

function Addon:ResetItemButtons(setEquipment, noOutfitReset)
	if(not noOutfitReset) then
		DressUpFrameOutfitDropDown:SelectOutfit(nil, false);
	end
	
	for slot, button in pairs(Addon.ItemButtons) do
		local itemlink = nil;
		
		if(setEquipment and not Addon.db.global.StartUndressed) then
			local skip = false;
			if(slot == 19 and Addon.db.global.HideTabard) then skip = true; end
			if(slot == 4 and Addon.db.global.HideShirt) then skip = true; end
			if((slot == 16 or slot == 17) and Addon.db.global.HideWeapons) then skip = true; end
			
			if(not Addon:IsSlotHidden(slot) and not skip) then
				itemlink = GetInventoryItemLink("player", slot)
				
				if(itemlink) then
					local isTransmogrified, hasPending, _, _, _, hasUndo, isHideVisual = C_Transmog.GetSlotInfo(slot, LE_TRANSMOG_TYPE_APPEARANCE);
					local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = Addon:GetInfoForSlot(slot, LE_TRANSMOG_TYPE_APPEARANCE)
				
					if(isTransmogrified and not isHideVisual) then
						itemlink = Addon:GetItemLinkFromSource(appliedSourceID);
					elseif(isHideVisual) then
						itemlink = nil;
					end
				end
			end
		end
		
		Addon:SetButtonItem(slot, itemlink);
	end
	
	Addon:HideConditionalSlots();
end

function Addon:ReapplyPreviewItems()
	DressUpModel:Undress();
	
	for slot = 1, 19 do
		if(Addon:IsSlotTransmogrifiable(slot)) then
			-- Refresh the actual preview items
			local item = Addon:GetSlotItem(slot);
			if(item) then
				DressUpModel:TryOn(item, INVENTORY_SLOT_NAMES[slot]);
			else
				DressUpModel:UndressSlot(slot);
			end
		end
	end
end

function DressUpHideArmorButton_OnClick(self)
	DressUpModel:Undress();
	Addon:ResetItemButtons();
end

function Addon:IsSlotHidden(slot_id)
	if(slot_id == 1 and not Addon:ShowingHelm()) then return true end
	if(slot_id == 3 and not Addon:ShowingShoulders()) then return true end
	if(slot_id == 15 and not Addon:ShowingCloak()) then return true end
	return false;
end

function Addon:ShowingHelm()
	local _, _, _, _, _, _, isHideVisual = C_Transmog.GetSlotInfo(1, LE_TRANSMOG_TYPE_APPEARANCE);
	return not isHideVisual;
end

function Addon:ShowingCloak()
	local _, _, _, _, _, _, isHideVisual = C_Transmog.GetSlotInfo(15, LE_TRANSMOG_TYPE_APPEARANCE);
	return not isHideVisual;
end

function Addon:ShowingShoulders()
	local _, _, _, _, _, _, isHideVisual = C_Transmog.GetSlotInfo(3, LE_TRANSMOG_TYPE_APPEARANCE);
	return not isHideVisual;
end

function Addon:GetItemSourceID(slot)
	local slotID, slotName;
	if(type(slot) == "string") then
		slotID   = INVENTORY_SLOT_NAMES[slot];
		slotName = slot;
	else
		slotID   = slot;
		slotName = INVENTORY_SLOT_NAMES[slot];
	end
	return DressUpFrameOutfitDropDown:GetSlotSourceID(slotName, LE_TRANSMOG_TYPE_APPEARANCE);
end

function Addon:GetItemLinkFromSource(sourceID)
	if(not sourceID) then return end
	
	local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID));
	return link;
end

function Addon:IsSlotTransmogrifiable(slot)
	return slot ~= 2 and
	       slot ~= 11 and
	       slot ~= 12 and
	       slot ~= 13 and
	       slot ~= 14;
end

function Addon:GetTransmogItemLinkFromSlot(slotID)
	if(not slotID) then return end
	
	-- local isTransmogrified, _, _, _, _, hasUndo, isHideVisual = C_Transmog.GetSlotInfo(slotID, LE_TRANSMOG_TYPE_APPEARANCE);
	-- if(not isTransmogrified or isHideVisual) then return nil end
	
	local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = Addon:GetInfoForSlot(slotID, LE_TRANSMOG_TYPE_APPEARANCE);
	return Addon:GetItemLinkFromSource(appliedSourceID);
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

hooksecurefunc("DressUpSources", function(...) Addon:DressUpSources(...) end);
function Addon:DressUpSources(appearanceSources, mainHandEnchant, offHandEnchant)
	if ( not appearanceSources ) then
		return true;
	end

	DressUpFrame_Show();
	
	DressUpModel:Undress();
	Addon:ResetItemButtons(false, true);
	
	local mainHandSlotID = GetInventorySlotInfo("MAINHANDSLOT");
	local secondaryHandSlotID = GetInventorySlotInfo("SECONDARYHANDSLOT");
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] and appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
				DressUpModel:TryOn(appearanceSources[i]);
			end
		end
	end

	DressUpModel:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
	DressUpModel:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);
end

function Addon:TryOn(itemSource, previewSlot, enchantID)
	if(not itemSource) then return end
	
	-- Reset item slot if it's zero
	if(itemSource == 0 and previewSlot) then
		targetSlotID = previewSlot and GetInventorySlotInfo(previewSlot) or nil;
		if(not targetSlotID) then
			targetSlotID = Addon:GetInvSlot(itemEquipLoc);
		end
		
		Addon:SetButtonItem(targetSlotID, nil);
		return;
	end
	
	local itemlink;
	if(type(itemSource) == "number") then
		-- Get itemlink from source id
		itemlink = Addon:GetItemLinkFromSource(itemSource);
	else
		-- Display is probably link
		itemlink = itemSource;
	end
	
	local targetSlotID;
	if(itemlink) then
		local _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemlink);
		
		targetSlotID = previewSlot and GetInventorySlotInfo(previewSlot) or nil;
		if(not targetSlotID) then
			targetSlotID = Addon:GetInvSlot(itemEquipLoc);
		end
		
		-- Don't display hidden sources
		if(HIDDEN_SOURCES_LIST[itemSource]) then return end
		
		Addon:SetButtonItem(targetSlotID, itemlink);
	end
	
	if(targetSlotID == 16 or targetSlotID == 17) then
		Addon:SetWeaponButtons();
	end
end

function Addon:UpdatePreviewSlot(slotID)
	if(not slotID) then return end
	local sourceID = Addon:GetItemSourceID(slotID);
	Addon:SetButtonItem(slotID, Addon:GetItemLinkFromSource(sourceID));
end

function Addon:SetWeaponButtons()
	-- Update weapons separately since in case of dualwielding, blizz preview is all kinds of wonky
	Addon:UpdatePreviewSlot(16);
	Addon:UpdatePreviewSlot(17);
end

-- Hacky hack hack
function Addon:ForceCacheLoad(itemList)
	local needsDelay = false;
	
	for slotID = 1, 18 do
		if(itemList[slotID] and itemList[slotID] ~= 0) then
			local itemLink = Addon:GetItemLinkFromSource(itemList[slotID]);
			local item = GetItemInfo(itemLink);
			if(not item) then needsDelay = true end
		end
	end
	
	if(itemList[19] and itemList[19] ~= 0) then
		local item = GetItemInfo(itemList[19]);
		if(not item) then needsDelay = true end
	end
	
	return needsDelay;
end

function Addon:LoadItemList(itemList)
	local needsDelay = Addon:ForceCacheLoad(itemList);
	
	local tempList = {};
	for slotID = 1, 19 do
		tempList[slotID] = itemList[slotID] or 0;
	end
	
	local tabard = tempList[19];
	tempList[19] = 0;
	
	local sourceList = {
		[1] = tempList,
		[2] = 0,
		[3] = 0,
	};
	
	C_Timer.After(needsDelay and 0.12 or 0, function()
		DressUpSources(unpack(sourceList));
		
		if(tabard ~= 0) then
			local _, tabard = GetItemInfo(tabard);
			DressUpModel:TryOn(tabard);
		end
	end);
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
		
		if(sourceID and sourceID ~= 0 and not HIDDEN_SOURCES_LIST[sourceID]) then
			items[slotID] = sourceID;
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
