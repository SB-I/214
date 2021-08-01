TBS._.combat = {};

TBS._.combat.Active = false
TBS._.combat.NodeID = nil
TBS._.combat.ObjectID = nil
TBS._.combat.CharID = 1
TBS._.combat.TargetName = nil
TBS._.combat.TargetSyncs = {};

TBS._.combat._ = {
    orderID=null,
    targetID=null,
    sectorID=null
};

TBS._.combat.gkpc = gkinterface.GKProcessCommand
TBS._.combat.getradar = radar.GetRadarSelectionID
TBS._.combat.setradar = radar.SetRadarSelection


TBS._.combat.Toggle = function()
	if TBS._.combat.Active then
		TBS._.combat.Active = false
		UnregisterEvent(TBS._.combat.ReTarget, "HUD_SHOW")
		UnregisterEvent(TBS._.combat.CHAT_MSG_GROUP, "CHAT_MSG_GROUP")
		UnregisterEvent(TBS._.combat.SendJumpLocation, "CHAT_MSG_SECTORD_SECTOR")
		TBS.print("Attack mode De-Activated.",TBS.colors.combat)
	else
		TBS._.combat.Active = true
		RegisterEvent(TBS._.combat.ReTarget, "HUD_SHOW")
		RegisterEvent(TBS._.combat.CHAT_MSG_GROUP, "CHAT_MSG_GROUP")
		RegisterEvent(TBS._.combat.SendJumpLocation, "CHAT_MSG_SECTORD_SECTOR")
		TBS.print("Attack mode Activated.",TBS.colors.combat)
	end
end

TBS._.combat.TargetIDs = function(CharID) -- -> Node/Object/Character IDs..
	TBS._.combat.CharID = RequestTargetStats() or 1
	TBS._.combat.NodeID = GetPlayerNodeID(CharID)
	TBS._.combat.ObjectID = GetPrimaryShipIDOfPlayer(CharID)
	return TBS._.combat.NodeID, TBS._.combat.ObjectID, TBS._.combat.CharID
end

TBS._.combat.SetTarget = function(_, data)
	TBS._.combat.NodeID, TBS._.combat.ObjectID, TBS._.combat.CharID = TBS._.combat.TargetIDs(TBS._.combat.CharID)
	local msg ="say_group New Target: "..TBS._.combat.CharID
    TBS._.combat.TargetName = GetPlayerName(TBS._.combat.CharID)
    TBS._.combat.gkpc(msg)
    TBS.print("(Attack) Sending rally call against "..TBS.colors.yellow..TBS._.combat.TargetName,TBS.colors.combat)
    TBS.Proxy._notify("order_attack", {type="newTarget", sectorID=GetCurrentSectorid(), myID=GetCharacterID(), targetID=TBS._.combat.CharID});
end

TBS._.combat.Re_TargetCharID = function(data)
    if tonumber(data) == tonumber(TBS._.combat.CharID) then
        TBS._.combat.NodeID = GetPlayerNodeID(data)
        TBS._.combat.ObjectID = GetPrimaryShipIDOfPlayer(data)
        TBS._.combat.setradar(TBS._.combat.NodeID, TBS._.combat.ObjectID)
	end
end

TBS._.combat.ReTarget = function(_, data) -- data=HudType=<"ship" || "turret">;
    if not TBS._.combat.Active then return end
    if not TBS._.combat.CharID then return end
    ForEachPlayer(TBS._.combat.Re_TargetCharID)
end

TBS._.combat.CHAT_MSG_GROUP = function(_, data) --_="CHAT_MSG_GROUP";
    if not TBS._.combat.Active then return end
    local TargetSys, TargetSect, TargetCharID, TargetName; --=null;

    if (string.find(data["msg"],"New Target:")) then
		_, _, TBS._.combat.CharID = string.find(data["msg"], " (%d+)");
		TBS._.combat.TargetName = GetPlayerName(tonumber(TBS._.combat.CharID))
		TBS.print("(Attack) Targeted Player is: "..TBS.colors.yellow..TBS._.combat.TargetName,TBS.colors.combat)
		TBS._.combat.setradar(TBS._.combat.NodeID, TBS._.combat.ObjectID)
	end


	if (string.find(data["msg"],"Target Jumped To:")) then
		TargetName, TargetSys, TargetSect = string.match(data["msg"], "(%S+) jumped to (%S+) System, Sector (%S+)")
		if  (TargetName == TBS._.combat.TargetName) then
			local location = TargetSys.." "..TargetSect
			NavRoute.SetFinalDestination(SectorIDFromLocationStr(location))
			TBS._.combat.gkpc("Activate")
		end
	end
end

TBS.Proxy.on("order_attack", function(data)
    --data = {type=string, sectorID=int, orderID=int, targetID=int};
    -- -- "orderID" being that of who issued the order, this can be denied if not in target sync with this member...
    if(not data.type)then return end; --We have no idea what to do!!
    if(data.type == "newTarget")then
        if(not data.sectorID)then return end; --We have no idea where this is!!
        if(not data.targetID)then return end; --We have no idea who to target!!
        if(data.orderID == GetCharacterID())then return end; --We're the requester!!
        if(data.sectorID ~= GetCurrentSectorid())then return end; --We're not in the same sector.

        local targetSync = false;
        TBS._.combat._.orderID = data.orderID;
        TBS._.combat._.targetID = data.targetID;
        TBS._.combat._.sectorID = data.sectorID;

        for _,ID in ipairs(TBS._.combat.TargetSyncs)do
            if(data.orderID ~= ID)then return end;
            targetSync = true;
        end;

        if(not targetSync)then
            TBS.print("(Attack) "..TBS.colors.white..GetPlayerName(TBS._.combat._.orderID)..TBS.colors.combat.." requesting target: "..TBS.colors.yellow..GetPlayerName(TBS._.combat._.targetID).."\n* /a3 - YES",TBS.colors.combat);
        else
            _, _, TBS._.combat.CharID = string.find(data["msg"], " (%d+)");
            TBS._.combat.TargetName = GetPlayerName(tonumber(TBS._.combat.CharID))
            TBS.print("(Attack) Targeted Player is: "..TBS.colors.yellow..TBS._.combat.TargetName,TBS.colors.combat)
            TBS._.combat.setradar(TBS._.combat.NodeID, TBS._.combat.ObjectID)
        end;

    elseif(data.type == "newLocation")then
        if(not data.targetID)then return end; --We have no target ID!!
        print("1111")
        print(data.targetID)
        print(TBS._.combat.CharID)
        if(data.targetID ~= TBS._.combat.CharID)then return end; --This isn't our target.
        print("2222")
        TBS.print("(Attack) Target Jumped to: "..ShortLocationStr(data.sectorID ))

        NavRoute.SetFinalDestination(data.sectorID)
        TBS._.combat.gkpc("Activate")

    elseif(data.type == "rally")then
        --data = {type="rally", user:str, targetID=int, sectorID=int}
----<USER> is rallying with you against <TARGET> in <SECTOR_SHORT>
        TBS.print("(Attack) "..TBS.colors.white..data.user..TBS.colors.combat.." is rallying with you against "..TBS.colors.yellow..GetPlayerName(data.targetID)..TBS.colors.combat.." in "..TBS.colors.white..ShortLocationStr(data.sectorID),TBS.colors.combat);

    else
        TBS.print("(Attack) Unkown Attack Orders: \""..data.type.."\"",TBS.colors.combat);
    end;
end);

TBS._.combat.SendJumpLocation = function(_, data)
    if not TBS._.combat.Active then return end
    local TargetSys, TargetSect, TargetCharID, TargetName; --=null;

    TargetName, TargetSys, TargetSect = string.match(data["msg"], "(%S+) jumped to (%S+) System, Sector (%S+)")

    local _TargetSys = string.match(TargetSys, "^(%S+)");
    local sectorID = SectorIDFromLocationStr(_TargetSys.." "..TargetSect);

    if (string.find(data["msg"]," jumped to ")) then
        if (TargetName == TBS._.combat.TargetName) then
            local msg ="say_group Target Jumped To: "..data["msg"]
            TBS._.combat.gkpc(msg)
            TBS.Proxy._notify("order_attack", {type="newLocation", myID=GetCharacterID(), targetID=TBS._.combat.CharID, sectorID=sectorID})
        end
    else
        print("Thename:".. tostring(TargetName).."   TargetName:"..tostring(TBS._.combat.TargetName),TBS.colors.combat)
	end
end

TBS._.combat.SendRally = function(_,data)
    TBS.print("(Attack) Joining the hunt against "..TBS.colors.yellow..GetPlayerName(TBS._.combat._.targetID),TBS.colors.combat)
    TBS.Proxy._notify("order_attack",{type="rally", leaderID=TBS._.combat._.orderID, targetID=TBS._.combat._.targetID, user=GetPlayerName(), sectorID=TBS._.combat._.sectorID});

    TBS._.combat.TargetName = GetPlayerName(tonumber(TBS._.combat._.targetID))
    TBS.print("(Attack) Targeted Player is: "..TBS.colors.yellow..TBS._.combat.TargetName,TBS.colors.combat)
    --TBS._.combat.NodeID, TBS._.combat.ObjectID, TBS._.combat.CharID = TBS._.combat.TargetIDs(TBS._.combat._.targetID)
    TBS._.combat.CharID = TBS._.combat._.targetID;
    TBS._.combat.ReTarget();
end;
-------------------------------------------------------------
RegisterUserCommand("z1",TBS._.combat.Toggle);
RegisterUserCommand("z2",TBS._.combat.SetTarget);
RegisterUserCommand("a3",TBS._.combat.SendRally);
