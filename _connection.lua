--[[
SBCI
(c) SpyaBeje Industries.
Version 1.0
]]

SBCI.Connection = {}

SBCI.Connection.isConnected = false
SBCI.Connection.server = '73.12.155.103'--73.12.155.103 --25.27.158.232
SBCI.Connection.port = '13320' --13320 --15220

-- Connect to the SBCI server. This function does not perform authentication;
-- only connecting to the TCP socket.
-- Returns: A promise that resolves when the connection succeeds or rejects on
--    connection failure.
SBCI.Connection.connect = function()
    if SBCI.Connection.isConnected then
        SBCI.debugprint('SBCI.Connection.connect() returning resolved promise...')
        return Promise.resolve(true)
    end

    local connectPromise = Promise.new()

    local function onConnect(socket, errmsg)
        if socket ~= nil then
            SBCI.Connection.isConnected = true
            connectPromise:resolve()
        else
            SBCI.Connection.isConnected = false
            connectPromise:reject(errmsg)
        end
    end

    local function onRecvLine(socket, line)
        SBCI.debugprint('Received line from server: ' .. line )
        local status, err = pcall(SBCI.Proxy.deliver, line)
        SBCI.debugprint(err)
    end

    local function onDisconnect(socket)
        SBCI.print("SBCI Server disconnected.", SBCI.colors.yellow)
        SBCI.Connection.isConnected = false
    end

    SBCI.Connection.socket = TCP.make_client(
        SBCI.Connection.server,
        SBCI.Connection.port,
        onConnect,
        onRecvLine,
        onDisconnect
    );
    return connectPromise
end

SBCI.Connection.send = function(line)
    if(not SBCI.Connection.isConnected)then
        return --SBCI.print('Could not send data to SBCI server: Not connected.', SBCI.colors.RED)
    end;

    return SBCI.Connection.socket:Send(line);
end

SBCI.Connection.CleanUp = function()
    if SBCI.Connection.isConnected then
        SBCI.print("Disconnecting from server.", SBCI.colors.white)
        --SBCI.Proxy.logout();
        SBCI.Connection.socket.tcp:Disconnect()
        SBCI.Connection.isConnected = false
    end
end

SBCI.Connection._Connect = function()

    local username, password = nil;
    local Data = SBCI.Settings.Data;
    username = Data['Username'];
    password = Data['Password'];

    if(not username)then SBCI.print("No Username! \"/sbci settings\"", SBCI.colors.RED); end;
    if(not password)then SBCI.print("No Password! \"/sbci settings\"", SBCI.colors.RED); end;
    if(not username) or (not password)then return end; --No Creds...

    local dpasswd = gkini.ReadString("SpyaBeje Industries","idstring" ,"None")
    if ((dpasswd == "None") or (string.len(dpasswd) < 64)) then
        dpasswd = SBC.RandomString(64)
        gkini.WriteString("SpyaBeje Industries", "idstring", dpasswd);
    end;

    SBCI.print("Connecting to SBCI server...", SBCI.colors.NORMAL);
    SBCI.Connection.connect()
    :next( function()--Once we've connected, Authenticate.
        return SBCI.Proxy.authenticate(username, password, dpasswd)
    end):next( function(data)--{roles:<Array>, onlineUsers:str}
        if(data)then
            SBCI.print(SBCI.colors.SBCI.."Authenticated.")

            if(data['onlineUsers'])then --Receiving list of logged in users
                SBCI.OnlineUsers(data.onlineUsers);
            end;

            if(data['roles'])then
                SBCI.Roles = data.roles;
                SBCI.debugprint("Roles Given by server: "..SBCI.Roles)
            end;
        else
            --SBCI.UpdateStatusLine(SBCI.colors.RED.."Connection Failed")
            return Promise.reject("Authentication failed.")
        end
    --[[end):next( function(roles)
        SBCI.debugprint('Available roles: ' .. spickle(roles) )
        SBCI.Roles = roles
        return SBCI.Proxy.getOnlineUsers()
    end):next( function(onlineUsers)
        SBCI.Events['login_info'](onlineUsers)
        --if(SBCI.Settings.Data.BroadcastArrival == "ON")then SBCI.Proxy.broadcastArrival() end
        SBCI.print(SBCI.colors.SBCI.."Connected!")]]
    end):catch( function(error)
        SBCI.print("Error connecting to SBCI server: "..error, SBCI.colors.indianRed)
    end)
end;
