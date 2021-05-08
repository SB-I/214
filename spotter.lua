--[[


]]
SBCI.LastSeen = SBCI.LastSeen or {}
SBCI.LastSeen.Timer = Timer()
SBCI.LastSeen.NotifyTimer = Timer()
SBCI.LastSeen.Timeout = 10 -- 15 seconds
SBCI.LastSeen.Notifications = {}
SBCI.LastSeen.NotifyTimeout = 15 -- 8 seconds

--dofile("ui/ui_lastseen.lua")

SBCI.LastSeen.PlayerListCheck = {} -- List of unknown players to check for

-- Check to see if we have any notification to send
SBCI.LastSeen.CheckSendData = function()
	local tmplist = {}
	if (#SBCI.LastSeen.PlayerListCheck>0) then -- Check if we have any unknowns
		for idx, charid in ipairs(SBCI.LastSeen.PlayerListCheck) do
			if (charid>0) then
				local name = GetPlayerName(charid)
				if (name==nil) then -- no name - we just presume he left sector
					SBCI.LastSeen.PlayerListCheck[idx] = -1
				else
					if (string.find(name, "reading transponder")==nil) then -- not unknown anymre...
						if (string.sub(name, 1, 1)=="*") then -- No NPC's
							SBCI.LastSeen.PlayerListCheck[idx] = -1
						else
							if (GetPlayerName()==name) then -- Not our self
								SBCI.LastSeen.PlayerListCheck[idx] = -1
							else
								local faction = GetPlayerFaction(charid) or 0
								local guildtag = GetGuildTag(charid) or ""
								--local health = GetPlayerHealth(charid) or 0.0
								local shipname = GetPrimaryShipNameOfPlayer(charid) or ""
								--[[local standing = {
									itani=0,
									serco=0,
									uit=0,
									_local=0,
								};]]

								--Server logging Data
								--local kills,deaths,pks = GetCharacterKillDeaths(charid);

								--[[local stats = {
									kills=kills,
									deaths=deaths,
									pks=pks,

									licenses = {
										combat=GetLicenseLevel(1,charid),
										light=GetLicenseLevel(2,charid),
										heavy=GetLicenseLevel(3,charid),
										trade=GetLicenseLevel(4,charid),
										mining=GetLicenseLevel(5,charid)
									};
								};]]

								table.insert(tmplist, { name=name, guildtag=guildtag, faction=faction, shipname=shipname, id=charid, --[[standing=standing, stats=stats,]] sectorid=GetCurrentSectorid()})
								SBCI.LastSeen.PlayerListCheck[idx] = -1
							end
						end
					end
				end
			else
				SBCI.LastSeen.PlayerListCheck[idx] = -1
			end
		end
		local tmp = {}
		for idx, charid in ipairs(SBCI.LastSeen.PlayerListCheck) do
			if (charid~=-1) then
				table.insert(tmp, charid)
			end
		end
		SBCI.LastSeen.PlayerListCheck = tmp
	end
	if (#tmplist>0) then
		-- SBCI.Send({ method="players_spotted", cmd="1250"}, {players=tmplist});
		if(SBCI.isConnected(0))then SBCI.Proxy.playersSpotted( { players=tmplist } ); end;
	end
	SBCI.LastSeen.Timer:SetTimeout(SBCI.LastSeen.Timeout*1000, SBCI.LastSeen.CheckSendData)
end

-- Check if we have any notifications
SBCI.LastSeen.CheckNotify = function()
	local now = os.time()
	for idx, n in ipairs(SBCI.LastSeen.Notifications) do
		if(SBCI.Settings.HUD.Spotter)then
			if (n.label==nil) then
				n.label = iup.label{title=n.txt, font=Font.H3*HUD_SCALE, alignment="ACENTER", expand="HORIZONTAL"}
				iup.Append(SBCI.LastSeen.NotifyBox, n.label)
                --SBCI.AddStatus(SBCI.colors.GREEN2 .. "(SBCI) " .. n.txt, true)
                SBCI.print(n.txt)
			end
		end
		if (now - n.time > SBCI.LastSeen.NotifyTimeout) then
			if (n.label~=nil) then
				iup.Detach(n.label)
				iup.Destroy(n.label)
			end
			n.txt = nil
		end
	end
	local tmp = {}
	for _, n in ipairs(SBCI.LastSeen.Notifications) do
		if (n.txt~=nil) then table.insert(tmp, n) end
	end
	SBCI.LastSeen.Notifications = tmp
	if (SBCI.LastSeen.NotifyBox2~=nil) then
		SBCI.LastSeen.NotifyBox2.visible = (#SBCI.LastSeen.Notifications>0 and "YES") or "NO"
	end
	SBCI.LastSeen.NotifyTimer:SetTimeout(1000, SBCI.LastSeen.CheckNotify)
end

-- Event
SBCI.LastSeen.EventPlayerEnteredSector = function(_, charid)
	table.insert(SBCI.LastSeen.PlayerListCheck, charid)
end

-- Check to see if anybody in the bar when you dock
SBCI.LastSeen.EventPlayerEnteredStation = function(_, params)
	if (PlayerInStation()) then
		local inbar = GetBarPatrons()
		for idx, charid in ipairs(inbar) do
			table.insert(SBCI.LastSeen.PlayerListCheck, charid)
		end
	end
end

-- Event
SBCI.LastSeen.EventHudShow = function()
	print("EVENT_HUD_SHOW")
	-- SBCI.LastSeen.Notify = SBCI.LastSeen.Notify or iup.label{title="TEST", font=Font.H4*HUD_SCALE, alignment="ACENTER", expand="HORIZONTAL"}
	if (SBCI.LastSeen.NotifyBox==nil) then
		print("LASTSEEN.NOTIFYBOX == nil")
		SBCI.LastSeen.NotifyBox = iup.vbox { margin="8x4", expand="YES", alignment="ACENTER" }
		SBCI.LastSeen.NotifyBox2 = iup.vbox {
			visible="NO",
			iup.fill { size="%69" },
			iup.hbox {
				iup.fill {},
				iup.hudrightframe {
					border="2 2 2 2",
					iup.vbox {
						expand="NO",
						iup.hudrightframe {
							border="0 0 0 0",
							iup.hbox {
								SBCI.LastSeen.NotifyBox,
							},
						},
					},
				},
				iup.fill {},
			},
			alignment="ACENTER",
			gap=2
		}
		--if(SBCI.Settings.Data.HUD_Spotter) then iup.Append(HUD.pluginlayer, SBCI.LastSeen.NotifyBox2) end
		SBCI.LastSeen.NotifyTimer:SetTimeout(1000, SBCI.LastSeen.CheckNotify)
	end
end

SBCI.LastSeen.EventSectorChanged = function(_, data)
	-- Add all players in sector to lastseen
	ForEachPlayer(
		function (charid)
			if (charid~=0) then table.insert(SBCI.LastSeen.PlayerListCheck, charid) end
		end
	)
end

SBCI.LastSeen.Timer:SetTimeout(SBCI.LastSeen.Timeout*1000, SBCI.LastSeen.CheckSendData)

RegisterEvent(SBCI.LastSeen.EventPlayerEnteredSector, "PLAYER_ENTERED_SECTOR")
RegisterEvent(SBCI.LastSeen.EventPlayerEnteredStation, "ENTERED_STATION")
RegisterEvent(SBCI.LastSeen.EventSectorChanged, "SECTOR_CHANGED")
RegisterEvent(SBCI.LastSeen.EventHudShow, "PLAYER_ENTERED_GAME")
