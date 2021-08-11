TBS.UI = TBS.UI or {};

TBS.UI.Main_Status = TBS.colorise("@yellow@Status: Prototype")


TBS.UI.Main_ChatTab = iup.vbox { iup.label {title="CHAT TAB" } }
TBS.UI.Main_ChatTab.tabtitle = "CHAT"

TBS.UI.Main_GuildTab = iup.vbox { iup.label {title="Guild TAB" } }
TBS.UI.Main_GuildTab.tabtitle = "GUILD"

TBS.UI.Main_TBSTab = iup.vbox { iup.label {title="TBS TAB" } }
TBS.UI.Main_TBSTab.tabtitle = "TBS"


TBS.UI.Main_Tabs = TBS.UIMain_Tabs or iup.pda_sub_tabs {
    TBS.UI.Main_ChatTab,
    TBS.UI.Main_GuildTab,
    TBS.UI.Main_TBSTab,
    tabchange_cb = function(self, newtab, oldtab)
		if (oldtab.OnDeactivate) then
			oldtab:OnDeactivate(newtab, oldtab)
		end
		if (newtab.OnActivate) then
			newtab:OnActivate(newtab, oldtab)
		end
		--TCFT2.CurMainTab = newtab

        --print("oldTab: "..oldtab.title)
        print("newTab: "..newtab.tabtitle)
	end,
};


TBS.UI.Main_Callbacks = {};
TBS.UI.Main_Callbacks.show = function(self)
    if (GetCurrentStationType()~=1 and PlayerInStation()) then
        HideDialog(StationDialog)
    end
    --[[
    -- Update systems dropdown
    TCFT2.Mining.MineralSearch.SearchSystem[1] = "Current sector"
    for i=1,#TCFT2.SystemNames do
        TCFT2.Trading.LookupSystem[i+1] = TCFT2.SystemNames[i]
        TCFT2.Mining.MiningMap.LookupSystem[i] = TCFT2.SystemNames[i]
        TCFT2.Mining.MineralSearch.SearchSystem[i+1] = TCFT2.SystemNames[i]
    end]]
end;

TBS.UI.Main_Callbacks.hide = function(self)
    if (GetCurrentStationType()~=1 and PlayerInStation()) then
        ShowDialog(StationDialog)
    end
    --ProcessEvent("TCFT2_HIDE")
end;


TBS.UI.Main_Buttons = {};
TBS.UI.Main_Buttons.size = tostring(Font.Default*5).."x";

TBS.UI.Main_Buttons.connect = iup.stationbutton {
    title = "Connect",
    size = TBS.UI.Main_Buttons.size,
    action = function()
        print("tbs.button['connect']");
        
        if(not TBS.Connection.isConnected)then
            TBS.Connection._Connect();
        else
            TBS.Connection.CleanUp() --close connection.
        end;
    end,
};

TBS.UI.Main_Buttons.close = iup.stationbutton {
    title = "Close",
    size = TBS.UI.Main_Buttons.size,
    action = function()
        print("tbs.button['close']")
        HideDialog(TBS.UI.MainWindow)
    end,
};

TBS.UI.Main_Buttons.reload = iup.stationbutton {
    title = "Reload",
    size = TBS.UI.Main_Buttons.size,
    action = function()
        print("tbs.button['reload']")
        TBS.CleanUp():next(function()
            ReloadInterface()
        end)
    end,
};

TBS.UI.Main_Buttons.settings = iup.stationbutton {
    title = "Settings",
    size = TBS.UI.Main_Buttons.size,
    action = function()
        print("tbs.button['settings']")
        HideDialog(TBS.UI.MainWindow)
        ShowDialog(TBS.UISettings:showDialog());
    end,
};

TBS.UI.Main_Buttons.registerUser = iup.stationbutton {
    title = "TBS Register",
    size = TBS.UI.Main_Buttons.size,
    action = function()
        print("tbs.button['tbs_register']")
        HideDialog(TBS.UI.MainWindow)
        ShowDialog(TBS.UIRegisterUser:showDialog());
    end,
};

TBS.UI.Main_Buttons.statusUpdate = iup.stationbutton {
    title = "TBS Status",
    size = TBS.UI.Main_Buttons.size,
    action = function()
        print("tbs.button['tbs_status']")
        HideDialog(TBS.UI.MainWindow)
        ShowDialog(TBS.UIStatus:showDialog());
    end,
};

TBS.UI.Show_MainWindow = function()

    TBS.UI.MainButtons = TBS.UI.MainButtons or iup.vbox {
        iup.hbox {
            iup.fill {},
            TBS.UI.Main_Buttons.registerUser,
            iup.fill { size="3" },
            TBS.UI.Main_Buttons.statusUpdate,
        },
        iup.hbox {
            iup.vbox {
                iup.fill { size="%1" },
                iup.label { title=TBS.UI.Main_Status, expand="HORIZONTAL" },
            },
            iup.fill {},
            TBS.UI.Main_Buttons.connect,
            iup.fill { size="3" },
            TBS.UI.Main_Buttons.settings,
            iup.fill { size="3" },
            TBS.UI.Main_Buttons.reload,
            iup.fill { size="3" },
            TBS.UI.Main_Buttons.close,
        },
    };


    local container = {};
    container = iup.vbox {
        iup.vbox {
            alignment="ACENTER",
            iup.fill { size="3" },
            iup.label { title=TBS.colorise("@TBS@2 1 4   -   T B S"), expand="HORIZONTAL", alignment="ACENTER" },
        },

        iup.zbox {
            expand="YES",
            all="YES",
            alignment="ACENTER",
            iup.hbox {
                iup.label { title = "", image="plugins/214-tbs/ui/images/214_logo.png" },
            },
            iup.vbox {
                TBS.UI.Main_Tabs,
            },
        },

        iup.hbox {
            margin="3x1",
            expand="YES",
            TBS.UI.MainButtons,
        },
    };


    TBS.UI.MainWindow = TBS.UI.MainWindow or iup.dialog {
        iup.stationhighopacityframe{
            container
        },

        topmost="YES",
        resize="NO",
        fullscreen="YES",
        expand="YES",
        modal="YES",
        border="NO",
        alignment="ATOP",
        bgcolor="30 50 70 150 *",

        defaultesc = TBS.UI.Main_Buttons.close,

		show_cb = TBS.UI.Main_Callbacks.show(),
		hide_cb = TBS.UI.Main_Callbacks.hide(),
    };


    PopupDialog(TBS.UI.MainWindow, iup.CENTER, iup.CENTER);
end;
