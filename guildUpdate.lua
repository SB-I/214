--[[
    ToDo:
        send list of Guild members currently online.
        send guild member when they just logged on.
        send guild member if they did not log off, but guild_removed.
        read activity log: check for "member left guild"/"member joined guild" send member.status
]]

--below was coded up as an example.
--May not function, use as basic guidlines for this feature. @Spy ~Spy

TBS.Guild = {};
TBS.Guild.SentMembers = {};

TBS.Guild.SendMembers = function()
    if(not TBS.Connection.isConnected)then return end; --SilentRunning.
    --if(GetGuildAcronym() ~= "TBS")then return print("NOT TBS")end;
    local list = {};

    for i=1, GetNumGuildMembers()do --GetNumGuildMembers() "Get's num of 'Online' members."
        local charid, rank, name = GetGuildMemberInfo(i);
        if(charid ~= GetCharacterIDByName(GetPlayerName()))then
            list[charid] = {name=name, rank=rank};
            --list{ [4444]={name:"TBS", rank:5} };
        end; --Ignore the messenger.
    end;

    local players = TBS.tableSize(list); --In case another user logs in or something?
    if(players>0)then
        --if(TBS.isConnected())then
            TBS.debugprint("Sending Data: \"update_guild_members\", {"..spickle({ type="add", players=list }).."}")
            TBS.Proxy._request("update_guild_members", { type="add", players=list } )
            :next( function(results)
                if(results==players)then--Saved is same amount that we sent.
                    --Save to local table, so we don't send a duplicate.
                    for k,v in pairs(list)do
                        if(TBS.Guild.SentMembers[k]==v.name)then return end; --We must'a logged out then in.
                        TBS.debugprint("Pushing to 'SentMembers': "..k.."="..v.name)
                        TBS.Guild.SentMembers[k] = v.name;

                        table.sort(TBS.Guild.SentMembers); --OCD ~Spy
                    end;
                end;
            end):catch( function(err)
                TBS.print("Error sending GuildMembers: "..err, TBS.colors.RED)
            end);
            --This should only run once; Unregister this event/function.
            UnregisterEvent(TBS.Guild.SendMembers, "SECTOR_CHANGED");
        --end;
    end;
end;

TBS.Guild.SendMember = function(_,charid, rank)
    if(not TBS.Connection.isConnected)then return end; --SilentRunning.
    if(GetGuildAcronym() ~= "TBS")then return end;
    local name = GetPlayerName(charid);
    if(TBS.Guild.SentMembers[charid]==name)then return end; --We've already sent this member. Logged back in.
    local members = {};
    members[charid] = {name=name, rank=rank};

    --if(TBS.isConnected(0))then
        TBS.debugprint("Sending Data: \"update_guild_members\", {"..spickle({ type="add", players=members }).."}");
        TBS.Proxy._request("update_guild_members", { type="add", players=members });

        --if result == true;
        TBS.debugprint("Pushing to 'SentMembers': "..charid.."="..name)
        TBS.Guild.SentMembers[charid] = name;
        table.sort(TBS.Guild.SentMembers); --OCD ~Spy
    --end;
end;

TBS.Guild.SendRemovedMember = function(_,charid, reason)
    --reason = 0=logoff, 1=resign, 2=kicked out by commander/lieutenant, 3=voted out by council.
    if(not TBS.Connection.isConnected)then return end; --SilentRunning.
    if(GetGuildAcronym() ~= "TBS")then return end;
    if(reason == 0)then return end;--Simple log off.
    local name = GetPlayerName(charid);
    local members = {};
    member[charid] = {name=name, reason=reason};

    --if(TBS.isConnected(0))then
        TBS.debugprint("Sending Data: \"update_guild_members\", {"..spickle({ type="remove", members}).."}");
        TBS.Proxy._request("update_guild_members", { type="remove", players=members});

        --if result == true;
        TBS.debugprint("Removing from 'SentMembers': "..charid.."="..name)
        TBS.Guild.SentMembers[charid] = nil; --In case they rejoin guild take them out of "Sent" list.
    --end;
end;

RegisterEvent(TBS.Guild.SendMembers, "SECTOR_CHANGED");
RegisterEvent(TBS.Guild.SendMember, "GUILD_MEMBER_ADDED");
RegisterEvent(TBS.Guild.SendRemovedMember, "GUILD_MEMBER_REMOVED");
