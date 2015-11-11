local ADDON_NAME, SHARED_DATA = ...;

local LibStub = LibStub;
local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceHook-3.0");
local AceDB = LibStub("AceDB-3.0");
_G[ADDON_NAME] = Addon;

local _;

local CLASS_DUALWIELD_ABILITY = {
	["WARRIOR"]	= {
		[0] = false,
		[2] = true,  	-- Fury
	},
	["DEATHKNIGHT"]	= {
		[0] = true,
		[1] = false,
	},
	["PALADIN"]	= {
		[0] = false,
	},
	["MONK"] = {
		[1] = true,		-- Brewmaster
		[2] = false,	-- Mistweaver
		[3] = true,		-- Windwalker
	},
	["PRIEST"] = {
		[0] = false,
	},
	["SHAMAN"] = {
		[0] = false,
		[2] = true,		-- Enhancement
	},
	["DRUID"] = {
		[0] = false,
	},
	["ROGUE"] = {
		[0] = true,
	},
	["MAGE"] = {
		[0] = false,
	},
	["WARLOCK"] = {
		[0] = false,
	},
	["HUNTER"] = {
		[0] = true,
	},
};

function Addon:CanPlayerDualWield()
	local _, class = UnitClass("player");
	local spec = GetSpecialization();
	
	return CLASS_DUALWIELD_ABILITY[class][spec] or CLASS_DUALWIELD_ABILITY[class][0], class == "WARRIOR" and spec == 2;
end

local paperDollSlots = {
	["CharacterHeadSlot"]			= 1,
	["CharacterNeckSlot"]			= 2,
	["CharacterShoulderSlot"]		= 3,
	["CharacterBackSlot"]			= 15,
	["CharacterChestSlot"]			= 5,
	-- ["CharacterShirtSlot"]			= 4,
	-- ["CharacterTabardSlot"]			= 19,
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
	["INVTYPE_WEAPON"] = 16,-- 17,
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
	[1]	= "HEADSLOT",
	[3] = "SHOULDERSLOT",
	[4] = "SHIRTSLOT",
	[5] = "CHESTSLOT",
	[6] = "WAISTSLOT",
	[7] = "LEGSSLOT",
	[8] = "FEETSLOT",
	[9] = "WRISTSLOT",
	[10] = "HANDSSLOT",
	[15] = "BACKSLOT",
	[16] = "MAINHANDSLOT",
	[17] = "SECONDARYHANDSLOT",
	[19] = "TABARDSLOT",
};

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
			-- local _, _, itemRarity, itemLevel = GetItemInfo(link);
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
			HideItemToggle = false,
			
			SaveCustomBackground = false,
			CustomBackground = nil,
		},
	};
	
	self.db = AceDB:New("DressupDB", defaults);
end

local DressUpModelOnEnter = DressUpModel:GetScript("OnEnter");
local DressUpModelOnLeave = DressUpModel:GetScript("OnLeave");

function Addon:OnEnable()
	Addon:RegisterEvent("TRANSMOGRIFY_OPEN");
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
	
	-- DressUpModel:RegisterForClicks("LeftButtonUp", "MiddleButtonUp");
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
			text = "Dim the Preview Background",
			func = function() Addon.db.global.DimBackground = not Addon.db.global.DimBackground; Addon:ToggleBackgroundDim(); end,
			checked = function() return Addon.db.global.DimBackground end,
			isNotRadio = true,
		},
		{
			text = "Save Custom Background",
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
			text = "Hide Model Control Gizmo",
			func = function() Addon.db.global.HideGizmo = not Addon.db.global.HideGizmo; Addon:ToggleGizmo(); end,
			checked = function() return Addon.db.global.HideGizmo end,
			isNotRadio = true,
		},
		{
			text = "Disable Side Panel Preview",
			func = function() Addon.db.global.DisableSidePanel = not Addon.db.global.DisableSidePanel; end,
			checked = function() return Addon.db.global.DisableSidePanel end,
			isNotRadio = true,
		},
		{
			text = " ", isTitle = true, notCheckable = true,
		},
		{
			text = "Character Panel", isTitle = true, notCheckable = true,
		},
		{
			text = "Hide Item Levels",
			func = function() Addon.db.global.HideItemLevel = not Addon.db.global.HideItemLevel; end,
			checked = function() return Addon.db.global.HideItemLevel end,
			isNotRadio = true,
		},
		{
			text = "Hide Helm and Cloak Display Toggle",
			func = function() Addon.db.global.HideItemToggle = not Addon.db.global.HideItemToggle; Addon:UpdateItemToggleVisibility(); end,
			checked = function() return Addon.db.global.HideItemToggle end,
			isNotRadio = true,
		},
	};
	
	Addon.ContextMenu:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
	EasyMenu(contextMenuData, Addon.ContextMenu, "cursor", 0, 0, "MENU");
	
	DropDownList1:ClearAllPoints();
	DropDownList1:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);
end

function Addon:UpdateItemToggleVisibility()
	local visible = not self.db.global.HideItemToggle;
	CharacterHeadSlotToggle:SetShown(visible and GetInventoryItemLink("player", 1) ~= nil);
	CharacterBackSlotToggle:SetShown(visible and GetInventoryItemLink("player", 15) ~= nil);
end

function Addon:ResetRaceSelect()
	local _, raceId = UnitRace("player");

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
		SetDressUpBackground(DressUpFrame, raceId);
	end
	
	UIDropDownMenu_SetText(DressUpRaceDropdown, "Change Preview Race");
end

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

local races = {
	"Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Worgen",
	"Orc", "Undead", "Tauren", "Troll", "Blood Elf", "Goblin",
	"Pandaren",
};

local raceIds = {
	1, 3, 4, 7, 11, 22, 2, 5, 6, 8, 10, 9, 24,
}

local raceNames = {
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

function Addon:GetRaceIndex(raceId)
	for k, id in ipairs(raceIds) do
		if(id == raceId) then return k end
	end
	
	return nil;
end

function Addon:SetCustomBackground(background_id)
	if(not background_id) then return end
	
	if(background_id == 0) then
		SetDressUpBackground(DressUpFrame, "Pet");
	else
		SetDressUpBackground(DressUpFrame, raceNames[raceIds[Addon.CustomBackground]]);
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
				id = raceNames[raceId];
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
		SetDressUpBackground(DressUpFrame, raceNames[self.value.id]);
	end
	
	UIDropDownMenu_SetText(DressUpRaceDropdown, self.value.name);
	
	Addon:ReapplyPreviewItems();
	
	-- SetDressUpBackground(DressUpFrame, "Pet");
	-- UIDropDownMenu_SetSelectedID(DressUpRaceDropdown, self:GetID());
end

function Addon:GenerateRaceMenu()
	local menu = {};
	
	local factions = {
		[1]	= "Alliance",
		[7] = "Horde",
		[13] = "Neutral",
	};
	
	for k, v in ipairs(races) do
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
				id = raceIds[k],
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
	DressUpFrameDescriptionText:Hide();
	DressUpRaceDropdownButton:SetScript("OnClick", DressUpRaceDropdown_OnClick);
	
	UIDropDownMenu_SetWidth(DressUpRaceDropdown, 132);
	UIDropDownMenu_SetButtonWidth(DressUpRaceDropdown, 132);
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

function Addon:ResetItemButtons(setEquipment)
	for slot, button in pairs(Addon.ItemButtons) do
		local link = nil;
		if(setEquipment) then
			local skip = false;
			if(slot == 1 and not ShowingHelm()) then skip = true; end
			if(slot == 15 and not ShowingCloak()) then skip = true; end
			
			if(not skip) then
				link = GetInventoryItemLink("player", slot)
				
				if(link and slot ~= 4 and slot ~= 19) then
					local transmogged, _, _, _, _, visible_id = GetTransmogrifySlotInfo(slot);
					if(transmogged) then
						link = select(2, GetItemInfo(visible_id));
					end
					
					if(link and slot == 16) then
						local invtype = select(9, GetItemInfo(link));
						if(invtype == "INVTYPE_RANGED" or invtype == "INVTYPE_RANGEDRIGHT") then
							link = nil;
							-- DressUpModel:TryOn(link);
						end
					end
				end
			end
		end
		
		Addon:SetButtonItem(slot, link);
	end
end

function Addon:ReapplyPreviewItems()
	DressUpModel:Undress();
	
	for slot=1, 19 do
		-- Hack to force item reset on model
		local inventoryItem = GetInventoryItemLink("player", slot);
		if(inventoryItem) then
			DressUpModel:TryOn(inventoryItem);
		end
		
		-- Refresh the actual preview items
		local item = Addon:GetSlotItem(slot);
		if(item) then
			DressUpModel:TryOn(item);
		else
			DressUpModel:UndressSlot(slot);
		end
	end
	
	DressUpModel:UndressSlot(16);
	DressUpModel:UndressSlot(17);
	
	local emptyMainhand = false;
	local mhweapon = Addon:GetSlotItem(16);
	if(mhweapon) then
		DressUpModel:TryOn(mhweapon);
	else
		emptyMainhand = true;
	end
	
	local ohweapon = Addon:GetSlotItem(17);
	if(ohweapon) then
		DressUpModel:TryOn(ohweapon);
		
		local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(ohweapon);
		if(emptyMainhand and itemEquipLoc ~= "INVTYPE_WEAPONOFFHAND") then
			DressUpModel:TryOn(ohweapon);
			DressUpModel:UndressSlot(16);
		end
	end
end

function DressUpHideTabardButton_OnClick(self)
	DressUpModel:UndressSlot(19);
	Addon:SetButtonItem(19, nil);
end

function DressUpHideArmorButton_OnClick(self)
	DressUpModel:Undress();
	Addon:ResetItemButtons();
end

function Addon:InitializeDressUpFrame()
	
	-- Addon:HookScript(DressUpFrame, "OnShow", function()
	-- 	if(self.db.global.SaveCustomBackground and self.db.global.CustomBackground) then
	-- 		Addon.CustomBackground = self.db.global.CustomBackground;
	-- 		Addon:SetCustomBackground(self.db.global.CustomBackground);
	-- 	end
	-- end);
	-- Addon:HookScript(DressUpFrame, "OnHide", function()
	-- 	Addon:DRESSUP_CLOSED()
	-- end);

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

function Addon:IsSlotTransmogrifiable(slot)
	return slot ~= 4 and slot ~= 19 and slot ~= 2 and slot ~= 11 and slot ~= 12 and slot ~= 13 and slot ~= 14;
end

local _DressUpItemLink = DressUpItemLink;
function DressUpItemLink(link)
	if(not link or not IsDressableItem(link)) then
		return false;
	end
	
	-- Convert itemstrings and item ids to actual links + other info
	local _, link, _, _, _, itemType, itemSubType, _, itemEquipLoc = GetItemInfo(link);
	
	local slot = Addon:GetInvSlot(itemEquipLoc);
	
	if(IsShiftKeyDown() and Addon:IsSlotTransmogrifiable(slot)) then
		local transmogSlot = slot;
		
		local applyTransmog = (link == GetInventoryItemLink("player", transmogSlot));
		if(not applyTransmog and transmogSlot == 16 and link == GetInventoryItemLink("player", 17)) then
			transmogSlot = 17;
			applyTransmog = true;
		end
		
		if(applyTransmog) then
			local transmogged, _, _, _, _, visible_id = GetTransmogrifySlotInfo(transmogSlot);
			if(transmogged) then
				link = select(2, GetItemInfo(visible_id));
			end
		end
	end
	
	if(not Addon.db.global.DisableSidePanel and SideDressUpFrame.parentFrame and SideDressUpFrame.parentFrame:IsShown()) then
		if(not SideDressUpFrame:IsShown() or SideDressUpFrame.mode ~= "player") then
			SideDressUpFrame.mode = "player";
			SideDressUpFrame.ResetButton:Show();

			local race, fileName = UnitRace("player");
			SetDressUpBackground(SideDressUpFrame, fileName);

			ShowUIPanel(SideDressUpFrame);
			SideDressUpModel:SetUnit("player");
		end
		SideDressUpModel:TryOn(link);
		
		return true;
	elseif(not DressUpFrame:IsShown() or DressUpFrame.mode ~= "player") then
		DressUpFrame.mode = "player";
		DressUpFrame.ResetButton:Show();

		local race, fileName = UnitRace("player");
		SetDressUpBackground(DressUpFrame, fileName);

		ShowUIPanel(DressUpFrame);
		Addon:ResetRaceSelect();
		
		Addon:ResetItemButtons(true);
	end
	
	DressUpModel:TryOn(link);
	
	if(slot ~= nil) then
		local canDualWield, hasTitanGrip = Addon:CanPlayerDualWield();
		
		if(slot == 16) then
			local cycle = false;
			if(itemEquipLoc == "INVTYPE_WEAPONMAINHAND") then
				Addon.WeaponPreviewSlot = 0;
			elseif(itemEquipLoc == "INVTYPE_2HWEAPON") then
				if(not hasTitanGrip) then
					Addon.WeaponPreviewSlot = 0;
					Addon:SetButtonItem(17, nil);
				else
					cycle = true;
					-- if(Addon.WeaponPreviewSlot == 1) then
					-- 	Addon:SetButtonItem(16, nil);
					-- end
				end
			elseif(itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_RANGEDRIGHT") then
				Addon.WeaponPreviewSlot = 0;
				Addon:SetButtonItem(17, nil);
			else
				cycle = true;
			end
			
			slot = slot + Addon.WeaponPreviewSlot;
			
			if(cycle and canDualWield) then
				Addon.WeaponPreviewSlot = (Addon.WeaponPreviewSlot + 1) % 2;
			end
		elseif(slot == 17) then
			local currentItemLink, currentItemEquipLoc = Addon:GetSlotItem(16);
			if(currentItemLink) then
				currentItemEquipLoc = select(9, GetItemInfo(currentItemLink));
			end
			-- print(slot, link, currentItemLink, itemEquipLoc, currentItemEquipLoc);
			
			if(itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or itemEquipLoc == "INVTYPE_HOLDABLE") then
				Addon.WeaponPreviewSlot = 0;
				
				if(currentItemEquipLoc == "INVTYPE_2HWEAPON" or
					currentItemEquipLoc == "INVTYPE_RANGED" or
					currentItemEquipLoc == "INVTYPE_RANGEDRIGHT") then
					Addon:SetButtonItem(16, nil);
					Addon:SetButtonItem(17, nil);
				end
			end
		end
		
		Addon:SetButtonItem(slot, link);
	end
	
	return true;
	-- return _DressUpItemLink(link)
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
		-- SetItemButtonTexture(Addon.ItemButtons[slot].Frame, texture);
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
	
	Addon:UpdateItemToggleVisibility();
end

function Addon:PAPERDOLL_CLOSED()
	Addon.PaperDollOpen = false;
end

function Addon:PLAYER_EQUIPMENT_CHANGED(event, slot, hasItem)
	Addon:UpdatePaperDollItemLevels()
	
	if(not Addon.PaperDollOpen) then return end
	
	if(slot == 1) then
		if(hasItem and not self.db.global.HideItemToggle) then
			CharacterHeadSlotToggle:Show();
		else
			CharacterHeadSlotToggle:Hide();
		end
	end
	
	if(slot == 15) then
		if(hasItem and not self.db.global.HideItemToggle) then
			CharacterBackSlotToggle:Show();
		else
			CharacterBackSlotToggle:Hide();
		end
	end
end

function Addon:TRANSMOGRIFY_OPEN()
	TransmogrifyModelFrame:UndressSlot(19);
	
	TransmogrifyFrame:SetSize(550, 500)
	TransmogrifyArtFrame:SetSize(550, 500)
	TransmogrifyModelFrame:SetSize(550, 465)
end