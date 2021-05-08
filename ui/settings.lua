SBCI.UISettings = {};


function SBCI.UISettings:createUI()
    local container, dialog;
    local p = Promise.new();

    --Our settings.
    SBCI.Settings.st = {};
    local _s = function(state) state = (state==1 and "ON") or "OFF"; return state end;
    -- action=function(self,state) -SBCI.Settings.Data.SETTING_NAME = _s(state) end;

    SBCI.Settings.st.Username = iup.text { value="", expand="YES", size="200x" };
    SBCI.Settings.st.Password = iup.text { value="", expand="YES", size="200x", password="YES" };
    SBCI.Settings.st.AutoLogin = iup.stationtoggle{ value="ON", title="AutoLogin",
        action=function(self,state) SBCI.Settings.Data.AutoLogin = _s(state) end; };
    --SBCI.Settings.st.BroadcastArrival = iup.stationtoggle{ value="ON", title="Broadcast Arrival",
        --action=function(self,state) SBCI.Settings.Data.BroadcastArrival = _s(state) end; };
    SBCI.Settings.st.SendLocation = iup.stationtoggle{ value="ON", title="Send Location",
        action=function(self,state) SBCI.Settings.Data.SendLocation = _s(state) end; };
    --SBCI.Settings.st.AutoRepair = iup.stationtoggle{ value="ON", title="Auto Repair",
        --action=function(self,state) SBCI.Settings.Data.AutoRepair = _s(state) end; };
    --SBCI.Settings.st.AutoReload = iup.stationtoggle{ value="ON", title="Auto Reload",
        --action=function(self,state) SBCI.Settings.Data.AutoReload = _s(state) end; };
    --SBCI.Settings.st.Spotter_HUD = iup.stationtoggle{ value="ON", title="Spotter - HUD",
        --action=function(self,state) SBCI.Settings.Data.Spotter_HUD = _s(state) end; };


    --SBCI.Settings.Help = iup.label{ title="[button]HELP ME!!!!!![/button_LOL]" }

    container = iup.vbox{
        iup.hbox{
			iup.label { title="Settings", font=Font.H1 },
			iup.fill{}
        },
        iup.vbox{
            gap="2",
            iup.hbox{ iup.label{ title="Username:"}, SBCI.Settings.st.Username },
            iup.hbox{ iup.label{ title="Password:"}, SBCI.Settings.st.Password },
            iup.fill{ size="5" },
            SBCI.Settings.st.AutoLogin,
            --SBCI.Settings.st.BroadcastArrival,
            SBCI.Settings.st.SendLocation,
            --SBCI.Settings.st.AutoRepair,
            --SBCI.Settings.st.AutoReload,
            --SBCI.Settings.st.Spotter_HUD,
            iup.fill{ size="5" },
            --SBCI.Settings.Help
        }
    };

    dialog = SBCI.UI.createOkCancelDialog(
        nil,--Blank...
        container,

        function() --"OK"
            SBCI.debugprint("SettingsDialog: OK...");

            SBCI._Settings("save");
            HideDialog(dialog);
        end,

        function() --"CANCEL"
            SBCI.debugprint("SettingsDialog: Cancel...");
            HideDialog(dialog);
        end

    );--dialog = CreateDialog;

    p:resolve(dialog);
    return p;
end;

function SBCI.UISettings:showDialog()
    local fut_dialog = self:createUI()
    self:updateUI();
    fut_dialog:next( function(dialog)
        PopupDialog(dialog, iup.CENTER, iup.CENTER)
    end)
end

function SBCI.UISettings.updateUI()

    SBCI.Settings.st.Username.value = SBCI.Settings.Data.Username or "";
    SBCI.Settings.st.Password.value = SBCI.Settings.Data.Password or "";
    SBCI.Settings.st.AutoLogin.value = SBCI.Settings.Data.AutoLogin or "ON";
    --SBCI.Settings.st.BroadcastArrival.value = SBCI.Settings.Data.BroadcastArrival or "ON";
    SBCI.Settings.st.SendLocation.value = SBCI.Settings.Data.SendLocation or "ON"
    --SBCI.Settings.st.AutoRepair.value = SBCI.Settings.Data.AutoRepair or "ON";
    --SBCI.Settings.st.AutoReload.value = SBCI.Settings.Data.AutoReload or "ON";
    --SBCI.Settings.st.Spotter_HUD.value = SBCI.Settings.Data.Spotter_HUD or "ON";
    ----SBCI.Settings.st.ShowPDAButtons.value = SBCI.Settings.Data.ShowPDAButtons or "ON";
end;
