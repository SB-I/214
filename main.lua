TBS = TBS or {}; --TBS Client.

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

TBS.Commands = function(_, args)
    if(args)then
        local cmd = string.lower(args[1]);
        local subCmd = string.lower(args[2] or "");

        if(cmd == "")then
            --code
        elseif(cmd == "connect")then
            if(not TBS.Connection.isConnected)then
                TBS.Connection._Connect();
            else
                TBS.Connection.CleanUp() --close connection.
            end;

        elseif(cmd=="say")then
            local arggs = args;
            table.remove(arggs, 1); --"say";
            local _ = nil;
            TBS.TBSSay(_, arggs);

        --[[elseif(cmd=="keys")then
            --local arggs = args; table.remove(arggs, 1); table.remove(arggs, 1); --"keys" "subCmd";
            local keyid = string.lower(args[3] or "0");
            if(keyid==0)then return TBS.print("(Keys) KeyID not defined.") end;
            local params = {};
            params.action = subCmd;
            params.keyid = keyid;

            if(subCmd=="distro")then
                local keygroup = string.lower(args[4] or "");
                if(not keygroup)then return TBS.print("(Keys) KeyGroup not defined.") end;
                params.keygroup = keygroup;


            elseif(subCmd=="ignore")then--ignore a key.
                --We've done what we need already...
            elseif(subCmd=="adduser")then

            elseif(subCmd=="addowner")then

            elseif(subCmd=="removeuser")then

            elseif(subCmd=="removeowner")then

            end;
            TBS.Proxy.Keys(params)]]

        elseif(cmd=="settings")then
            TBS.UISettings:showDialog();

        elseif(cmd=="get_members")then
            TBS.Guild.SendMembers();

        elseif(cmd=="tct")then
            TBS.tct.target()


    -- Below are Dev Commands.
        elseif(cmd == "debug")then
            if(TBS.debug)then TBS.debug = false;
            else TBS.debug = true end;
            TBS.print("@yellow@> TBS.debug = "..tostring(TBS.debug));

        elseif(cmd=="reload")then
            TBS.CleanUp();
            ReloadInterface();

        else
            TBS.print("Unknown Command \"@yellow@"..cmd.."@white@\"")
        end;
    else
        TBS.print("Help (Coming Soon(tm)!!)")
    end;
end;

--Register Commands.
RegisterUserCommand("tbs", TBS.Commands);
RegisterUserCommand("say_tbs", TBS.TBSSay)

--Register Events
RegisterEvent(TBS.EventPlayerEnteredGame, "PLAYER_ENTERED_GAME"); --Do initialize stuff..
RegisterEvent(TBS.CleanUp, "UNLOAD_INTERFACE") --ReloadInterface() or logout.
--RegisterEvent(TCFT3.Trading.SubmitStation, "ENTERED_STATION")
--RegisterEvent(TCFT3.Mining.EventTargetScanned, "TARGET_SCANNED")

--RegisterEvent(TBS.Proxy.Stations, "CHAT_MSG_SERVER");
