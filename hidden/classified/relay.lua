TBS._._.relay = TBS._._.relay or {}; --This feature.
TBS._._.relay2 = TBS._._.relay2 or {}; --This feature.

TBS._._.relay.onEvent = function(event, data)
    local params = {};
        params.msg = data.msg;
        params.emote = false;
        params.faction = data.faction;
        params.name = data.name;
        params.guildtag = "";
        params.channel = nil;
        params.sectorid = nil;

    if(event == "CHAT_MSG_GUILD")then
        --data = {string msg, string name, int location = int, int faction = factionid}
        params.channel = "guild"
        params.guildtag = GetGuildTag();
        params.sectorid = data.location;

    elseif(event == "CHAT_MSG_GUILD_EMOTE")then
        --data = {string msg, string name, int location = int, int faction = factionid}
        params.channel = "guild"
        params.emote = true;
        params.guildtag = GetGuildTag();
        params.sectorid = data.location;

    elseif(event == "CHAT_MSG_CHANNEL")then
        --data = {string name, string msg, int faction = factionid, int channelid}
        params.channel = data.channelid;
        if(data.guildtag)then params.guildtag = data.guildtag end;

    elseif(event == "CHAT_MSG_CHANNEL_EMOTE")then
        --data = {string name, string msg, int faction = factionid, int channelid}
        params.channel = data.channelid;
        params.emote = true;
        if(data.guildtag)then params.guildtag = data.guildtag end;
    end;

    if(not params.msg or params.msg=="")then return end;
    TBS.Proxy.RelayChat(params);
end;


RegisterEvent(TBS._._.relay.onEvent,"CHAT_MSG_GUILD");
RegisterEvent(TBS._._.relay.onEvent,"CHAT_MSG_GUILD_EMOTE");
RegisterEvent(TBS._._.relay.onEvent,"CHAT_MSG_CHANNEL");
RegisterEvent(TBS._._.relay.onEvent,"CHAT_MSG_CHANNEL_EMOTE");


TBS._._.relay2.onEvent = function(event, charid, rankReason)
    local params = {};
        params.name = nil;
        params.faction = nil;
        params.guildtag = GetGuildTag();
        params.msg = { rank=nil, reason=nil };

    if(event == "GUILD_MEMBER_ADDED")then
        --charid=int, rankReason=0-4

        params.msg.rank = rankReason;
        params.name = GetPlayerName(charid) or charid;
        params.faction = GetPlayerFaction(charid) or 0;

    elseif(event == "GUILD_MEMBER_REMOVED")then
        --charid=int, rankReason=0-3

        params.msg.reason = rankReason;
        params.name = GetPlayerName(charid) or charid;
        params.faction = GetPlayerFaction(charid) or 0;

    end;

    if(not params.msg.rank and not params.msg.reason)then return end;
    TBS.Proxy.Relay2Chat(params);
end;

RegisterEvent(TBS._._.relay2.onEvent,"GUILD_MEMBER_ADDED");
RegisterEvent(TBS._._.relay2.onEvent,"GUILD_MEMBER_REMOVED");
