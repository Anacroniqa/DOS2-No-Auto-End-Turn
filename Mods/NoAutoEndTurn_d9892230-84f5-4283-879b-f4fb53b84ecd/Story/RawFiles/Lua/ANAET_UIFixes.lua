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
            --Hide the Fake AP in the UI:
            if (event.UI:GetTypeId() == Ext.UI.TypeID.statusConsole or event.UI:GetTypeId() == Ext.UI.TypeID.bottomBar_c) and (event.Function == "setAvailableAp" or event.Function == "setActiveAp") and event.When == "Before" then
                event.UI:GetRoot().setAvailableAp(0)
                event.PreventAction(event)
            end
            --Prevent the notification informing you that your movement speed is 0 from popping up when the Paralized status is applied:
            if Paralized and event.UI:GetTypeId() == Ext.UI.TypeID.notification and event.Function == "setNotification" and event.When == "Before" then
                event.PreventAction(event)
            end
            --Fixes to the mouse movement tooltips: 
            if event.UI:GetTypeId() == Ext.UI.TypeID.textDisplay and event.Function == "addText" then
                local Text, MouseX, MouseY = table.unpack(event.Args)
                local StrMovementSpeedIs0 = Ext.L10N.GetTranslatedString("h8c41d755g3d74g4a3dg91f4g3e0724f5af73")
                local StrXAP = Ext.L10N.GetTranslatedString("h984df648geba3g4eaagb035g2088d0e58f72")
                    if Paralized and string.find(Text, StrMovementSpeedIs0) then
                        local StrYoureOutOfAP = Ext.L10N.GetTranslatedString("ANAET_471gdec0g4e99g8f66g3f1100068fd8")
                        Text = Text:gsub(StrMovementSpeedIs0, StrYoureOutOfAP, 1) --When you are out of AP and movement, this replaces the text "Movement speed is 0." in "Can't move: Movement speed is 0." with "You're out of AP!"
                    end
                    if string.find(Text, StrXAP) then
                        if string.find(Text, [[</font><br><font color="#C80030"></font>]]) then --Mouse & keyboard UI
                            local StrNotEnoughAPToReachDestination = Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c")
                            local Text1 = [[<font color="#C80030">]]..Text -- Gives the right colour (red) to the "1AP" text.
                            if not string.find(Text, StrNotEnoughAPToReachDestination) then    
                                local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">]]..StrNotEnoughAPToReachDestination..[[</font><br><font color="#C80030"></font>]], 1) --Adds extra text (Not enough AP to reach destination!) to the tooltip in the right format
                                Text = Text2 --These changes are made in two different steps to avoid changing the distance info that is in the middle
                            else
                                Text = Text1
                            end
                        else -- controller UI
                            local StrCantReachDestination = Ext.L10N.GetTranslatedString("ha9156ca2g7912g462cgab60gda4ada5938ce")
                            Text = [[<font color="#C80030">]]..StrCantReachDestination 
                        end
                    end
                event.UI:GetRoot().addText(Text, MouseX, MouseY)
                event:PreventAction()
            end
            --Hides the extra movement tooltip telling you how much you can actually move when you have 0AP, as it gives the info as if you had 1AP. 
            --The proper thing to do would be make the label give the info as if you had 0AP, but I don't know how to get the info regarding your available movement nor the x and y coordinates for the right positioning of the label.
            if event.UI:GetTypeId() == Ext.UI.TypeID.textDisplay and event.Function == "addLabel" then
                local Id, Text, X, Y = table.unpack(event.Args)
                local StrXAP = Ext.L10N.GetTranslatedString("h984df648geba3g4eaagb035g2088d0e58f72")
                if string.find(Text, StrXAP) then
                    event.PreventAction(event) 
                end
            end
        end
    end
Ext.Events.UIInvoke:Subscribe(InvisibleAP)

--Can't move: h8533d422g37beg42b0gaa83g437cf4f22abe
--Movement speed is 0.: h8c41d755g3d74g4a3dg91f4g3e0724f5af73
--[1]AP: h984df648geba3g4eaagb035g2088d0e58f72
--Not enough AP to reach destination!: hc8b063d2gca90g457cgb3dcg735eae03b13c
--Can't reach destination (controller version): ha9156ca2g7912g462cgab60gda4ada5938ce
--1AP variations: 1AP, 1PA, 1BA, 1ОД, 1点AP, 1點AP, １AP, 1 행동점