--[[
    SBCI Functions.
    Trying to keep main.lua Clean.
]]

SBCI.debugprint = function(msg) --Print msg to VO-ChatBox only when debug is on.
    if SBCI.debug then
        print(SBCI.colors.GREEN2.."(SBCI) Debug: "..SBCI.colors.YELLOW..msg);
    end;
end;

SBCI.print = function(msg, color) --Print msg to VO-ChatBox.
    local color = color or "";
    if(color == "") then color = SBCI.colors.WHITE; end;
    print(SBCI.colors.SBCI.."(SBCI) "..color..msg);
end;

--Send msg to server/other pilots.
SBCI.SendSBCIChatMessage = function(msg, emote)
	local sectorid = -1
	--msg = TCFT2.escapeApostrophes(msg)
	if SBCI.Settings.Data.SendLocation == true then
		if GetCurrentSectorid() ~= nil then
			sectorid = GetCurrentSectorid()
		else
			sectorid = -1
		end
	end
    SBCI.Proxy.sendChat(msg, sectorid, emote)
end

-- '/SBCI say' or '/say_SBCI'
SBCI.SBCISay = function(data,args)
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
	SBCI.SendSBCIChatMessage(txt, isemote);
end

SBCI.CleanUp = function() --(!) Interface unloading -- opposite of "PLAYER_ENTERED_GAME";
	SBCI.Connection.CleanUp()
end

--[[
	Check Connection status.
	@param [Integer] verbose
	-- 0 Not verbose (silently return connection status).
	-- 1 prints (RED)"Error: Cannot send Data; Not Connected." if not connected
	@returns true/false (not status) else check code.
]]
SBCI.isConnected = function(verbose)
	local isConnected = SBCI.Connection.isConnected; --true|false;

    if verbose and not isConnected then
        SBCI.print("Error: Cannot send data to SBCI Server: Not Connected.", SBCI.colors.RED)
    end
    return isConnected
end

--[[
	Count the entries of `table`, then return the number.
	@param {Table} table - Table to count.
	@returns {integer} number of entries in `table`.
]]
SBCI.tableSize = function(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- create random string for password
function SBCI.RandomString(length)
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
SBCI.EventPlayerEnteredGame = function(_, params)
	if(SBCI.IsInitialised)then return end; --Already Init'd....

	--SetShipPurchaseColor(229) --TGFT Green.

	-- Load our settings and login if AutoConnect is ON.
	SBCI._Settings("load"):next(function()
		if(SBCI.Settings.Data.AutoLogin=="ON")then
			SBCI.Connection._Connect();
		end;
	end);

	SBCI.IsInitialised = true
end


-- "Online Users" (Members connected to server.)
SBCI.OnlineUsers = function(txt)
	SBCI.print("*** SBCI Users Online: "..txt, SBCI.colors.SBCI);
end;
