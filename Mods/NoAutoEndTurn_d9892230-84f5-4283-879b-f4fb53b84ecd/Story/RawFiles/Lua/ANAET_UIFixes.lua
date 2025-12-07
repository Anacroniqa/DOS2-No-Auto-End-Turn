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
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "Not enough AP to reach destination!" then --English
                    if Paralized and Text == [[<font color="#C80030">Can't move: Movement Speed is 0.<br></font>]] then
                        Text = Text:gsub("Movement Speed is 0.","You're out of AP!", 1)
                    end
                    if string.find(Text, "1AP") then
                        local Text1 = Text:gsub([[1AP<br><font color="#DBDBDB">]],[[<font color="#C80030">1AP</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">Not enough AP to reach destination!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "¡Sin PA suficientes para llegar al destino!" then --Spanish (Castillian + LATAM)
                    if Paralized and Text == [[<font color="#C80030">No puedes moverte: La velocidad de movimiento es 0<br></font>]] then
                        Text = Text:gsub("La velocidad de movimiento es 0","¡No te quedan PA!", 1)
                    end
                    if string.find(Text, "1PA") then
                        local Text1 = Text:gsub([[1PA<br><font color="#DBDBDB">]],[[<font color="#C80030">1PA</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">¡Sin PA suficientes para llegar al destino!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "PA insuficientes para alcançar destino!" then --Brazilian Portuguese
                    if Paralized and Text == [[<font color="#C80030">Imóvel: Velocidade de Movimento: 0<br></font>]] then
                        Text = Text:gsub("Velocidade de Movimento: 0","Você não tem PA restantes!", 1)
                    end
                    if string.find(Text, "1PA") then
                        local Text1 = Text:gsub([[1PA<br><font color="#DBDBDB">]],[[<font color="#C80030">1PA</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">PA insuficientes para alcançar destino!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "PA insufficienti per raggiungere la destinazione!" then --Italian
                    if Paralized and Text == [[<font color="#C80030">Non puoi muoverti: Velocità di movimento azzerata.<br></font>]] then
                        Text = Text:gsub("Velocità di movimento azzerata.","Non hai più PA!", 1)
                    end
                    if string.find(Text, "1PA") then
                        local Text1 = Text:gsub([[1PA<br><font color="#DBDBDB">]],[[<font color="#C80030">1PA</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">PA insufficienti per raggiungere la destinazione!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "Pas assez de PA pour atteindre la destination !" then --French
                    if Paralized and Text == [[<font color="#C80030">Impossible de bouger : La vitesse de déplacement est égale à 0.<br></font>]] then
                        Text = Text:gsub("La vitesse de déplacement est égale à 0.","Vous n'avez plus aucun PA !", 1)
                    end
                    if string.find(Text, "1PA") then
                        local Text1 = Text:gsub([[1PA<br><font color="#DBDBDB">]],[[<font color="#C80030">1PA</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">Pas assez de PA pour atteindre la destination !</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "Nicht genügend AP zum Erreichen des Ziels!" then --German
                    if Paralized and Text == [[<font color="#C80030">Bewegen nicht möglich: Bewegungstempo: 0.<br></font>]] then
                        Text = Text:gsub("Bewegungstempo: 0.","Sie haben keine AP mehr!", 1)
                    end
                    if string.find(Text, "1AP") then
                        local Text1 = Text:gsub([[1AP<br><font color="#DBDBDB">]],[[<font color="#C80030">1AP</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">Nicht genügend AP zum Erreichen des Ziels!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "Za mało PA, aby dostać się we wskazane miejsce!" then --Polish
                    if Paralized and Text == [[<font color="#C80030">Ruch niemożliwy: Prędkość ruchu wynosi 0.<br></font>]] then
                        Text = Text:gsub("Prędkość ruchu wynosi 0.","Skończyły ci się PA!", 1)
                    end
                    if string.find(Text, "1PA") then
                        local Text1 = Text:gsub([[1PA<br><font color="#DBDBDB">]],[[<font color="#C80030">1PA</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">Za mało PA, aby dostać się we wskazane miejsce!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "Nedostatek AB pro přesun do dané oblasti!" then --Czech
                    if Paralized and Text == [[<font color="#C80030">Nelze se pohybovat: Rychlost pohybu je 0.<br></font>]] then
                            Text = Text:gsub("Rychlost pohybu je 0.","Došly vám BA!", 1)
                    end
                    if string.find(Text, "1BA") then
                        local Text1 = Text:gsub([[1BA<br><font color="#DBDBDB">]],[[<font color="#C80030">1BA</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">Nedostatek AB pro přesun do dané oblasti!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "Недостаточно ОД, чтобы дойти до места!" then --Russian
                    if Paralized and Text == [[<font color="#C80030">Нельзя двигаться: Скорость движения равна нулю.<br></font>]] then
                        Text = Text:gsub("Скорость движения равна нулю.","У вас закончились ОД!", 1)
                    end
                    if string.find(Text, "1ОД") then
                        local Text1 = Text:gsub([[1ОД<br><font color="#DBDBDB">]],[[<font color="#C80030">1ОД</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">Недостаточно ОД, чтобы дойти до места!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "行动点数不足以抵达目的地！" then --Chinese
                    if Paralized and Text == [[<font color="#C80030">无法移动： 原地未动。<br></font>]] then
                        Text = Text:gsub("原地未动。","你没有AP了！", 1)
                    end
                    if string.find(Text, "1点AP") then
                        local Text1 = Text:gsub([[1点AP<br><font color="#DBDBDB">]],[[<font color="#C80030">1点AP</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">行动点数不足以抵达目的地！</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "行動點數不足以抵達目的地！" then --Traditional Chinese
                    if Paralized and Text == [[<font color="#C80030">無法移動： 原地未動。<br></font>]] then
                        Text = Text:gsub("原地未動。","您沒有AP了！", 1)
                    end
                    if string.find(Text, "1點AP") then
                        local Text1 = Text:gsub([[1點AP<br><font color="#DBDBDB">]],[[<font color="#C80030">1點AP</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">行動點數不足以抵達目的地！</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "目標に到達するためのAPが足りない！" then --Japanese
                    if Paralized and Text == [[<font color="#C80030">移動不可： 移動速度が0<br></font>]] then
                        Text = Text:gsub("移動速度が0","AP切れ！", 1)
                    end
                    if string.find(Text, "１AP") then
                        local Text1 = Text:gsub([[１AP<br><font color="#DBDBDB">]],[[<font color="#C80030">１AP</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">目標に到達するためのAPが足りない！</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
                end
                if Ext.L10N.GetTranslatedString("hc8b063d2gca90g457cgb3dcg735eae03b13c") == "목적지에 도달하기 위한 행동력이 충분하지 않습니다!" then --Korean
                    if Paralized and Text == [[<font color="#C80030">이동할 수 없습니다: 이동 속도가 0입니다.<br></font>]] then
                        Text = Text:gsub("이동 속도가 0입니다.","행동 포인트가 부족합니다!", 1)
                    end
                    if string.find(Text, "1 행동점") then
                        local Text1 = Text:gsub([[1 행동점<br><font color="#DBDBDB">]],[[<font color="#C80030">1 행동점</font><br><font color="#DBDBDB">]], 1)
                        local Text2 = Text1:gsub([[</font><br><font color="#C80030"></font>]],[[</font><br><font size="17" color="#FCD203">목적지에 도달하기 위한 행동력이 충분하지 않습니다!</font><br><font color="#C80030"></font>]], 1)
                        Text = Text2
                    end
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