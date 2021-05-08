--[[
    ToDo:
        send list of Guild members currently online.
        send guild member when they just logged on.
        send guild member if they did not log off, but guild_removed.
        read activity log: check for "member left guild"/"member joined guild" send member.status
]]

--below was coded up as an example.
--May not function, use as basic guidlines for this feature. @Spy ~Spy

SBCI.Guild = {};
SBCI.Guild.SentMembers = {};

SBCI.Guild.SendMembers = function()
    if(not SBCI.Connection.isConnected)then return end; --SilentRunning.
    --if(GetGuildAcronym() ~= "SBCI")then return print("NOT SBCI")end;
    local list = {};

    for i=1, GetNumGuildMembers()do --GetNumGuildMembers() "Get's num of 'Online' members."
        local charid, rank, name = GetGuildMemberInfo(i);
        if(charid ~= GetCharacterIDByName(GetPlayerName()))then
            list[charid] = {name=name, rank=rank};
            --list{ [4444]={name:"SBCI", rank:5} };
        end; --Ignore the messenger.
    end;

    local players = SBCI.tableSize(list); --In case another user logs in or something?
    if(players>0)then
        --if(SBCI.isConnected())then
            SBCI.debugprint("Sending Data: \"update_guild_members\", {"..spickle({ type="add", players=list }).."}")
            SBCI.Proxy._request("update_guild_members", { type="add", players=list } )
            :next( function(results)
                if(results==players)then--Saved is same amount that we sent.
                    --Save to local table, so we don't send a duplicate.
                    for k,v in pairs(list)do
                        if(SBCI.Guild.SentMembers[k]==v.name)then return end; --We must'a logged out then in.
                        SBCI.debugprint("Pushing to 'SentMembers': "..k.."="..v.name)
                        SBCI.Guild.SentMembers[k] = v.name;

                        table.sort(SBCI.Guild.SentMembers); --OCD ~Spy
                    end;
                end;
            end):catch( function(err)
                SBCI.print("Error sending GuildMembers: "..err, SBCI.colors.RED)
            end);
            --This should only run once; Unregister this event/function.
            UnregisterEvent(SBCI.Guild.SendMembers, "SECTOR_CHANGED");
        --end;
    end;
end;

SBCI.Guild.SendMember = function(_,charid, rank)
    if(not SBCI.Connection.isConnected)then return end; --SilentRunning.
    if(GetGuildAcronym() ~= "SBCI")then return end;
    local name = GetPlayerName(charid);
    if(SBCI.Guild.SentMembers[charid]==name)then return end; --We've already sent this member. Logged back in.
    local members = {};
    members[charid] = {name=name, rank=rank};

    --if(SBCI.isConnected(0))then
        SBCI.debugprint("Sending Data: \"update_guild_members\", {"..spickle({ type="add", players=members }).."}");
        SBCI.Proxy._request("update_guild_members", { type="add", players=members });

        --if result == true;
        SBCI.debugprint("Pushing to 'SentMembers': "..charid.."="..name)
        SBCI.Guild.SentMembers[charid] = name;
        table.sort(SBCI.Guild.SentMembers); --OCD ~Spy
    --end;
end;

SBCI.Guild.SendRemovedMember = function(_,charid, reason)
    --reason = 0=logoff, 1=resign, 2=kicked out by commander/lieutenant, 3=voted out by council.
    if(not SBCI.Connection.isConnected)then return end; --SilentRunning.
    if(GetGuildAcronym() ~= "SBCI")then return end;
    if(reason == 0)then return end;--Simple log off.
    local name = GetPlayerName(charid);
    local members = {};
    member[charid] = {name=name, reason=reason};

    --if(SBCI.isConnected(0))then
        SBCI.debugprint("Sending Data: \"update_guild_members\", {"..spickle({ type="remove", members}).."}");
        SBCI.Proxy._request("update_guild_members", { type="remove", players=members});

        --if result == true;
        SBCI.debugprint("Removing from 'SentMembers': "..charid.."="..name)
        SBCI.Guild.SentMembers[charid] = nil; --In case they rejoin guild take them out of "Sent" list.
    --end;
end;

RegisterEvent(SBCI.Guild.SendMembers, "SECTOR_CHANGED");
RegisterEvent(SBCI.Guild.SendMember, "GUILD_MEMBER_ADDED");
RegisterEvent(SBCI.Guild.SendRemovedMember, "GUILD_MEMBER_REMOVED");
