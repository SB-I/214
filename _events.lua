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





SBCI.Proxy.on("chat_msg", function(data)
	--data = {name:string, msg:string, faction:integer};
	local faction = data.faction or 0 -- for NameColor Devloping.

	if faction and faction ~= 0 then
		faction = SBCI.colors.faction[3]
	else
        faction = SBCI.colors.NORMAL
	end

	SBCI.print("<"..data.name..SBCI.colors.SBCI.."> "..data.msg, faction);
end);
SBCI.Proxy.on("chat", function() return; end);


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
	for _, player in ipairs(data['spots']) do

		local msg, playerColor, locColor, location, name, faction, sectorid, guild, shipname
        msg = "Player spotted: "
        playerColor =  "";
        locColor = SBCI.colors.YELLOW;
        location = "";
        name = player["name"]
        faction = player["faction"]
        sectorid = player["sectorid"]
        guild = player['guild']
        shipname = player["ship"]

		if(name == nil or name == "")then return end; --Bad Spot.
		if(sectorid == GetCurrentSectorid() or sectorid == nil)then return end; --Same location.

		if(sectorid ~= nil) and (sectorid > 0)then
			local alignment = SBCI.SystemNames_[GetSystemID(sectorid)][3];
			locColor = SBCI.colors.faction[alignment] or SBCI.colors.SBCI;
			location = "["..ShortLocationStr(sectorid).."]";
		end;

		if(faction ~= nil and faction>0)then playerColor = SBCI.colors.faction[faction];
		else playerColor = SBCI.colors.NORMAL end;

        if guild ~= nil and string.len(guild) > 0 then
			guild = "["..guild.."]" end

		if(shipname ~= nil) and (string.len(shipname) > 0)then
			shipname = "Piloting "..Article(shipname)end;

			msg = string.format("%s%s%s %s%s%s %s%s", msg, locColor, location, playerColor, guild, name, SBCI.colors.WHITE, shipname);
			SBCI.print(msg, SBCI.colors.WHITE)
	end
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
