local function CheckAPsInUI(event) -- Basically used to create an event in the server when characters use APs or have APs added
    if (event.UI.AnchorObjectName == "statusConsole" or event.UI.AnchorObjectName == "bottomBar_c1") and event.Function == "setAvailableAp" and event.When == "Before" then
        Ext.Net.PostMessageToServer("ANAET_CharacterAPsChanged", "")
    end
end
Ext.Events.UIInvoke:Subscribe(CheckAPsInUI)
