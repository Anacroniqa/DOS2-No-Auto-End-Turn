local ANAET = {
    TurnCharacter = {};
}

local function StoreTurnCharacter(_Character) --To store the turn character ID
    local CombatID = CombatGetIDForCharacter(_Character)
    if not CombatID or CombatID == 0 then return end
    local Character = Ext.Entity.GetCharacter(_Character)
    local SummonOwner = Ext.Entity.GetCharacter(Character.OwnerCharacterHandle)
    if (Character.IsPlayer or Character.PartyFollower or (Character.Summon and (SummonOwner.IsPlayer or SummonOwner.PartyFollower))) then
        ANAET.TurnCharacter[CombatID] = _Character
    end
end
Ext.Osiris.RegisterListener("ObjectTurnStarted", 1, "after", function(_Character)
    StoreTurnCharacter(_Character)
end)

local function CleanAfterTurn(_Character) --Clean entries and Fake APs after turn and after turn is delayed. The entries thing is done to prevent errors if a character dies while their id is stored
    local CombatID = CombatGetIDForCharacter(_Character)
    local Character = Ext.Entity.GetCharacter(_Character)
    local HasFakeAP = Character:GetStatus("ANAET_HasFakeAP") ~= nil
    local TimeWrapped = Character:GetStatusByType("EXTRA_TURN") ~= nil
    if HasFakeAP then
        if not TimeWrapped then
            CharacterAddActionPoints(_Character, -99) --It is ABSOLUTELY NECESSARY to remove more APs than the character maximum APs to prevent errors with the last character of the round
        else
            CharacterAddActionPoints(_Character, -1) --Necessary for Fane's Time Wrap to work properly
        end
        RemoveStatus(_Character, "ANAET_HasFakeAP")
    end
    if ANAET.TurnCharacter[CombatID] ~= nil then
        ANAET.TurnCharacter[CombatID] = nil
    end
end
Ext.Osiris.RegisterListener("ObjectTurnEnded", 1, "before", function(_Character)
    CleanAfterTurn(_Character)
end)

local function CleanFakeAPAfterCombat(_Character, CombatID) --Clean entries and Fake APs after turn and after turn is delayed. The entries thing is done to prevent errors if a character dies while their id is stored
    local HasFakeAP = HasActiveStatus(_Character, "ANAET_HasFakeAP")
    if HasFakeAP == 1 then
        RemoveStatus(_Character, "ANAET_HasFakeAP")
    end
end
Ext.Osiris.RegisterListener("ObjectLeftCombat", 2, "before", function(_Character, CombatID)
    CleanFakeAPAfterCombat(_Character, CombatID)
end)

local function CleanEntriesAfterCombat(CombatID) -- Clean entries after combat
    if ANAET.TurnCharacter[CombatID] ~= nil then
        ANAET.TurnCharacter[CombatID] = nil
    end
end
Ext.Osiris.RegisterListener("CombatEnded", 1, "after", function(CombatID) 
    CleanEntriesAfterCombat(CombatID)
end)

local function AddAP(CharacterID) --To add 1AP and the needed statuses the first time a character reaches 0AP
    local Character = Ext.Entity.GetCharacter(CharacterID)
        if Character and Character.Stats and Character.Stats.CurrentAP == 0 then
            CharacterAddActionPoints(CharacterID, 1)
            ApplyStatus(CharacterID, "ANAET_HasFakeAP", -1.0, 1, CharacterID);
            if Character.PartialAP == 0.0 then 
                ApplyStatus(CharacterID, "ANAET_Paralize", -1.0, 1, CharacterID);
            end
        end
    end

local function AddAP_HasFakeAP(CharacterID) --To add 1AP and the paralize status (if needed) the second time a character reaches 0AP
    local Character = Ext.Entity.GetCharacter(CharacterID)
        if Character and Character.Stats and Character.Stats.CurrentAP == 0 then
        local Paralized = HasActiveStatus(CharacterID, "ANAET_Paralize")
            CharacterAddActionPoints(CharacterID, 1)
            if Paralized == 0 then
                ApplyStatus(CharacterID, "ANAET_Paralize", -1.0, 1, CharacterID);
            end
        end
    end

local function RemoveFakeAP(CharacterID) --Removes the Fake AP when a status or talent (adrenaline, executioner, etc.) add APs while having 0APs
    local Character = Ext.Entity.GetCharacter(CharacterID)
    local HasFakeAP = Character:GetStatus("ANAET_HasFakeAP") ~= nil
        if Character and Character.Stats and Character.Stats.CurrentAP > 1 and HasFakeAP then
            CharacterAddActionPoints(CharacterID, -1)
            RemoveStatus(CharacterID, "ANAET_HasFakeAP")
        end
    end

local function CheckAPs() --Logic to check characters' APs
    for CombatID, CharacterID in pairs(ANAET.TurnCharacter) do
        if not CharacterID then goto continue end
        if CharacterID == "" or type(CharacterID) ~= "string" then goto continue end
        if CombatGetIDForCharacter(CharacterID) ~= CombatID then goto continue end
        if not ObjectExists(CharacterID) then goto continue end
        local Character = Ext.Entity.GetCharacter(CharacterID)
        if not Character or Character.IsGameMaster or Character.IsPossessed or Character.Stats.CurrentVitality == 0 then goto continue end
            local HasFakeAP = Character:GetStatus("ANAET_HasFakeAP") ~= nil
            local Paralized = Character:GetStatus("ANAET_Paralize") ~= nil
            if Character.Stats.CurrentAP == 0 and not Paralized then
                if HasFakeAP then
                    AddAP_HasFakeAP(CharacterID)
                else
                    AddAP(CharacterID)
                end
            elseif Character.Stats.CurrentAP > 1 and HasFakeAP then
                RemoveFakeAP(CharacterID)
            end
        ::continue::
    end
end
Ext.RegisterNetListener("ANAET_CharacterAPsChanged", CheckAPs)

local function MovementAdjustment(event) --To remove the paralized status and any partial AP the character might have after doing so
    if event.Status.StatusId ~= "ANAET_HasFakeAP" then return end    
    local Character = Ext.Entity.GetCharacter(event.Status.TargetHandle)
    local _Character = Character.MyGuid
    local Paralized = Character:GetStatus("ANAET_Paralize") ~= nil
    if Paralized then
        RemoveStatus(_Character, "ANAET_Paralize")
        if Character.PartialAP ~= 0.0 then 
            Character.PartialAP = 0.0
        end
    end
end
Ext.Events.StatusDelete:Subscribe(MovementAdjustment)