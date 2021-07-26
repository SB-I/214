
TBS.Proxy.on("broadcast_connect", function(data)
	--data = {username:string};
	local username = data.username;
	if(not username)then return end;
	TBS.print("*** "..username.." Logged in.",TBS.colors.TBS);
end);


TBS.Proxy.on("broadcast_disconnect", function(data)
	--data = {username:string};
	local username = data.username;
	if(not username)then return end;
	TBS.print("*** "..username.." Logged out.",TBS.colors.TBS);
end);


TBS.Proxy.on("chat_msg", function(data)
	--data = {name:string, msg:string, faction:integer, channel:int};
	local faction = data.faction or 0 -- for NameColor Devloping.
	local channel = data.channel or 0; -- Channel posting.
	local chatColor = TBS.colors.channels[channel];

	if faction and faction ~= 0 then
		faction = TBS.colors.faction[3]
	else
        faction = TBS.colors.normal
	end

	if channel and channel ~= 0 then
		channel = SBC.channels[channel];
	else
		channel = TBS.colors.TBS;
	end;

	TBS.print(channel.."<"..faction..data.name..chatColor.."> "..data.msg, chatColor);
end);
--TBS.Proxy.on("chat", function() return; end);


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
TBS.Proxy.on("playersSpotted", function(data)
	for _, player in ipairs(data['players']) do

		local msg, playerColor, locColor, location, name, faction, sectorid, guild, shipname, status, pStatus
        msg = "Player spotted: "
        playerColor =  "";
        locColor = TBS.colors.yellow;
        location = "";
        name = player["name"]
        faction = player["faction"]
        sectorid = player["sectorID"]
        guild = player['guild']
        shipname = player["ship"]
		status = player['status'] or 0;
		pStatus = player['personalStatus'] or "";

		if(name == nil or name == "")then return end; --Bad Spot.

		if(sectorid == GetCurrentSectorid())then

			TBS.__PlayersInSector[GetCharacterIDByName(name)] = { status = status, pStatus = pStatus };
			printtable(TBS.__PlayersInSector)
			--table.concat(TBS.__PlayersInSector, {GetCharacterIDByName(name), {'status':status, 'pStatus':pStatus}});
		end;

		--if(not TBS.Settings.Data.ShowSpots)then return end; --Client doesn't want to see spots.

		if(sectorid ~= nil) and (sectorid > 0)then
			local alignment = TBS.SystemNames_[GetSystemID(sectorid)][3];
			locColor = TBS.colors.faction[alignment] or TBS.colors.TBS;
			location = "["..ShortLocationStr(sectorid).."]";
		end;

		if(faction ~= nil and faction>0)then playerColor = TBS.colors.faction[faction];
		else playerColor = TBS.colors.normal end;

        if guild ~= nil and string.len(guild) > 0 then
			guild = "["..guild.."]"
		end

		if(shipname ~= nil) and (string.len(shipname) > 0)then
			shipname = "Piloting "..Article(shipname)end;

		if(status ~= nil) and (TBS.standings[status])then
			status = TBS.colors.standings[status].."("..TBS.standings[status]..")"
		end

		if((pStatus ~= "") and (pStatus ~= "")) and (TBS.standings[pStatus])then
			pStatus = TBS.colors.standings[pStatus].." (Personal: "..TBS.standings[pStatus]..")"
		end

		msg = string.format("%s%s%s %s %s%s%s %s%s%s", msg, locColor, location, status, playerColor, guild, name, TBS.colors.white, shipname, pStatus);
		TBS.print(msg, TBS.colors.white)
	end
end);

--[[
	data = {
		KosList = [{
			name: string,
			faction: int,
			reason: string
		}]
	}
]]
TBS.Proxy.on("isKoS", function(data)
	for _, player in ipairs(data['KosList']) do
		if(not data['name']) then return end;
		if(not data['faction'])then
			faction = TBS.colors.factions[0]
		else
			faction = TBS.colors.factions[data['faction']]
		end

		TBS.print(faction..data['name']..' @indianRed@is KoS to 214 for: @white@'..data['reason']);
	end
end)



TBS.Proxy.on("station_alarms", function(data)
	--data = {guildtag=string, sectorid=integer, msg=string};
	TBS.print("["..data.guildtag.."] "..data.msg);
end);

TBS.Proxy.on("keys", function(data)
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

		--local name = TBS.vokeys.GetKeySlot(data.keyid);
		--name = name.." (id:"..data.keyid..")";
		local name = params.keyid;
		TBS.print("(Keys) "..name.." added to the Ignore List.");

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

TBS.Proxy.on("server_notice", function(data)
	--data = {msg:string};

	TBS.print("<"..TBS.colors.TBS.."TBS"..TBS.colors.white.."> "..TBS.colors.TBS..data.msg, TBS.colors.white);
end);


TBS.Proxy.on("server_attacked_stations", function(data)
	--data = {msg:string};

	TBS.print("<"..TBS.colors.TBS.."TBS"..TBS.colors.white.."> "..TBS.colors.indianRed..data.msg, TBS.colors.white);
end);
