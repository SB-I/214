--[[

]]
TBS.Settings = TBS.Settings or {};
TBS.Settings.SaveID = 190419041904;
TBS.Settings.Data = {};

--[[
	Load or Save TBS Settings.
	@param {String} type "Load" or "Save"
]]
TBS._Settings = function(type)
    TBS.print("Running _Settings()", TBS.colors.yellow)
	if not type then return end --We don't know what we're doing....
	local promise = Promise.new()

    if(type=="load")then
        TBS.print("Running _Settings(\"load\")", TBS.colors.yellow)
        TBS.Settings.Data = unspickle(LoadSystemNotes(TBS.Settings.SaveID));
        --[[if(not TBS.Settings.Data)then
            TBS.debugprint("Settings not found; Creating Settings....");
            TBS._Settings("save"):next(function()
                TBS._Settings("load");
            end):next(function()
                TBS.debugprint("Settings Created!")
            end);
        end;]]
        --[[TBS.print("Running _Settings(\"load\") -- Catches", TBS.colors.yellow)
        if(not TBS.Settings.Data)then TBS.print("NO SETTINGS FOUND",TBS.colors.RED); end;
        if(TBS.Settings.Data==nil)then TBS.print("NO SETTINGS FOUND2",TBS.colors.RED); end;
        TBS.print("Running _Settings(\"load\") -- promise:resolve()", TBS.colors.yellow)

        TBS.print("Running _Settings(\"load\") = \""..spickle(TBS.Settings.Data).."\"", TBS.colors.yellow)]]
        if(TBS.Settings.Data)then printtable(TBS.Settings.Data) end;
        if(TBS.Settings.Data)then
            promise:resolve();
        else
            promise.reject();
        end;

		--TCFT2.Settings.Update() ?? ~Spy
--[[
		if(TBS.Settings.Data.SettingsVersion == nil)then
			print("Settings Do Not Exist!!")

			TBS.Settings.Data = TBS.Settings.Default;
			TBS.Settings.Data.SettingsVersion = TBS.Version;

			TBS._Settings("save")
			--:next(
				--TBS._Settings("load")
			--)
		end;]]

		--[[if(TBS.Settings.Data.SettingsVersion ~= TBS.Version)then
			local Data = TBS.Settings.Data;
			for i,v in ipairs(TBS.Settings.Default) do
				if(i=="SettingsVersion")then return; end; --We're updating settings.

				for ii,vv in ipairs(Data) do
					if(i==ii)then return end; --Setting Exists.
					Data[i] = v; --Add Setting.
				end;
			end;
			Data.SettingsVersion = TBS.Version;

			TBS._Settings("save"):next(TBS._Settings("load"))
		end;]]

    elseif(type=="save")then

        TBS.Settings.Data.Username = TBS.Settings.st.Username.value or "";
        TBS.Settings.Data.Password = TBS.Settings.st.Password.value or "";
        TBS.Settings.Data.AutoLogin = TBS.Settings.st.AutoLogin.value or "ON";
        --TBS.Settings.Data.BroadcastArrival = TBS.Settings.st.BroadcastArrival.value or "ON";
        TBS.Settings.Data.SendLocation = TBS.Settings.st.SendLocation.value or "ON";
        --TBS.Settings.Data.AutoRepair = TBS.Settings.st.AutoRepair.value or "ON";
        --TBS.Settings.Data.AutoReload = TBS.Settings.st.AutoReload.value or "ON";
        --TBS.Settings.Data.Spotter_HUD = TBS.Settings.st.Spotter_HUD.value or "ON";
        TBS.Settings.Data.ShowSectorSpots = TBS.Settings.st.ShowSectorSpots.value or "ON";


        TBS.debugprint("Saving Settings:\n"..spickle(TBS.Settings.Data))
        SaveSystemNotes(spickle(TBS.Settings.Data), TBS.Settings.SaveID);
		--return promise:resolve();

    else return; --[[Well... That wasn't a setting....]] end;

    return promise;
end;
