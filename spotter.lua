--[[


]]
TBS.LastSeen = TBS.LastSeen or {}
TBS.LastSeen.Timer = Timer()
TBS.LastSeen.NotifyTimer = Timer()
TBS.LastSeen.Timeout = 10 -- 15 seconds
TBS.LastSeen.Notifications = {}
TBS.LastSeen.NotifyTimeout = 15 -- 8 seconds

--dofile("ui/ui_lastseen.lua")

TBS.LastSeen.PlayerListCheck = {} -- List of unknown players to check for

-- Check to see if we have any notification to send
TBS.LastSeen.CheckSendData = function()
	local tmplist = {}
	if (#TBS.LastSeen.PlayerListCheck>0) then -- Check if we have any unknowns
		for idx, charid in ipairs(TBS.LastSeen.PlayerListCheck) do
			if (charid>0) then
				local name = GetPlayerName(charid)
				if (name==nil) then -- no name - we just presume he left sector
					TBS.LastSeen.PlayerListCheck[idx] = -1
				else
					if (string.find(name, "reading transponder")==nil) then -- not unknown anymre...
						if (string.sub(name, 1, 1)=="*") then -- No NPC's
							TBS.LastSeen.PlayerListCheck[idx] = -1
						else
							if (GetPlayerName()==name) then -- Not our self
								TBS.LastSeen.PlayerListCheck[idx] = -1
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

								table.insert(tmplist, { name=name, guildTag=guildtag, faction=faction, shipName=shipname, id=charid, --[[standing=standing, stats=stats,]] sectorID=GetCurrentSectorid()})
								TBS.LastSeen.PlayerListCheck[idx] = -1
							end
						end
					end
				end
			else
				TBS.LastSeen.PlayerListCheck[idx] = -1
			end
		end
		local tmp = {}
		for idx, charid in ipairs(TBS.LastSeen.PlayerListCheck) do
			if (charid~=-1) then
				table.insert(tmp, charid)
			end
		end
		TBS.LastSeen.PlayerListCheck = tmp
	end
	if (#tmplist>0) then
		-- TBS.Send({ method="players_spotted", cmd="1250"}, {players=tmplist});
		if(TBS.isConnected(false))then TBS.Proxy.playersSpotted( { players=tmplist } ); end;
	end
	TBS.LastSeen.Timer:SetTimeout(TBS.LastSeen.Timeout*1000, TBS.LastSeen.CheckSendData)
end

-- Check if we have any notifications
TBS.LastSeen.CheckNotify = function()
	local now = os.time()
	for idx, n in ipairs(TBS.LastSeen.Notifications) do
		if(TBS.Settings.HUD.Spotter)then
			if (n.label==nil) then
				n.label = iup.label{title=n.txt, font=Font.H3*HUD_SCALE, alignment="ACENTER", expand="HORIZONTAL"}
				iup.Append(TBS.LastSeen.NotifyBox, n.label)
                --TBS.AddStatus(TBS.colors.green2 .. "(TBS) " .. n.txt, true)
                TBS.print(n.txt)
			end
		end
		if (now - n.time > TBS.LastSeen.NotifyTimeout) then
			if (n.label~=nil) then
				iup.Detach(n.label)
				iup.Destroy(n.label)
			end
			n.txt = nil
		end
	end
	local tmp = {}
	for _, n in ipairs(TBS.LastSeen.Notifications) do
		if (n.txt~=nil) then table.insert(tmp, n) end
	end
	TBS.LastSeen.Notifications = tmp
	if (TBS.LastSeen.NotifyBox2~=nil) then
		TBS.LastSeen.NotifyBox2.visible = (#TBS.LastSeen.Notifications>0 and "YES") or "NO"
	end
	TBS.LastSeen.NotifyTimer:SetTimeout(1000, TBS.LastSeen.CheckNotify)
end

-- Event
TBS.LastSeen.EventPlayerEnteredSector = function(_, charid)
	table.insert(TBS.LastSeen.PlayerListCheck, charid)
end

-- Check to see if anybody in the bar when you dock
TBS.LastSeen.EventPlayerEnteredStation = function(_, params)
	if (PlayerInStation()) then
		local inbar = GetBarPatrons()
		for idx, charid in ipairs(inbar) do
			table.insert(TBS.LastSeen.PlayerListCheck, charid)
		end
	end
end

-- Event
TBS.LastSeen.EventHudShow = function()
	print("EVENT_HUD_SHOW")
	-- TBS.LastSeen.Notify = TBS.LastSeen.Notify or iup.label{title="TEST", font=Font.H4*HUD_SCALE, alignment="ACENTER", expand="HORIZONTAL"}
	if (TBS.LastSeen.NotifyBox==nil) then
		print("LASTSEEN.NOTIFYBOX == nil")
		TBS.LastSeen.NotifyBox = iup.vbox { margin="8x4", expand="YES", alignment="ACENTER" }
		TBS.LastSeen.NotifyBox2 = iup.vbox {
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
								TBS.LastSeen.NotifyBox,
							},
						},
					},
				},
				iup.fill {},
			},
			alignment="ACENTER",
			gap=2
		}
		--if(TBS.Settings.Data.HUD_Spotter) then iup.Append(HUD.pluginlayer, TBS.LastSeen.NotifyBox2) end
		TBS.LastSeen.NotifyTimer:SetTimeout(1000, TBS.LastSeen.CheckNotify)
	end
end

TBS.LastSeen.EventSectorChanged = function(_, data)
	-- Add all players in sector to lastseen
	TBS.__PlayersInSector = {};
	ForEachPlayer(
		function (charid)
			if (charid~=0) then
				table.insert(TBS.LastSeen.PlayerListCheck, {charid, {status = nil, pStatus = nil}})
			end
		end
	)
end

TBS.LastSeen.Timer:SetTimeout(TBS.LastSeen.Timeout*1000, TBS.LastSeen.CheckSendData)

RegisterEvent(TBS.LastSeen.EventPlayerEnteredSector, "PLAYER_ENTERED_SECTOR")
RegisterEvent(TBS.LastSeen.EventPlayerEnteredStation, "ENTERED_STATION")
RegisterEvent(TBS.LastSeen.EventSectorChanged, "SECTOR_CHANGED")
RegisterEvent(TBS.LastSeen.EventHudShow, "PLAYER_ENTERED_GAME")


TBS.UpdateHUD = function()
	--data = {};
	local targetName = GetTargetInfo();
	local targetID = GetCharacterIDByName(targetName);

	if(targetID == nil)then return end; --We don't care about bots...
	local target = nil;
	for PlayerID, statuses in pairs(TBS.__PlayersInSector) do
		--[[
			TBS.__PlayersInSector = [
				999999 = { status = int, pStatus = int }, ....
			];
		]]
		if targetID == PlayerID then
			target = statuses

			break
		end
	end

	if(not target)then return end; --We don't have any statuses.

	if((target['status'] == nil) and (target['pStatus'] == nil))then return end;

	local targetColor = nil;
	local status = "";
	local pStatus = nil;

	if((target['status'] ~= nil) and (TBS.standings[target.status]))then
		status = TBS.colors.standings[target.status]..TBS.standings[target.status];
		targetColor = TBS.colors.radar[target.status];
	end;

	if((target['pStatus'] ~= nil) and (TBS.standings[target.pStatus]))then
		pStatus = TBS.colors.standings[target.pStatus]..TBS.standings[target.pStatus];
	end;

	--HUD.scaninfo.title = HUD.scaninfo.title .. status;
	--HUD.scaninfo.font = "19"
	HUD:PrintSecondaryMsg(status)
	if(pStatus ~= nil)then HUD:PrintSecondaryMsg(pStatus.."\127o") end;

	if(targetColor ~= nil)then radar.SetSelColor(targetColor[1], targetColor[2], targetColor[3]) end;
end

RegisterEvent(TBS.UpdateHUD, "TARGET_CHANGED")
