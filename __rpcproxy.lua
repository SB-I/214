--[[
    RPC Proxy coded by Xanos.
    Edited by "Scion Spy" for SBCI.
]]

SBCI.Proxy = SBCI.Proxy or {}

SBCI.Proxy.__eventHandlers = {}

-- Objects in __openRpcRequests should have the following format:
-- {
--     timestamp = int (os.time()),
--     promise = promise
-- }
-- keys are message ids
SBCI.Proxy.__openRpcRequests = {}
SBCI.Proxy.__msg_id_index = 0
SBCI.Proxy.timer = Timer()

local TIMEOUT = 8 -- seconds

-- Check for expired requests every second
SBCI.Proxy.timer:SetTimeout(TIMEOUT*1000, function()
    for k, v in pairs(SBCI.Proxy.__openRpcRequests) do
        if (os.time() - v.timestamp) > TIMEOUT then
            v.promise:reject("RPC Request timed out.")
            SBCI.Proxy.__openRpcRequests[k] = nil
        end
    end
end)


-- Deliver all incoming messages from the RPC server to this function.
SBCI.Proxy.deliver = function(line)
    local data = nil
    local status, errmsg = pcall(function()
        data = _json.decode(line)
    end)

    if not status then
        SBCI.debugprint('Could not decode incoming json: ' .. line)
        return
    end

    if(data.method ~= nil)then
        SBCI.debugprint('Incoming method: '..data.method);

        local status, errMsg = pcall( function()
            if(SBCI.Proxy.__eventHandlers[data.method])then
                SBCI.Proxy.__eventHandlers[data.method](data.params);
            else
                SBCI.print("ERROR calling event: \""..data.method.."\". Exists??");
            end;
        end);

        if status == false then
            SBCI.print("ERROR: Could not call event handler: "..errMsg, SBCI.colors.RED);
        end;
    else
        --ToDo: Tell server no method.
        return;
    end;
end


-- Internal send function. Expects a string for "method", object for "params"
SBCI.Proxy._request= function(method, params)
    local msgId = SBCI.Proxy.__msg_id_index
    SBCI.Proxy.__msg_id_index = SBCI.Proxy.__msg_id_index+1
    local packet = {method = method, params = params, id=msgId}

    local promise = Promise.new()
    SBCI.Proxy.__openRpcRequests[msgId] = {
        timestamp = os.time(),
        promise = promise
    }

    SBCI.debugprint("Sending rpc request: " .. spickle(packet))
    SBCI.Connection.send(_json.encode(packet) .. "\r\n")
    return promise
end

-- Internal send function. Expects a string for "method", object for "params"
SBCI.Proxy._notify= function(method, params)
    local packet = {method = method, params = params}

    SBCI.debugprint("Sending rpc notification: " .. spickle(packet))
    SBCI.Connection.send(_json.encode(packet) .. "\r\n")
    return
end

SBCI.Proxy.on = function(method, callback)
    SBCI.Proxy.__eventHandlers[method] = callback
end

SBCI.Proxy.authenticate = function(username, password, charname, charid, idstring)
    SBCI.debugprint("authenticate")
    local params = {
        username = username,
        password = password,
        guildtag = GetGuildTag(),
        charname = GetPlayerName(),
        charid = GetCharacterID(),
        idstring = idstring
    };

    return SBCI.Proxy._request('authenticate', params)
end

SBCI.Proxy.logout = function()
    return SBCI.Proxy._request("logout", {});
end;






--[[SBCI.Proxy.getOnlineUsers = function()
    return SBCI.Proxy._request("get_online_users", {})
end]]

-- Get the current logged-in user's roles
--[[SBCI.Proxy.getRoles = function()
    return SBCI.Proxy._request("get_roles", {})
end]]

-- Get all available/possible roles
--[[SBCI.Proxy.getAllRoles = function()
    return SBCI.Proxy._request("get_all_roles", {})
end]]

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
--[[SBCI.Proxy.__submitStationInfo = function(sectorid, stationid)
    local sendbuf = {}
    for i=1, 25 do
        if #SBCI.Proxy.__submitStationInfoBuf <= 0 then
            break
        end
        table.insert(sendbuf, table.remove(SBCI.Proxy.__submitStationInfoBuf) )
    end
    if #sendbuf == 0 then
        if SBCI.Proxy.__submitStationInfoPromise then
            SBCI.Proxy.__submitStationInfoPromise:resolve(true)
            SBCI.Proxy.__submitStationInfoPromise = nil
        end
        return
    else
        local params = {
            sectorid = sectorid,
            stationid = stationid,
            items = sendbuf
        }
        local p = SBCI.Proxy._request('submit_station_item_info', params)
        p:next( function(result)
            SBCI.Proxy.__submitStationInfo(sectorid, stationid)
        end)
    end
end]]

--[[SBCI.Proxy.submitStationInfo = function(sectorid, stationid, items)
    SBCI.Proxy.__submitStationInfoBuf = items
    SBCI.Proxy.__submitStationInfo(sectorid, stationid)
    local p = Promise.new()
    SBCI.Proxy.__submitStationInfoPromise = p
    return p
end]]


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
SBCI.Proxy.playersSpotted = function(params)
    return SBCI.Proxy._notify('players_spotted', params)
end

--[[
registerNewUser()

Call this function to begin the process of registering a new user to SBCI.

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

        SBCI.Proxy.registerNewUser("UserX", {"Member"})
        :next( function(authcode)
            -- Do something with authcode here
        end)

    CommanderY DM's the auth code to UserX

    UserX then manipulates a fancy UI which runs the function

        SBCI.Proxy.setMemberPassword(desired_password, auth_code_from_CommanderY, maybe_an_email_address)

Note: This function can also be used to reset an existing member's password.
]]

--[[SBCI.Proxy.registerNewUser = function(name, roles)
    local params = {
        username = name,
        roles = roles }
    local p = SBCI.Proxy._request('register_new_user', params)
        :next(function(result)
            return result.auth_code
        end)
    return p
end]]

SBCI.Proxy.sendChat = function(msg, sectorid, isemote)
    local params = {
        msg = msg,
        sectorid = sectorid,
        isemote = isemote
    }
    return SBCI.Proxy._notify('send_chat', params)
end

--[[
setMemberPassword()

This function should be called when it is time for a new member to finalize
their account setup by setting a new password, OR if a member needs to reset a
lost password.

Required role priveleges: None.

Parameters:
    name : The username of the SBCI account to set up
    password : The new password
    authCode : The authorization code generated previousy by registerNewUser()
        (See above)
    opt_params : Optional paramaters. The optional paramaters are:
        faction: an integer faction ID
        email: A string that is an email address

Returns:
    true on success
]]
--[[SBCI.Proxy.setMemberPassword = function(name, password, authCode, opt_params)
    local faction = nil
    local email = nil
    if opt_params ~= nil then
        faction = opt_params.faction
        email = opt_params.email
    end
    local params = {
        username = name,
        password = password,
        nonce = authCode,
        email = email,
        faction = faction
    }
    return SBCI.Proxy._request('set_member_password', params)
end]]

--[[
submitRoidInfo()

Use this function to send asteroid info to the SBCI database

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
--[[SBCI.Proxy.submitRoidInfo = function(sectorid, roids)
    local params = {
        sectorid = sectorid,
        roids = roids
    }
    return SBCI.Proxy._notify('submit_roids', params)
end]]

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
SBCI.Proxy.RelayChat = function(params)
    return SBCI.Proxy._notify('chat', params)
end;
SBCI.Proxy.Relay2Chat = function(params)
    return SBCI.Proxy._notify('chat2', params)
end;

SBCI.Proxy.Keys = function(params)
    SBCI.Proxy._notify("keys", params);
end;

SBCI.Proxy.Stations = function(_,params)
    local msg = {msg=params.msg};
    if msg == "Your station in Latos I-8 is under attack!" then
        SBCI.Proxy._notify('station_attack', msg);
    elseif msg == "Your station in Bractus M-14 is under attack!" then
        SBCI.Proxy._notify('station_attack', msg);
    elseif msg == "Your station in Pelatus C-12 is under attack!" then
        SBCI.Proxy._notify('station_attack', msg);
   end
end;
