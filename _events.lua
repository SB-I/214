SBCI.Events = SBCI.Events or {};

-- Error Occured Server-Side...
SBCI.Proxy.on("error", function(data)
	SBCI.print("Server Error proccessing request: \""..data.method.."\".\nError Message: \""..data.err.."\"")
end);

-- Failed to login to the server.
SBCI.Proxy.on("badcon", function(data)
	SBCI.print("Server rejected connection with reason: "..data.reason);
	SBCI.Connection.socket.tcp:Disconnect()
end);

-- Logged into the server.
SBCI.Proxy.on("authenticated", function(data)
	--data = {roles=[], onlineUsers=[]};

	if(data['onlineUsers'])then --Receiving list of logged in users
		SBCI.OnlineUsers(data.onlineUsers);
	end;

	if(data['roles'])then
		SBCI.Roles = table.concat(data.roles,", ")
		SBCI.debugprint("Roles Given by server: "..SBCI.Roles)
	end;
end);





SBCI.Proxy.on("broadcast_connect", function(data)
	--data = {username:string};
	local username = data.username;
	if(not username)then return end;
	SBCI.print("*** "..username.." Logged in.",SBCI.colors.SBCI);
end);

SBCI.Proxy.on("broadcast_disconnect", function(data)
	--data = {username:string};
	local username = data.username;
	if(not username)then return end;
	SBCI.print("*** "..username.." Logged out.",SBCI.colors.SBCI);
end);





SBCI.Proxy.on("chat", function(data)
	--data = {name:string, msg:string, faction:integer, channel:int};
	local faction = data.faction or 0 -- for NameColor Devloping.
	local channel = data.channel or 0; -- Channel posting.
	local chatColor = SBCI.colors.channels[channel];

	if faction and faction ~= 0 then
		faction = SBCI.colors.faction[3]
	else
        faction = SBCI.colors.NORMAL
	end

	if channel and channel ~= 0 then
		channel = SBC.channels[channel];
	else
		channel = SBCI.colors.SBCI;
	end;

	SBCI.print(channel.."<"..faction..data.name..chatColor.."> "..data.msg, chatColor);
end);
--SBCI.Proxy.on("chat", function() return; end);


--[[
	data = {
		spots = [{
            name: player.name,
            guild: player.guildtag,
            faction: player.faction,
            ship: player.shipname,
            sectorid: player.sectorid,
        },...
		]
	}
]]
SBCI.Proxy.on("broadcast_spots", function(data)
	for _, spot in ipairs(data.spots) do
		local guild, faction, ship, name, sectorid;
		if(not spot.sectorid)then return end; --No location, no spot.
		if(not spot.name)then return end; --No name, no spot.
		if(spot.guild ~= nil)then guild = "["..spot.guild.."] " else guild = "" end;
		if(spot.ship ~= nil)then ship = spot.ship else ship = "" end;
		if(spot.faction ~= nil)then faction = "{"..spot.faction.."}" else faction = "{-1}" end;

		SBCI.print("Player Spotted: ["..spot.sectorid.."] "..guild..faction..spot.name.." in a "..ship, SBCI.colors.WHITE)
	end;
end);





SBCI.Proxy.on("station_alarms", function(data)
	--data = {guildtag=string, sectorid=integer, msg=string};
	SBCI.print("["..data.guildtag.."] "..data.msg);
end);

SBCI.Proxy.on("keys", function(data)
	--data = {action:"distro", keyid:<int>, list:{owners:[], users:[]}};
	--data = {}; "Ignored"
	--data = {}; "adduser"
	--data = {}; "addowner"
	--data = {}; "removeuser"
	--data = {}; "removeowner"

	local action = data.action;

	if(action=="distro")then
		local keyid, users, owners = data.keyid, data.list.users, data.list.owners;
		if(fn.tableSize(users)>0)then --[[execute userkeys]] end;
		if(fn.tableSize(owners)>0)then --[[execute userkeys]] end;

	elseif(action=="ignore")then--ignore a key.
		GetKeyInfo()GetNumKeysInKeychain()
		for k,v in ipairs(GetNumKeysInKeychain())do
			local key = GetKeyInfo(k);
			printtable(key)
		end;

		--local name = SBCI.vokeys.GetKeySlot(data.keyid);
		--name = name.." (id:"..data.keyid..")";
		local name = params.keyid;
		SBCI.print("(Keys) "..name.." added to the Ignore List.");

	elseif(action=="adduser")then

	elseif(action=="addowner")then

	elseif(action=="removeuser")then

	elseif(action=="removeowner")then

	end;
end);




--[[
	Below are "Server Events".
	These events are private messages between the server and the client.
	Usually pertaining to administration actions, or other notices.
]]

SBCI.Proxy.on("server_notice", function(data)
	--data = {msg:string};

	SBCI.print("<"..SBCI.colors.SBCI.."SBCI"..SBCI.colors.WHITE.."> "..SBCI.colors.SBCI..data.msg, SBCI.colors.WHITE);
end);


SBCI.Proxy.on("server_attacked_stations", function(data)
	--data = {msg:string};

	SBCI.print("<"..SBCI.colors.SBCI.."SBCI"..SBCI.colors.WHITE.."> "..SBCI.colors.INDIAN_RED..data.msg, SBCI.colors.WHITE);
end);
