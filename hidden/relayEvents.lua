
--[[
    method: '__isOnline',
    data: { 'username': str },
    returns: bool,
    description: Checks if the provided {data.username} is currently online for discord authentication.
]]
TBS.Proxy.on('__isOnline', function(data)
    --data = { username:str };

    local hasPlayer = false;

    for i=1, GetNumGuildMembers()do --GetNumGuildMembers() "Get's num of 'Online' members."
        local charid, rank, name = GetGuildMemberInfo(i);
        if(name == data.username)then
            hasPlayer = { charID=charid, rank=rank };
            break;
        end; --Ignore the messenger.
    end;
    
    return hasPlayer;
end);
