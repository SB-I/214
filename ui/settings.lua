TBS.UISettings = {};


function TBS.UISettings:createUI()
    local container, dialog;
    local p = Promise.new();

    --Our settings.
    TBS.Settings.st = {};
    local _s = function(state) state = (state==1 and "ON") or "OFF"; return state end;
    -- action=function(self,state) -TBS.Settings.Data.SETTING_NAME = _s(state) end;

    TBS.Settings.st.Username = iup.text { value="", expand="YES", size="200x" };
    TBS.Settings.st.Password = iup.text { value="", expand="YES", size="200x", password="YES" };
    TBS.Settings.st.AutoLogin = iup.stationtoggle{ value="ON", title="AutoLogin",
        action=function(self,state) TBS.Settings.Data.AutoLogin = _s(state) end; };
    --TBS.Settings.st.BroadcastArrival = iup.stationtoggle{ value="ON", title="Broadcast Arrival",
        --action=function(self,state) TBS.Settings.Data.BroadcastArrival = _s(state) end; };
    TBS.Settings.st.SendLocation = iup.stationtoggle{ value="ON", title="Send Location",
        action=function(self,state) TBS.Settings.Data.SendLocation = _s(state) end; };
    --TBS.Settings.st.AutoRepair = iup.stationtoggle{ value="ON", title="Auto Repair",
        --action=function(self,state) TBS.Settings.Data.AutoRepair = _s(state) end; };
    --TBS.Settings.st.AutoReload = iup.stationtoggle{ value="ON", title="Auto Reload",
        --action=function(self,state) TBS.Settings.Data.AutoReload = _s(state) end; };
    --TBS.Settings.st.Spotter_HUD = iup.stationtoggle{ value="ON", title="Spotter - HUD",
        --action=function(self,state) TBS.Settings.Data.Spotter_HUD = _s(state) end; };
    TBS.Settings.st.ShowSectorSpots = iup.stationtoggle{ value="ON", title="Show My Spots",
        action=function(self,state) TBS.Settings.st.ShowSectorSpots = _s(state) end; };




    --TBS.Settings.Help = iup.label{ title="[button]HELP ME!!!!!![/button_LOL]" }

    container = iup.vbox{
        iup.hbox{
			iup.label { title="Settings", font=Font.H1 },
			iup.fill{}
        },
        iup.vbox{
            gap="2",
            iup.hbox{ iup.label{ title="Username:"}, TBS.Settings.st.Username },
            iup.hbox{ iup.label{ title="Password:"}, TBS.Settings.st.Password },
            iup.fill{ size="5" },
            TBS.Settings.st.AutoLogin,
            --TBS.Settings.st.BroadcastArrival,
            TBS.Settings.st.SendLocation,
            --TBS.Settings.st.AutoRepair,
            --TBS.Settings.st.AutoReload,
            --TBS.Settings.st.Spotter_HUD,
            TBS.Settings.st.ShowSectorSpots,
            iup.fill{ size="5" },
            --TBS.Settings.Help
        }
    };

    dialog = TBS.UI.createOkCancelDialog(
        nil,--Blank...
        container,

        function() --"OK"
            TBS.debugprint("SettingsDialog: OK...");

            TBS._Settings("save");
            HideDialog(dialog);
        end,

        function() --"CANCEL"
            TBS.debugprint("SettingsDialog: Cancel...");
            HideDialog(dialog);
        end

    );--dialog = CreateDialog;

    p:resolve(dialog);
    return p;
end;

function TBS.UISettings:showDialog()
    local fut_dialog = self:createUI()
    self:updateUI();
    fut_dialog:next( function(dialog)
        PopupDialog(dialog, iup.CENTER, iup.CENTER)
    end)
end

function TBS.UISettings.updateUI()

    TBS.Settings.st.Username.value = TBS.Settings.Data.Username or "";
    TBS.Settings.st.Password.value = TBS.Settings.Data.Password or "";
    TBS.Settings.st.AutoLogin.value = TBS.Settings.Data.AutoLogin or "ON";
    --TBS.Settings.st.BroadcastArrival.value = TBS.Settings.Data.BroadcastArrival or "ON";
    TBS.Settings.st.SendLocation.value = TBS.Settings.Data.SendLocation or "ON"
    --TBS.Settings.st.AutoRepair.value = TBS.Settings.Data.AutoRepair or "ON";
    --TBS.Settings.st.AutoReload.value = TBS.Settings.Data.AutoReload or "ON";
    --TBS.Settings.st.Spotter_HUD.value = TBS.Settings.Data.Spotter_HUD or "ON";
    TBS.Settings.st.ShowSectorSpots.value = TBS.Settings.Data.ShowSectorSpots or "ON"
    ----TBS.Settings.st.ShowPDAButtons.value = TBS.Settings.Data.ShowPDAButtons or "ON";
end;
