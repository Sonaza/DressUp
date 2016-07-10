local ADDON_NAME, SHARED_DATA = ...;

local LibStub = LibStub;
local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceHook-3.0");
local AceDB = LibStub("AceDB-3.0");
_G[ADDON_NAME] = Addon;

local _;

local paperDollSlots = {
	["CharacterHeadSlot"]			= 1,
	["CharacterNeckSlot"]			= 2,
	["CharacterShoulderSlot"]		= 3,
	["CharacterBackSlot"]			= 15,
	["CharacterChestSlot"]			= 5,
	["CharacterShirtSlot"]			= 4,
	["CharacterTabardSlot"]			= 19,
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

local RACES = {
	"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen",
	"Orc", "Undead", "Tauren", "Troll", "Blood Elf", "Goblin",
	"Pandaren",
};

local RACE_IDS = {
	1, 3, 4, 7, 11, 22, 2, 5, 6, 8, 10, 9, 24,
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

function Addon:GetRealItemLevel(itemLink)
	if(not itemLink) then return 0, 0; end
	
	if(not DressUpInternalTooltip) then
		tooltip = CreateFrame("GameTooltip", "DressUpInternalTooltip", UIParent, "GameTooltipTemplate");
	end
	
	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:SetHyperlink(itemLink);
	
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

function Addon:UpdatePaperDollItemLevels()
	for slotName, slotId in pairs(paperDollSlots) do
		local frame = _G[slotName .. "ItemLevel"];
		
		local link = GetInventoryItemLink("player", slotId);
		if(link) then
			local itemLevel, defaultItemLevel = Addon:GetRealItemLevel(link);
			frame.value:SetText(itemLevel);
		else
			frame.value:SetText("");
		end
	end
end

function Addon:MODIFIER_STATE_CHANGED()
	for slotName, slotId in pairs(paperDollSlots) do
		local frame = _G[slotName .. "ItemLevel"];
		
		if(IsAltKeyDown() and not self.db.global.HideItemLevel) then
			frame:Show();
		else
			frame:Hide();
		end
	end
end

function Addon:OnInitialize()
	local defaults = {
		global = {
			DimBackground = true,
			HideGizmo = true,
			DisableSidePanel = true,
			HideItemLevel = false,
			
			HideTabard = false,
			HideWeapons = false,
			
			SaveCustomBackground = false,
			CustomBackground = nil,
		},
	};
	
	self.db = AceDB:New("DressupDB", defaults);
end

local DressUpModelOnEnter = DressUpModel:GetScript("OnEnter");
local DressUpModelOnLeave = DressUpModel:GetScript("OnLeave");

function Addon:OnEnable()
	Addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
	Addon:RegisterEvent("MODIFIER_STATE_CHANGED");
	
	Addon:InitializeDressUpFrame();
	Addon:InitializePaperDoll();
	
	Addon.WeaponPreviewSlot = 0;
	Addon.ItemButtons = {};
	
	Addon:InitializeItemButtons();
	Addon:ResetItemButtons(true);
	
	Addon:InitializeRaceMenu();
	
	Addon:ToggleBackgroundDim();
	Addon:ToggleGizmo();
	
	DressUpModel:HookScript("OnMouseDown", function(self, button)
		if(IsControlKeyDown() and button == "MiddleButton") then
			Addon:SwitchBackground(0);
		end
	end);
	
	DressUpModel:SetScript("OnMouseWheel", function(self, delta)
		if(not IsControlKeyDown()) then
			Model_OnMouseWheel(self, delta);
		else
			Addon:SwitchBackground(delta);
		end
	end);
	
	DressUpFrame:HookScript("OnShow", function()
		Addon:ResetRaceSelect();
		Addon:ResetItemButtons(true);
	end);
	
	hooksecurefunc(DressUpModel, "TryOn", function(self, ...) Addon:TryOn(...) end);
end

function Addon:ToggleBackgroundDim()
	if(self.db.global.DimBackground) then
		SetDressUpAlpha(0.6, 0.6, false);
	else
		SetDressUpAlpha(1.0, 1.0, false);
	end
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
			func = function() Addon.db.global.DimBackground = not Addon.db.global.DimBackground; Addon:ToggleBackgroundDim(); end,
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
			text = " ", isTitle = true, notCheckable = true,
		},
		{
			text = "Character Panel", isTitle = true, notCheckable = true,
		},
		{
			text = "Hide item levels",
			func = function() Addon.db.global.HideItemLevel = not Addon.db.global.HideItemLevel; end,
			checked = function() return Addon.db.global.HideItemLevel end,
			isNotRadio = true,
		},
	};
	
	Addon.ContextMenu:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	EasyMenu(contextMenuData, Addon.ContextMenu, "cursor", 0, 0, "MENU");
	
	DropDownList1:ClearAllPoints();
	DropDownList1:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
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
		SetDressUpBackground(DressUpFrame, raceID);
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
		SetDressUpBackground(DressUpFrame, "Pet");
	else
		SetDressUpBackground(DressUpFrame, RACE_NAMES[RACE_IDS[Addon.CustomBackground]]);
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
		SetDressUpBackground(DressUpFrame, RACE_NAMES[self.value.id]);
	end
	
	UIDropDownMenu_SetText(DressUpRaceDropdown, self.value.name);
	
	Addon:ReapplyPreviewItems();
end

function Addon:GenerateRaceMenu()
	local menu = {};
	
	local factions = {
		[1]	= "Alliance",
		[7] = "Horde",
		[13] = "Neutral",
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
	if(DropDownList1:IsVisible()) then CloseMenus(); return end
	
	PlaySound("igMainMenuOptionCheckBoxOn");
	
	local menudata = Addon:GenerateRaceMenu();
	EasyMenu(menudata, DressUpRaceDropdown, DressUpRaceDropdown, 15, 8);
	DropDownList1:SetWidth(148);
	
	for i=1, 18 do
		_G["DropDownList1Button" .. i]:SetWidth(122);
	end
end

function Addon:InitializeRaceMenu()
	DressUpFrameOutfitDropDown:ClearAllPoints();
	DressUpFrameOutfitDropDown:SetPoint("BOTTOMLEFT", DressUpFrame, "BOTTOMLEFT", 29, 112);
	
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
		if(Addon.ItemButtons[slot].ItemLink) then
			ChatEdit_InsertLink(Addon.ItemButtons[slot].ItemLink)
		end
	elseif(button == "RightButton") then
		Addon:SetButtonItem(slot, nil);
		DressUpModel:UndressSlot(slot);
			
		if(slot == 16 or slot == 17) then
			Addon.WeaponPreviewSlot = 0;
		end
		
		GameTooltip:ClearLines();
		GameTooltip:AddLine(Addon.ItemButtons[slot].SlotName);
		GameTooltip:Show();
	end
end

function DressupPreviewItemButton_OnEnter(self)
	local slot = self:GetID();
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 40);
	
	if(Addon.ItemButtons[slot].ItemLink) then
		GameTooltip:SetHyperlink(Addon.ItemButtons[slot].ItemLink);
	else
		GameTooltip:AddLine(Addon.ItemButtons[slot].SlotName);
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
			ItemLink = nil,
			SlotName = _G[invslot],
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
	if(Addon.db.global.HideTabard) then
		DressUpModel:UndressSlot(19);
	end
	
	if(Addon.db.global.HideWeapons) then
		DressUpModel:UndressSlot(16);
		DressUpModel:UndressSlot(17);
	end
end

function Addon:ResetItemButtons(setEquipment)
	Addon:HideConditionalSlots();
	DressUpFrameOutfitDropDown:SelectOutfit(nil, false);
	
	for slot, button in pairs(Addon.ItemButtons) do
		local itemlink = nil;
		
		if(setEquipment) then
			local skip = false;
			if(slot == 19 and Addon.db.global.HideTabard) then skip = true; end
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

function Addon:InitializeDressUpFrame()
	Addon:HookScript(DressUpFrameResetButton, "OnClick", function()
		Addon:ResetItemButtons(true);
		Addon.WeaponPreviewSlot = 0;
		
		Addon:ResetRaceSelect();
	end);
end

function Addon:InitializePaperDoll()
	Addon.PaperDollOpen = false;
	
	Addon:HookScript(PaperDollFrame, "OnShow", function()
		Addon:PAPERDOLL_OPENED()
	end);
	
	Addon:HookScript(PaperDollFrame, "OnHide", function()
		Addon:PAPERDOLL_CLOSED()
	end);
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
	
	local isTransmogrified, _, _, _, _, hasUndo, isHideVisual = C_Transmog.GetSlotInfo(slot, LE_TRANSMOG_TYPE_APPEARANCE);
	if(not isTransmogrified or isHideVisual) then return nil end
	
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

function Addon:TryOn(displayID, previewSlot, enchantID)
	if(not displayID) then return end
	
	local itemlink;
	if(type(displayID) == "number") then
		-- Get itemlink from source id
		itemlink = Addon:GetItemLinkFromSource(displayID);
	else
		-- Display is probably link
		itemlink = displayID;
	end
	
	local _, _, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(itemlink);
	
	local targetSlotID = previewSlot and GetInventorySlotInfo(previewSlot) or nil;
	if(not targetSlotID) then
		targetSlotID = Addon:GetInvSlot(itemEquipLoc);
	end
	
	-- Don't display hidden cloak
	if(displayID == 77345) then return end
	
	Addon:SetButtonItem(targetSlotID, itemlink);
	
	-- Update weapons separately since in case of dualwielding, blizz preview is all kinds of wonky
	local mainhand = Addon:GetItemSourceID(16);
	local offhand = Addon:GetItemSourceID(17);
	Addon:SetButtonItem(16, Addon:GetItemLinkFromSource(mainhand));
	Addon:SetButtonItem(17, Addon:GetItemLinkFromSource(offhand));
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
	
	Addon.ItemButtons[slot].ItemLink = itemlink;
	
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
		return Addon.ItemButtons[slot].ItemLink;
	end
	
	return nil;
end

function Addon:OnDisable()
		
end

function Addon:PAPERDOLL_OPENED()
	Addon.PaperDollOpen = true;
	Addon:UpdatePaperDollItemLevels();
end

function Addon:PAPERDOLL_CLOSED()
	Addon.PaperDollOpen = false;
end

function Addon:PLAYER_EQUIPMENT_CHANGED(event, slot, hasItem)
	Addon:UpdatePaperDollItemLevels()
end
