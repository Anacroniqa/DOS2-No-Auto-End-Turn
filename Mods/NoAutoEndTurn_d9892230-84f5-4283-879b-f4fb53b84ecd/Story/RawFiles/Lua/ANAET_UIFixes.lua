function IsEditor()
    return Ext.Utils.GameVersion() == "v3.6.51.9303"
end

---Returns the currently-controlled character on the client.  
---@param playerIndex integer? Defaults to 1.
---@return EclCharacter|nil
function GetClientCharacter(playerIndex)
if not IsEditor() then
    playerIndex = playerIndex or 1
    local playerManager = Ext.Entity.GetPlayerManager()
    local Character = Ext.ClientEntity.GetCharacter(playerManager.ClientPlayerData[playerIndex].CharacterNetId) ---@type EclCharacter
    return Character
    end
return nil
end

local function InvisibleAP(event) --Hides the "fake" AP in the UI and fixes the movement related tooltips to show info as if the character had 0AP
    local Character = GetClientCharacter()
    if not Character or not Character.InCombat then return end
    local HasFakeAP = Character:GetStatus("ANAET_HasFakeAP") ~= nil
        if HasFakeAP and Character.Stats.CurrentAP == 1 then
        local Paralized = Character:GetStatus("ANAET_Paralize") ~= nil
            if (event.UI.AnchorObjectName == "statusConsole" or event.UI.AnchorObjectName == "bottomBar_c1") and (event.Function == "setAvailableAp" or event.Function == "setActiveAp") and event.When == "Before" then
                event.UI:GetRoot().setAvailableAp(0)
                event.PreventAction(event)
            end
            if Paralized and event.UI.AnchorObjectName == "notification1" and event.Function == "setNotification" and event.When == "Before" then
                event.PreventAction(event)
            end
            if event.UI:GetTypeId() == Ext.UI.TypeID.textDisplay and event.Function == "addText" then
                local Text, MouseX, MouseY = table.unpack(event.Args)
                local StrMovementSpeedIs0 = Ext.L10N.GetTranslatedString("h8c41d755g3d74g4a3dg91f4g3e0724f5af73")
                    if Paralized and string.find(Text, StrMovementSpeedIs0) then
                        local StrYoureOutOfAP = Ext.L10N.GetTranslatedString("ANAET_471gdec0g4e99g8f66g3f1100068fd8")
                        Text = Text:gsub(StrMovementSpeedIs0, StrYoureOutOfAP, 1)
                    end
                    if string.find(Text, "1AP") or string.find(Text, "1PA") or string.find(Text, "1BA") or string.find(Text, "1ОД") or string.find(Text, "1点AP") or string.find(Text, "1點AP") or string.find(Text, "１AP") or string.find(Text, "1 행동점") then
                        local StrNotEnoughAPToReachDestination = Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c")
                        local Text1 = [[<font color="#C80030">]]..Text -- Gives the right colour to the "1AP" text.
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">]]..StrNotEnoughAPToReachDestination..[[</font><br><font color="#C80030"></font>]], 1) --Adds extra text in the right format
                        Text = Text2 --These changes are made in two different steps to avoid changing the distance info that is in the middle
                    end
                event.UI:GetRoot().addText(Text, MouseX, MouseY)
                event:PreventAction()
            end
        end
    end
Ext.Events.UIInvoke:Subscribe(InvisibleAP)

--Can't move: h8533d422g37beg42b0gaa83g437cf4f22abe
--Movement speed is 0.: h8c41d755g3d74g4a3dg91f4g3e0724f5af73
--AP: heb85c676g65fbg4026g89e7gf1bd9e2caa15
--Target receives 1 AP and [2]% damage boost at the cost of [1] Constitution.: hf46f9b97g5f77g464cg894bg9147058b6e46
--Not enough AP to reach destination!: hc8b063d2gca90g457cgb3dcg735eae03b13c