SBCI = SBCI or {}; --SBCI Client.

dofile("__promise.lua")
dofile("__rpcproxy.lua")
dofile("__tcpsock.lua")
dofile("__json.lua")
dofile("_common.lua");
dofile("_connection.lua")
dofile("_events.lua")
dofile("settings.lua")
----dofile("tools.lua");
dofile("functions.lua"); --(Keep main.lua clean!)
--dofile("keys.lua")--
dofile("spotter.lua");--
--dofile("trading.lua")
----dofile("mining.lua")
--dofile("tct.lua");
--dofile("guildUpdate.lua"); --Prototype; rewrite.
dofile("ui/_dofile.lua");
--dofile("hidden/_dofile.lua");

SBCI.Commands = function(_, args)
    if(args)then
        local cmd = string.lower(args[1]);
        local subCmd = string.lower(args[2] or "");

        if(cmd == "")then
            --code
        elseif(cmd == "connect")then
            if(not SBCI.Connection.isConnected)then
                SBCI.Connection._Connect();
            else
                SBCI.Connection.CleanUp() --close connection.
            end;

        elseif(cmd=="say")then
            local arggs = args;
            table.remove(arggs, 1); --"say";
            local _ = nil;
            SBCI.SBCISay(_, arggs);

        --[[elseif(cmd=="keys")then
            --local arggs = args; table.remove(arggs, 1); table.remove(arggs, 1); --"keys" "subCmd";
            local keyid = string.lower(args[3] or "0");
            if(keyid==0)then return SBCI.print("(Keys) KeyID not defined.") end;
            local params = {};
            params.action = subCmd;
            params.keyid = keyid;

            if(subCmd=="distro")then
                local keygroup = string.lower(args[4] or "");
                if(not keygroup)then return SBCI.print("(Keys) KeyGroup not defined.") end;
                params.keygroup = keygroup;


            elseif(subCmd=="ignore")then--ignore a key.
                --We've done what we need already...
            elseif(subCmd=="adduser")then

            elseif(subCmd=="addowner")then

            elseif(subCmd=="removeuser")then

            elseif(subCmd=="removeowner")then

            end;
            SBCI.Proxy.Keys(params)]]

        elseif(cmd=="settings")then
            SBCI.UISettings:showDialog();

        elseif(cmd=="get_members")then
            SBCI.Guild.SendMembers();

        elseif(cmd=="tct")then
            SBCI.tct.target()


    -- Below are Dev Commands.
        elseif(cmd == "debug")then
            if(SBCI.debug)then SBCI.debug = false;
            else SBCI.debug = true end;
            SBCI.print("> SBCI.debug = "..tostring(SBCI.debug), SBCI.colors.YELLOW);

        elseif(cmd=="reload")then
            SBCI.CleanUp();
            ReloadInterface();
        end;
    else
        --Help ??
    end;
end;

--Register Commands.
RegisterUserCommand("sbci", SBCI.Commands);
RegisterUserCommand("say_sbci", SBCI.SBCISay)

--Register Events
RegisterEvent(SBCI.EventPlayerEnteredGame, "PLAYER_ENTERED_GAME"); --Do initialize stuff..
RegisterEvent(SBCI.CleanUp, "UNLOAD_INTERFACE") --ReloadInterface() or logout.
--RegisterEvent(TCFT3.Trading.SubmitStation, "ENTERED_STATION")
--RegisterEvent(TCFT3.Mining.EventTargetScanned, "TARGET_SCANNED")

--RegisterEvent(SBCI.Proxy.Stations, "CHAT_MSG_SERVER");
