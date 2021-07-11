--[[
    TBS Functions.
    Trying to keep main.lua Clean.
]]

TBS.colorise = function(msg)
    return string.gsub(msg, "@%w+@", TBS.colour_codes)
end

TBS.debugprint = function(msg) --Print msg to VO-ChatBox only when debug is on.
    if TBS.debug then
		print(TBS.colorise("@green2@(TBS) Debug: @yellow@"..msg))
    end;
end;

TBS.print = function(msg, color) --Print msg to VO-ChatBox.
    local color = color or "";
    if(color == "") then color = "@white@"; end;
	print(TBS.colorise("@TBS@(TBS) "..color..msg));
end;

--Send msg to server/other pilots.
TBS.SendTBSChatMessage = function(msg, emote)
	local sectorid = -1
	--msg = TCFT2.escapeApostrophes(msg)
	if TBS.Settings.Data.SendLocation == true then
		if GetCurrentSectorid() ~= nil then
			sectorid = GetCurrentSectorid()
		else
			sectorid = -1
		end
	end
    TBS.Proxy.sendChat(msg, sectorid, emote)
end

-- '/TBS say' or '/say_TBS'
TBS.TBSSay = function(data,args)
    local txt = "";
    local isemote = false;
    if(args[1]=="/me")then
        table.remove(args, 1);
        isemote = true;
    end;
	for _,arg in ipairs(args) do
		if(txt~="")then txt = txt .. " " .. arg
		else txt = arg; end;
	end
	TBS.SendTBSChatMessage(txt, isemote);
end

TBS.CleanUp = function() --(!) Interface unloading -- opposite of "PLAYER_ENTERED_GAME";
	TBS.Connection.CleanUp()
end

--[[
	Check Connection status.
	@param [Integer] verbose
	-- 0 Not verbose (silently return connection status).
	-- 1 prints (RED)"Error: Cannot send Data; Not Connected." if not connected
	@returns true/false (not status) else check code.
]]
TBS.isConnected = function(verbose)
	local isConnected = TBS.Connection.isConnected; --true|false;

    if verbose and not isConnected then
        TBS.print("Error: Cannot send data to TBS Server: Not Connected.", TBS.colors.RED)
    end
    return isConnected
end

--[[
	Count the entries of `table`, then return the number.
	@param {Table} table - Table to count.
	@returns {integer} number of entries in `table`.
]]
TBS.tableSize = function(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

--[[
	Iterate through the table and check if it has a specific value.
	@param {Table} tbl - Table to loo kthrough.
	@param {String|Bool|Int} value - value to search for.
	@returns {Boolean} True if the {value} exists within {tbl}, false f it does not.
]]
TBS.tableHasValue = function(tbl, value)
    for k, v in ipairs(tbl) do -- iterate table (for sequential tables only)
        if v == value then
            return true -- Found in this or nested table
        end
    end
    return false -- Not found
end

-- create random string for password
function TBS.RandomString(length)
	if length < 1 then return nil end
	local valChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	length = length or 1
	local array = ""
	for i = 1,length do
		local A = math.random(#valChars)
		array = array..string.sub(valChars,A,A)
	end
	return array
end

-- Player enters game
TBS.EventPlayerEnteredGame = function(_, params)
	if(TBS.IsInitialised)then return end; --Already Init'd....

	--SetShipPurchaseColor(229) --TGFT Green.

	-- Load our settings and login if AutoConnect is ON.
	TBS._Settings("load"):next(function()
		if(TBS.Settings.Data.AutoLogin=="ON")then
			TBS.Connection._Connect()
		end;
	end);

	TBS.IsInitialised = true
end


-- "Online Users" (Members connected to server.)
TBS.OnlineUsers = function(txt)
	TBS.print("*** TBS Users Online: "..txt, TBS.colors.TBS);
end;




TBS.AutoRepair = function()
	if((not TBS.Settings.Data.AutoRepair) or (not HasActiveShip()))then return end;

    RepairShip(GetActiveShipID(), 1)
end;

TBS.AutoReload = function()
	if((not TBS.Settings.Data.AutoReload) or (not HasActiveShip()))then return end;

	for x = 2, GetActiveShipNumAddonPorts()-1, 1 do
		if GetInventoryItemName(GetActiveShipItemIDAtPort(x)) then
			local curAddon, maxAddon= GetAddonItemInfo(GetActiveShipItemIDAtPort(x))
			if current < maximum then
				ReplenishWeapon(GetActiveShipItemIDAtPort(x),maxAddon - curAddon)
			end
		end
	end
end;




TBS.voEvents = TBS.voEvents or {};
voEve = TBS.voEvents;

voEve.EnteredStation = function()
	TBS.AutoRepair(); --Functions
	TBS.AutoReload(); --Functions
end; RegisterEvent(TBS.voEvents.EnteredStation, "ENTERED_STATION");
