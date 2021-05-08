SBCI._._.stationAttacks = {};

SBCI._._.stationAttacks.event = function(_,data)
    --data = {msg=string};
    local post = false;
    local params = {
        msg=data.msg,
        sectorid=-1
    };
    if(data.msg == "Your station in Latos I-8 is under attack!")then
        --I-8 --stationid=1472769 --name="CONQURABLE STATION"
        --sectorid = 5753
        params.sectorid=5753; post = true;
    elseif(data.msg == "Your station in Pelatus C-12 is under attack!")then
        --C-12 --stationid=1028865 --name="Pelatus Mining Station"
        --sectorid=4019
        params.sectorid=4019; post = true;
    elseif(data.msg == "Your station in Bractus M-14 is under attack!")then
        --M-14 --stationid=1105153 --name="Bractus IX Planetary Outpost"
        --sectorid=4317
        params.sectorid=4317; post = true;
    else
        return;
    end;
    if(post)then SBCI.Proxy._notify("station_alarms",params); end;
end;

RegisterEvent(SBCI._._.stationAttacks.event, "CHAT_MSG_SERVER");


-------------------------------------------------------
-- Get Keys in your keychain
-------------------------------------------------------
function SBCI._._.stationAttacks.Get_Keychain()
    if SBCI.debug then SBCI.debugprint("tgft is calling the get key routine.") end
    SBCI._._.stationAttacks.keys = {}
    for v = 1, GetNumKeysInKeychain(), 1 do
        local keyid, description, owner, timestamp, access, possessors, active = GetKeyInfo(tonumber(v))
        local key_data = {}
        if active then -- Only active keys have possessor tables...
            Keychain.list(keyid,
                function(isError, message)
                if (isError) then
                    SBCI.print("KEY ERROR:",SBCI.colors.RED)
                else
                    keyid, description, owner, timestamp, access, possessors, active = GetKeyInfo(tonumber(v))
                end
            end)
            local key_data = {ID = keyid, DESC = description, OWN = owner, ACTIVE = active, ACCESS = access, POSS = possessors }
            table.insert(SBCI._._.stationAttacks.keys,key_data)
        end
    end
end
--[[
    GetKeyInfo(KEY INDEX)
    keyid = 3384
    description = "SBI   CapShips"
    owner = 3383
    timestamp = 512421985829
    access = TABLE
    ** TABLE
    ** ** TABLE
    ** ** ** station = int
    ** ** ** name = string
    ** ** TABLE
    ** ** ** candock = boolean
    ** ** ** itemid = integer (always "0"??) -- only on capship keys....
    ** ** ** iff = boolean
    ... (Repeat Per "Station Access")
    possessors = TABLE
    active = boolean
]]


-------------------------------------------------------
-- Get a keys index number
-------------------------------------------------------
function SBCI._._.stationAttacks.GetKeyIndex(x)
	for i = 1, GetNumKeysInKeychain(), 1 do
		local keyid, description, owner, timestamp, access, possessors, active = GetKeyInfo(tonumber(i))
		if (tonumber(keyid) == tonumber(x)) then return i end
	end
    return -1 -- Not found in the list
end


-------------------------------------------------------
-- Verify Key when you enter systems
-------------------------------------------------------
function SBCI._._.stationAttacks.VerifyDestination()
	local destsector = NavRoute.GetNextHop()
	if not destsector then return end
	local stationname = "None"
	if destsector==4019 then stationname = "Pelatus Mining Station" end
	if destsector==4317 then stationname = "Bractus IX Planetary Outpost" end
	if destsector==5753 then stationname = "CONQUERABLE STATION" end
	--SBCI._._.stationAttacks.Sector_Verified()
	if stationname == "None" then return end -- Normal sectors... just return
  	if SBCI.debug then SBCI.debugprint("Verify Key for Sector:"..destsector) end

	for i = 1, #SBCI._._.stationAttacks.keys, 1 do
		local keyid, description, owner, timestamp, access, possessors, active =
			GetKeyInfo(tonumber(tgft.GetKeyIndex(SBCI._._.stationAttacks.keys[i]["ID"])))
		if access then
			for j = 1, # access, 1 do
				if (access[j][1].name==stationname) then
					if (access[j][2].candock) and (access[j][2].iff)then return end
				end
			end
		end
	end
	SBCI.print("\127ff1010-- WARNING -- Key is NOT VALID for: "..stationname, SBCI.colors.RED)
end


-------------------------------------------------------
-- Verify faction standing before jumping to systems
-------------------------------------------------------
function SBCI._._.stationAttacks.Sector_Verified()
	local destsector = NavRoute.GetNextHop()
  	if SBCI.debug then SBCI.debugprint("Verify standing at Destination Sector:"..destsector) end
	local systemid = GetSystemID(destsector)
  	if SBCI.debug then SBCI.debugprint("SystemID is:"..systemid) end
	local faction = SBCI.SystemNames_[systemid][3]
  	if SBCI.debug then SBCI.debugprint("Local Factin is:"..faction) end
  	--[[if SBCI.debug then dprint("Number of stations loaded:"..#SBCI._._.stationAttacks.stations) end

	for i = 1, #SBCI._._.stationAttacks.stations, 1 do
		if (tonumber(SBCI._._.stationAttacks.stations[i][1]) == destsector) then
			faction = tonumber(SBCI._._.stationAttacks.stations[i][2])
			break;
		end
	end
	local destfaction = GetPlayerFactionStanding(faction, GetCharacterID()) / 32.768 -1000
	if destfaction < -600 then
		SBCI.print("\127ff1010-- WARNING -- Faction Standing at Destination: "..math.floor(destfaction), SBCI.colors.RED)
	elseif destfaction < -590 then
		SBCI.print("\127FFFF00-- CAUTION -- Check Faction Standing.  Low at Destination! "..math.floor(destfaction), SBCI.colors.ORANGE)
	end]]
end
