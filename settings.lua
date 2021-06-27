--[[

]]
SBCI.Settings = SBCI.Settings or {};
SBCI.Settings.SaveID = 190419041904;
SBCI.Settings.Data = {};

--[[
	Load or Save SBCI Settings.
	@param {String} type "Load" or "Save"
]]
SBCI._Settings = function(type)
    SBCI.print("Running _Settings()", SBCI.colors.YELLOW)
	if not type then return end --We don't know what we're doing....
	local promise = Promise.new()

    if(type=="load")then
        SBCI.print("Running _Settings(\"load\")", SBCI.colors.YELLOW)
        SBCI.Settings.Data = unspickle(LoadSystemNotes(SBCI.Settings.SaveID));
        --[[if(not SBCI.Settings.Data)then
            SBCI.debugprint("Settings not found; Creating Settings....");
            SBCI._Settings("save"):next(function()
                SBCI._Settings("load");
            end):next(function()
                SBCI.debugprint("Settings Created!")
            end);
        end;]]
        --[[SBCI.print("Running _Settings(\"load\") -- Catches", SBCI.colors.YELLOW)
        if(not SBCI.Settings.Data)then SBCI.print("NO SETTINGS FOUND",SBCI.colors.RED); end;
        if(SBCI.Settings.Data==nil)then SBCI.print("NO SETTINGS FOUND2",SBCI.colors.RED); end;
        SBCI.print("Running _Settings(\"load\") -- promise:resolve()", SBCI.colors.YELLOW)

        SBCI.print("Running _Settings(\"load\") = \""..spickle(SBCI.Settings.Data).."\"", SBCI.colors.YELLOW)]]
        if(SBCI.Settings.Data)then printtable(SBCI.Settings.Data) end;
        if(SBCI.Settings.Data)then
            promise:resolve();
        else
            promise.reject();
        end;

		--TCFT2.Settings.Update() ?? ~Spy
--[[
		if(SBCI.Settings.Data.SettingsVersion == nil)then
			print("Settings Do Not Exist!!")

			SBCI.Settings.Data = SBCI.Settings.Default;
			SBCI.Settings.Data.SettingsVersion = SBCI.Version;

			SBCI._Settings("save")
			--:next(
				--SBCI._Settings("load")
			--)
		end;]]

		--[[if(SBCI.Settings.Data.SettingsVersion ~= SBCI.Version)then
			local Data = SBCI.Settings.Data;
			for i,v in ipairs(SBCI.Settings.Default) do
				if(i=="SettingsVersion")then return; end; --We're updating settings.

				for ii,vv in ipairs(Data) do
					if(i==ii)then return end; --Setting Exists.
					Data[i] = v; --Add Setting.
				end;
			end;
			Data.SettingsVersion = SBCI.Version;

			SBCI._Settings("save"):next(SBCI._Settings("load"))
		end;]]

    elseif(type=="save")then

        SBCI.Settings.Data.Username = SBCI.Settings.st.Username.value or "";
        SBCI.Settings.Data.Password = SBCI.Settings.st.Password.value or "";
        SBCI.Settings.Data.AutoLogin = SBCI.Settings.st.AutoLogin.value or "ON";
        --SBCI.Settings.Data.BroadcastArrival = SBCI.Settings.st.BroadcastArrival.value or "ON";
        SBCI.Settings.Data.SendLocation = SBCI.Settings.st.SendLocation.value or "ON";
        --SBCI.Settings.Data.AutoRepair = SBCI.Settings.st.AutoRepair.value or "ON";
        --SBCI.Settings.Data.AutoReload = SBCI.Settings.st.AutoReload.value or "ON";
        --SBCI.Settings.Data.Spotter_HUD = SBCI.Settings.st.Spotter_HUD.value or "ON";


        SBCI.debugprint("Saving Settings:\n"..spickle(SBCI.Settings.Data))
        SaveSystemNotes(spickle(SBCI.Settings.Data), SBCI.Settings.SaveID);
		--return promise:resolve();

    else return; --[[Well... That wasn't a setting....]] end;

    return promise;
end;
