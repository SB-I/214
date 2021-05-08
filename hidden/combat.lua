SBCI._.combat = {};

SBCI._.combat.Active = false
SBCI._.combat.NodeID = nil
SBCI._.combat.ObjectID = nil
SBCI._.combat.CharID = 1
SBCI._.combat.TargetName = nil
SBCI._.combat.TargetSyncs = {};

SBCI._.combat._ = {
    orderID=null,
    targetID=null,
    sectorID=null
};

SBCI._.combat.gkpc = gkinterface.GKProcessCommand
SBCI._.combat.getradar = radar.GetRadarSelectionID
SBCI._.combat.setradar = radar.SetRadarSelection


SBCI._.combat.Toggle = function()
	if SBCI._.combat.Active then
		SBCI._.combat.Active = false
		UnregisterEvent(SBCI._.combat.ReTarget, "HUD_SHOW")
		UnregisterEvent(SBCI._.combat.CHAT_MSG_GROUP, "CHAT_MSG_GROUP")
		UnregisterEvent(SBCI._.combat.SendJumpLocation, "CHAT_MSG_SECTORD_SECTOR")
		SBCI.print("Attack mode De-Activated.",SBCI.colors.combat)
	else
		SBCI._.combat.Active = true
		RegisterEvent(SBCI._.combat.ReTarget, "HUD_SHOW")
		RegisterEvent(SBCI._.combat.CHAT_MSG_GROUP, "CHAT_MSG_GROUP")
		RegisterEvent(SBCI._.combat.SendJumpLocation, "CHAT_MSG_SECTORD_SECTOR")
		SBCI.print("Attack mode Activated.",SBCI.colors.combat)
	end
end

SBCI._.combat.TargetIDs = function(CharID) -- -> Node/Object/Character IDs..
	SBCI._.combat.CharID = RequestTargetStats() or 1
	SBCI._.combat.NodeID = GetPlayerNodeID(CharID)
	SBCI._.combat.ObjectID = GetPrimaryShipIDOfPlayer(CharID)
	return SBCI._.combat.NodeID, SBCI._.combat.ObjectID, SBCI._.combat.CharID
end

SBCI._.combat.SetTarget = function(_, data)
	SBCI._.combat.NodeID, SBCI._.combat.ObjectID, SBCI._.combat.CharID = SBCI._.combat.TargetIDs(SBCI._.combat.CharID)
	local msg ="say_group New Target: "..SBCI._.combat.CharID
    SBCI._.combat.TargetName = GetPlayerName(SBCI._.combat.CharID)
    SBCI._.combat.gkpc(msg)
    SBCI.print("(Attack) Sending rally call against "..SBCI.colors.YELLOW..SBCI._.combat.TargetName,SBCI.colors.combat)
    SBCI.Proxy._notify("order_attack", {type="newTarget", sectorID=GetCurrentSectorid(), myID=GetCharacterID(), targetID=SBCI._.combat.CharID});
end

SBCI._.combat.Re_TargetCharID = function(data)
    if tonumber(data) == tonumber(SBCI._.combat.CharID) then
        SBCI._.combat.NodeID = GetPlayerNodeID(data)
        SBCI._.combat.ObjectID = GetPrimaryShipIDOfPlayer(data)
        SBCI._.combat.setradar(SBCI._.combat.NodeID, SBCI._.combat.ObjectID)
	end
end

SBCI._.combat.ReTarget = function(_, data) -- data=HudType=<"ship" || "turret">;
    if not SBCI._.combat.Active then return end
    if not SBCI._.combat.CharID then return end
    ForEachPlayer(SBCI._.combat.Re_TargetCharID)
end

SBCI._.combat.CHAT_MSG_GROUP = function(_, data) --_="CHAT_MSG_GROUP";
    if not SBCI._.combat.Active then return end
    local TargetSys, TargetSect, TargetCharID, TargetName; --=null;

    if (string.find(data["msg"],"New Target:")) then
		_, _, SBCI._.combat.CharID = string.find(data["msg"], " (%d+)");
		SBCI._.combat.TargetName = GetPlayerName(tonumber(SBCI._.combat.CharID))
		SBCI.print("(Attack) Targeted Player is: "..SBCI.colors.YELLOW..SBCI._.combat.TargetName,SBCI.colors.combat)
		SBCI._.combat.setradar(SBCI._.combat.NodeID, SBCI._.combat.ObjectID)
	end


	if (string.find(data["msg"],"Target Jumped To:")) then
		TargetName, TargetSys, TargetSect = string.match(data["msg"], "(%S+) jumped to (%S+) System, Sector (%S+)")
		if  (TargetName == SBCI._.combat.TargetName) then
			local location = TargetSys.." "..TargetSect
			NavRoute.SetFinalDestination(SectorIDFromLocationStr(location))
			SBCI._.combat.gkpc("Activate")
		end
	end
end

SBCI.Proxy.on("order_attack", function(data)
    --data = {type=string, sectorID=int, orderID=int, targetID=int};
    -- -- "orderID" being that of who issued the order, this can be denied if not in target sync with this member...
    if(not data.type)then return end; --We have no idea what to do!!
    if(data.type == "newTarget")then
        if(not data.sectorID)then return end; --We have no idea where this is!!
        if(not data.targetID)then return end; --We have no idea who to target!!
        if(data.orderID == GetCharacterID())then return end; --We're the requester!!
        if(data.sectorID ~= GetCurrentSectorid())then return end; --We're not in the same sector.

        local targetSync = false;
        SBCI._.combat._.orderID = data.orderID;
        SBCI._.combat._.targetID = data.targetID;
        SBCI._.combat._.sectorID = data.sectorID;

        for _,ID in ipairs(SBCI._.combat.TargetSyncs)do
            if(data.orderID ~= ID)then return end;
            targetSync = true;
        end;

        if(not targetSync)then
            SBCI.print("(Attack) "..SBCI.colors.WHITE..GetPlayerName(SBCI._.combat._.orderID)..SBCI.colors.combat.." requesting target: "..SBCI.colors.YELLOW..GetPlayerName(SBCI._.combat._.targetID).."\n* /a3 - YES",SBCI.colors.combat);
        else
            _, _, SBCI._.combat.CharID = string.find(data["msg"], " (%d+)");
            SBCI._.combat.TargetName = GetPlayerName(tonumber(SBCI._.combat.CharID))
            SBCI.print("(Attack) Targeted Player is: "..SBCI.colors.YELLOW..SBCI._.combat.TargetName,SBCI.colors.combat)
            SBCI._.combat.setradar(SBCI._.combat.NodeID, SBCI._.combat.ObjectID)
        end;

    elseif(data.type == "newLocation")then
        if(not data.targetID)then return end; --We have no target ID!!
        print("1111")
        print(data.targetID)
        print(SBCI._.combat.CharID)
        if(data.targetID ~= SBCI._.combat.CharID)then return end; --This isn't our target.
        print("2222")
        SBCI.print("(Attack) Target Jumped to: "..ShortLocationStr(data.sectorID ))

        NavRoute.SetFinalDestination(data.sectorID)
        SBCI._.combat.gkpc("Activate")

    elseif(data.type == "rally")then
        --data = {type="rally", user:str, targetID=int, sectorID=int}
----<USER> is rallying with you against <TARGET> in <SECTOR_SHORT>
        SBCI.print("(Attack) "..SBCI.colors.WHITE..data.user..SBCI.colors.combat.." is rallying with you against "..SBCI.colors.YELLOW..GetPlayerName(data.targetID)..SBCI.colors.combat.." in "..SBCI.colors.WHITE..ShortLocationStr(data.sectorID),SBCI.colors.combat);

    else
        SBCI.print("(Attack) Unkown Attack Orders: \""..data.type.."\"",SBCI.colors.combat);
    end;
end);

SBCI._.combat.SendJumpLocation = function(_, data)
    if not SBCI._.combat.Active then return end
    local TargetSys, TargetSect, TargetCharID, TargetName; --=null;

    TargetName, TargetSys, TargetSect = string.match(data["msg"], "(%S+) jumped to (%S+) System, Sector (%S+)")

    local _TargetSys = string.match(TargetSys, "^(%S+)");
    local sectorID = SectorIDFromLocationStr(_TargetSys.." "..TargetSect);

    if (string.find(data["msg"]," jumped to ")) then
        if (TargetName == SBCI._.combat.TargetName) then
            local msg ="say_group Target Jumped To: "..data["msg"]
            SBCI._.combat.gkpc(msg)
            SBCI.Proxy._notify("order_attack", {type="newLocation", myID=GetCharacterID(), targetID=SBCI._.combat.CharID, sectorID=sectorID})
        end
    else
        print("Thename:".. tostring(TargetName).."   TargetName:"..tostring(SBCI._.combat.TargetName),SBCI.colors.combat)
	end
end

SBCI._.combat.SendRally = function(_,data)
    SBCI.print("(Attack) Joining the hunt against "..SBCI.colors.YELLOW..GetPlayerName(SBCI._.combat._.targetID),SBCI.colors.combat)
    SBCI.Proxy._notify("order_attack",{type="rally", leaderID=SBCI._.combat._.orderID, targetID=SBCI._.combat._.targetID, user=GetPlayerName(), sectorID=SBCI._.combat._.sectorID});

    SBCI._.combat.TargetName = GetPlayerName(tonumber(SBCI._.combat._.targetID))
    SBCI.print("(Attack) Targeted Player is: "..SBCI.colors.YELLOW..SBCI._.combat.TargetName,SBCI.colors.combat)
    --SBCI._.combat.NodeID, SBCI._.combat.ObjectID, SBCI._.combat.CharID = SBCI._.combat.TargetIDs(SBCI._.combat._.targetID)
    SBCI._.combat.CharID = SBCI._.combat._.targetID;
    SBCI._.combat.ReTarget();
end;
-------------------------------------------------------------
RegisterUserCommand("z1",SBCI._.combat.Toggle);
RegisterUserCommand("z2",SBCI._.combat.SetTarget);
RegisterUserCommand("a3",SBCI._.combat.SendRally);
