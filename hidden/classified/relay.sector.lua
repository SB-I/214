SBCI._._.relay = SBCI._._.relay or {}; --This feature.

SBCI._._.relay.onEvent = function(event, data)
    local params = {};
        params.msg = data.msg;
        params.emote = false;
        params.faction = data.faction;
        params.name = data.name;
        params.guildtag = "";
        params.channel = nil;
        params.sectorid = GetCurrentSectorid();

    if(event == "CHAT_MSG_SECTOR")then
        --data = {string msg, string name, int location = sectorid, int faction = factionid}
        params.channel = "sector"
        params.guildtag = GetGuildTag(GetCharacterIDByName(params.name));

    elseif(event == "CHAT_MSG_SECTOR_EMOTE")then
        --data = {string msg, string name, int location = sectorid, int faction = factionid}
        params.channel = "sector"
        params.emote = true;
        params.guildtag = GetGuildTag(GetCharacterIDByName(params.name));
    end;

    if(not params.msg or params.msg=="")then return end;
    SBCI.Proxy.RelayChat(params);
end;


RegisterEvent(SBCI._._.relay.onEvent,"CHAT_MSG_SECTOR");
RegisterEvent(SBCI._._.relay.onEvent,"CHAT_MSG_SECTOR_EMOTE");
