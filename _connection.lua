--[[
TBS
(c) SpyaBeje Industries.
Version 1.0
]]

TBS.Connection = {}

TBS.Connection.isConnected = false
TBS.Connection.server = '73.12.155.103'--73.12.155.103 --25.27.158.232
TBS.Connection.port = '27480' --27480 --15220

-- Connect to the TBS server. This function does not perform authentication;
-- only connecting to the TCP socket.
-- Returns: A promise that resolves when the connection succeeds or rejects on
--    connection failure.
TBS.Connection.connect = function()
    if TBS.Connection.isConnected then
        TBS.debugprint('TBS.Connection.connect() returning resolved promise...')
        return Promise.resolve(true)
    end

    local connectPromise = Promise.new()

    local function onConnect(socket, errmsg)
        if socket ~= nil then
            TBS.Connection.isConnected = true
            connectPromise:resolve()
        else
            TBS.Connection.isConnected = false
            connectPromise:reject(errmsg)
        end
    end

    local function onRecvLine(socket, line)
        TBS.debugprint('Received line from server: ' .. line )
        local status, err = pcall(TBS.Proxy.deliver, line)
        TBS.debugprint(err)
    end

    local function onDisconnect(socket)
        TBS.print("TBS Server disconnected.", TBS.colors.yellow)
        TBS.Connection.isConnected = false
    end

    TBS.Connection.socket = TCP.make_client(
        TBS.Connection.server,
        TBS.Connection.port,
        onConnect,
        onRecvLine,
        onDisconnect
    );
    return connectPromise
end

TBS.Connection.send = function(line)
    if(not TBS.Connection.isConnected)then
        return --TBS.print('Could not send data to TBS server: Not connected.', TBS.colors.RED)
    end;

    return TBS.Connection.socket:Send(line);
end

TBS.Connection.CleanUp = function()
    if TBS.Connection.isConnected then
        TBS.print("Disconnecting from server.", TBS.colors.white)
        --TBS.Proxy.logout();
        TBS.Connection.socket.tcp:Disconnect()
        TBS.Connection.isConnected = false
    end
end

TBS.Connection._Connect = function()

    local username, password = nil;
    local Data = TBS.Settings.Data;
    username = Data['Username'];
    password = Data['Password'];

    if(not username)then TBS.print("No Username! \"/tbs settings\"", TBS.colors.RED); end;
    if(not password)then TBS.print("No Password! \"/tbs settings\"", TBS.colors.RED); end;
    if(not username) or (not password)then return end; --No Creds...

    TBS.print("Connecting to TBS server...", TBS.colors.normal);
    TBS.Connection.connect()
    :next( function()--Once we've connected, Authenticate.
        return TBS.Proxy.authenticate(username, password)
    end):next( function(data)--{roles:<Array>, onlineUsers:str}
        if(data and not data.error)then
            TBS.print(TBS.colors.TBS.."Authenticated.")

            if(data['onlineUsers'])then --Receiving list of logged in users
                TBS.OnlineUsers(data.onlineUsers);
            end;

            if(data['roles'])then
                TBS.Roles = data.roles;
                TBS.debugprint("Roles Given by server: "..table.concat(TBS.Roles,", "))
            end;

            if(data['allStats'])then
                local txt = "";
                local stats = data['allStats'];

                for _, status in pairs(stats) do
                    TBS.standings[status.id] = status.name;
                    TBS.colors.radar[status.id] = status.rgb;
                    TBS.colors.standings[status.id] = "\127"..status.hex;

                    txt = txt.."["..status.id.."] = \""..status.name.."\"";
                end;

                TBS.debugprint("Status's given by server: "..txt);
            end;
        elseif(data and data.error)then

                TBS.print('@indianRed@'..data.error.type..": @white@"..data.error.message);

        else
            --TBS.UpdateStatusLine(TBS.colors.RED.."Connection Failed")
            return Promise.reject("Authentication failed.")
        end
    --[[end):next( function(roles)
        TBS.debugprint('Available roles: ' .. spickle(roles) )
        TBS.Roles = roles
        return TBS.Proxy.getOnlineUsers()
    end):next( function(onlineUsers)
        TBS.Events['login_info'](onlineUsers)
        --if(TBS.Settings.Data.BroadcastArrival == "ON")then TBS.Proxy.broadcastArrival() end
        TBS.print(TBS.colors.TBS.."Connected!")]]
    end):catch( function(error)
        local msg = "";
        if(error.code)then
            msg = "@indianRed@Internal server error: "..error.code.." - "..error.message;
        else
            msg = "@indianRed@Error connecting to TBS server: "..error;
        end

        TBS.print(msg)
    end)
end;
