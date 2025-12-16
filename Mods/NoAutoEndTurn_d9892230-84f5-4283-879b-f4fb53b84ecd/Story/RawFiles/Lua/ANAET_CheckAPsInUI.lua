local function CheckAPsInUI(event) -- Basically used to create an event in the server when characters use APs or have APs added
    if (event.UI:GetTypeId() == Ext.UI.TypeID.statusConsole or event.UI:GetTypeId() == Ext.UI.TypeID.bottomBar_c) and event.Function == "setAvailableAp" and event.When == "Before" then
        Ext.Net.PostMessageToServer("ANAET_CharacterAPsChanged", "")
    end
end
Ext.Events.UIInvoke:Subscribe(CheckAPsInUI)

--117 is the id for statusConsole
--59 is the id for bottomBar_c