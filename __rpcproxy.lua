--[[
    RPC Proxy coded by Xanos.
    Edited by "Scion Spy" for TBS.
]]

TBS.Proxy = TBS.Proxy or {}

TBS.Proxy.__eventHandlers = {}

-- Objects in __openRpcRequests should have the following format:
-- {
--     timestamp = int (os.time()),
--     promise = promise
-- }
-- keys are message ids
TBS.Proxy.__openRpcRequests = {}
TBS.Proxy.__msg_id_index = 0
TBS.Proxy.timer = Timer()

local TIMEOUT = 8 -- seconds

-- Check for expired requests every second
TBS.Proxy.timer:SetTimeout(TIMEOUT*1000, function()
    for k, v in pairs(TBS.Proxy.__openRpcRequests) do
        if (os.time() - v.timestamp) > TIMEOUT then
            v.promise:reject("RPC Request timed out.")
            TBS.Proxy.__openRpcRequests[k] = nil
        end
    end
end)


-- Deliver all incoming messages from the RPC server to this function.
TBS.Proxy.deliver = function(line)
    local data = nil
    local status, errmsg = pcall(function()
        data = _json.decode(line)
    end)
    if not status then
        TBS.debugprint('Could not decode incoming json: ' .. line)
        return
    end
    if(data.result~=nil)then --Incoming is response to a recent TC3 request.
        TBS.debugprint('Received result from server.')
        if(TBS.Proxy.__openRpcRequests[data.id] == nil)then
            TBS.print("Unknown Request: ID:"..data.id..", Obj:"..data, TBS.colors.RED)
            return
        end
        local status, errMsg = pcall(function()
            TBS.Proxy.__openRpcRequests[data.id].promise:resolve(data.result)
            -- Apparently, setting table value to "nil" is an acceptable way of
            -- removing an item from a table based on the key value.
            -- https://stackoverflow.com/questions/1758991/how-to-remove-a-lua-table-entry-by-its-key
            TBS.Proxy.__openRpcRequests[data.id] = nil;
        end)
        if status == false then
            TBS.print('ERROR calling result handler: '..errMsg, TBS.colors.RED)
            return
        end
    elseif data.method ~= nil then
        -- Handle incoming TC3 RPC call. TODO : Must send result back to server
        TBS.debugprint('Handle incoming method call from server: '..data.method)
        local result = nil;

        local status, errMsg = pcall( function()
            result = TBS.Proxy.__eventHandlers[data.method](data.params)
        end)

        if status == false then
            TBS.print("ERROR: Could not call event handler: "..errMsg, TBS.colors.RED)
            return false
        else
            TBS.Proxy._result(result, data['id']);
        end;
        return;

    elseif data.error ~= nil then
        -- Handle incoming TC3 RPC error
        if(data.id ~= nil)then
            local status, errMsg = pcall(function()
                TBS.Proxy.__openRpcRequests[data.id].promise:reject(data.error)
                TBS.Proxy.__openRpcRequests[data.id] = nil
            end)
            if not status then
                TBS.print("Could not reject promise: " .. errMsg)
            end
        else
            TBS.print("@indianRed@Incoming Server Error: @white@"..data.error.code.." - "..data.error.message)
        end
    end
end


-- Internal send function. Expects a string for "method", object for "params"
TBS.Proxy._request= function(method, params)
    local msgId = TBS.Proxy.__msg_id_index
    TBS.Proxy.__msg_id_index = TBS.Proxy.__msg_id_index+1
    local packet = {method = method, params = params, id=msgId}

    local promise = Promise.new()
    TBS.Proxy.__openRpcRequests[msgId] = {
        timestamp = os.time(),
        promise = promise
    }

    TBS.debugprint("Sending rpc request: " .. spickle(packet))
    TBS.Connection.send(_json.encode(packet) .. "\r\n")
    return promise
end

-- Internal send function. Expects a string for "method", object for "params"
TBS.Proxy._notify= function(method, params)
    local packet = {method = method, params = params}

    TBS.debugprint("Sending rpc notification: " .. spickle(packet))
    TBS.Connection.send(_json.encode(packet) .. "\r\n")
    return
end

-- Interal send function. Expects an object for result, and an int for id/
TBS.Proxy._result = function(result, id)
    local packet = {result = result, id = id};

    TBS.debugprint("Sending rpc result: " .. spickle(packet))
    TBS.Connection.send(_json.encode(packet) .. "\r\n")
    return
end;

TBS.Proxy.on = function(method, callback)
    TBS.Proxy.__eventHandlers[method] = callback
end

TBS.Proxy.authenticate = function(username, password, idstring)
    TBS.debugprint("authenticate")
    local params = {
        version = TBS.Version,
        username = username,
        password = password,
        --guildtag = GetGuildTag(),
        --charname = GetPlayerName(),
        charid = GetCharacterID(),
        idstring = idstring
    };

    return TBS.Proxy._request('authenticate', params)
end

TBS.Proxy.logout = function()
    return TBS.Proxy._request("logout", {});
end;






TBS.Proxy.getOnlineUsers = function()
    return TBS.Proxy._request("get_online_users", {})
end

-- Get the current logged-in user's roles
TBS.Proxy.getRoles = function()
    return TBS.Proxy._request("get_roles", {})
end

-- Get all available/possible roles
TBS.Proxy.getAllRoles = function()
    return TBS.Proxy._request("get_all_roles", {})
end



--[[
    Submit station/item info.
    items: Array of objects:
        [{ name = text,
           sellprice = int or nil,
           buyprice = int or nil,
           type = text,
           desired = bool,
           staticprice = bool,
           mass = int,
           volume = int,
           inventory = int,
        }]
]]
--[[TBS.Proxy.__submitStationInfo = function(sectorid, stationid)
    local sendbuf = {}
    for i=1, 25 do
        if #TBS.Proxy.__submitStationInfoBuf <= 0 then
            break
        end
        table.insert(sendbuf, table.remove(TBS.Proxy.__submitStationInfoBuf) )
    end
    if #sendbuf == 0 then
        if TBS.Proxy.__submitStationInfoPromise then
            TBS.Proxy.__submitStationInfoPromise:resolve(true)
            TBS.Proxy.__submitStationInfoPromise = nil
        end
        return
    else
        local params = {
            sectorid = sectorid,
            stationid = stationid,
            items = sendbuf
        }
        local p = TBS.Proxy._request('submit_station_item_info', params)
        p:next( function(result)
            TBS.Proxy.__submitStationInfo(sectorid, stationid)
        end)
    end
end]]

--[[TBS.Proxy.submitStationInfo = function(sectorid, stationid, items)
    TBS.Proxy.__submitStationInfoBuf = items
    TBS.Proxy.__submitStationInfo(sectorid, stationid)
    local p = Promise.new()
    TBS.Proxy.__submitStationInfoPromise = p
    return p
end]]


--[[
registerNewUser()

Call this function to begin the process of registering a new user to TBS.

Required role privileges: In order to call this function, the caller must be
one of "Commander", "Lieutenant", or "Engineer" roles. If the user is not in
one of these roles, the caller will receive an "No such RPC method" error.

Parameters:
    name : The new username of the user
    roles : An array of roles you want the new user to be in.

Returns:
    A promise that resolves an "auth-code". The auth-code is required for the
    next step in this process in which the new user must call the
    "setMemberPassword" function below.

Example use case scenario:
    A new member, "UserX", has been accepted as full member into the guild.
    CommanderY manipulates a fancy UI which executes the function

        TBS.Proxy.registerNewUser("UserX", {"Member"})
        :next( function(authcode)
            -- Do something with authcode here
        end)

    CommanderY DM's the auth code to UserX

    UserX then manipulates a fancy UI which runs the function

        TBS.Proxy.setMemberPassword(desired_password, auth_code_from_CommanderY, maybe_an_email_address)

Note: This function can also be used to reset an existing member's password.
]]

TBS.Proxy.registerNewUser = function(name, roles)
    local params = {
        username = name,
        roles = roles }
    local p = TBS.Proxy._request('register_new_user', params)
        :next(function(result)
            return result.auth_code
        end)
    return p
end

--[[
setMemberPassword()

This function should be called when it is time for a new member to finalize
their account setup by setting a new password, OR if a member needs to reset a
lost password.

Required role priveleges: None.

Parameters:
    name : The username of the TBS account to set up
    password : The new password
    authCode : The authorization code generated previousy by registerNewUser()
        (See above)
    opt_params : Optional paramaters. The optional paramaters are:
        faction: an integer faction ID
        email: A string that is an email address

Returns:
    true on success
]]
TBS.Proxy.setMemberPassword = function(name, password, authCode, opt_params)
    local faction = GetPlayerFaction();
    local email = nil

    if opt_params ~= nil then
        email = opt_params.email
    end

    local params = {
        username = name,
        password = password,
        email = email,
        faction = faction,
        nonce = authCode,
        charID = GetCharacterID()
    }
    return TBS.Proxy._request('set_member_password', params)
end

--[[
submitRoidInfo()

Use this function to send asteroid info to the TBS database

Paramaters:
    sectorid: The sector ID of the roids being submitted
    roids: An array of the following format:

        [
            {
                id: int,
                temperature: float, (optional),
                ores: [
                    {
                        type: string, (i.e. VanAzek),
                        density: float, (i.e. 0.50 for 50%)
                    },
                ]
            },
        ]
]]
--[[TBS.Proxy.submitRoidInfo = function(sectorid, roids)
    local params = {
        sectorid = sectorid,
        roids = roids
    }
    return TBS.Proxy._notify('submit_roids', params)
end]]




TBS.Proxy.sendChat = function(msg, sectorid, isemote, ch)

    if(not ch)then ch = 0 end;

    local params = {
        msg = msg,
        sectorid = sectorid,
        isemote = isemote,
        channel = ch
    };

    return TBS.Proxy._notify('chat', params)
end


--[[
    Relay chat to RelayServer.

    @params = object {
        channel=<string || integer>,
        msg=string,
        emote=boolean,
        name=string,
        guildtag=[string],
        faction=integer
    }
    @returns true if relayed, false if failed.


    Relay2, relays guild notices. (logon/off)
    @params = object {
        name = str || int(charid)
        faction = int
        guildtag = str
        msg = {<rank=str || reason=str>}
    }
    @returns true if relayed, false if failed.
]]
TBS.Proxy.RelayChat = function(params)
    return TBS.Proxy._notify('chat', params)
end;
TBS.Proxy.Relay2Chat = function(params)
    return TBS.Proxy._notify('chat2', params)
end;

TBS.Proxy.Keys = function(params)
    TBS.Proxy._notify("keys", params);
end;

TBS.Proxy.Stations = function(_,params)
    local msg = {msg=params.msg};
    if msg == "Your station in Latos I-8 is under attack!" then
        TBS.Proxy._notify('station_attack', msg);
    elseif msg == "Your station in Bractus M-14 is under attack!" then
        TBS.Proxy._notify('station_attack', msg);
    elseif msg == "Your station in Pelatus C-12 is under attack!" then
        TBS.Proxy._notify('station_attack', msg);
   end
end;


TBS.Proxy.GetKoS = function(parmas)
    if(not params)then
        return TBS.Proxy._request('KoS', {type='getKoS'});
    end
end


--[[
playersSpotted()
Expected params:

    params = {
        sectorid = int,
        players = [{
            name = string (required),
            id = int (VO id, optional),
            guildtag = string (optional),
            shipname = string (optional)
            faction = int (optional)
        }, ... ]
    }

]]
TBS.Proxy.playersSpotted = function(params)
    TBS.Proxy._notify('players_spotted', params)
    --[[:next(function(kosList) -- kosLis = [{ name=str, faction=int, reason=str }]
	    if(kosList == false)then return end -- No KoS's were found.

        for _, player in ipairs(kosList) do
            if(not player['name']) then return end;
            local faction = "";
            if(not player['faction'])then
                faction = TBS.colors.faction[0]
            else
                faction = TBS.colors.faction[player['faction']]
    --[[        end

            TBS.print('@white@The pilot '..faction..player['name']..' @white@is KoS to [214] for: @yellow@'..player['reason']);
        end
    end)]]
end
