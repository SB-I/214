SBCI.UIRegisterUser = {}
-- Create the UI element. Returns a promise that resolves when complete
function SBCI.UIRegisterUser:createUI()
    local p = Promise.new()
    SBCI.Proxy.getAllRoles():next( function(roles)
        SBCI.debugprint('Got roles from server.')

        local userLabel = iup.label{title='Username:'}
        local usernameEntry = iup.text{value="", expand="YES", size="80x"}

        local roleToggles = {}
        local togglesVbox = iup.vbox{}
        for i,v in ipairs(roles) do
            roleToggles[i] = iup.stationtoggle{ title=v, value='OFF' }
            iup.Append(togglesVbox, roleToggles[i])
        end

        -- Create a vbox with the toggle switches

        local container = iup.vbox{
            iup.hbox{ userLabel, usernameEntry },
            iup.fill{size=3},
            iup.label{title='Select new member roles:'},
            togglesVbox
        }
        local dialog = {}
        dialog = SBCI.UI.createOkCancelDialog(
            'Register New SBCI User',
            container,
            function()
                SBCI.debugprint('OK clicked.')
                SBCI.debugprint('Username: ' .. usernameEntry.value)

                local memberRoles = {}
                for _,v in ipairs(roleToggles) do
                    SBCI.debugprint(v.title .. ":" .. v.value)
                    if v.value == 'ON' then
                        table.insert(memberRoles, v.title)
                    end
                end

                if #usernameEntry.value == 0 then
                    local err_dialog = SBCI.UI.createMessageDialog(
                        "ERROR",
                        "Please enter a username.")
                    ShowDialog(err_dialog)
                    return
                end

                if #memberRoles == 0 then
                    local err_dialog = SBCI.UI.createMessageDialog(
                        "ERROR",
                        "Please select at least 1 role.")
                    ShowDialog(err_dialog)
                    return
                end

                HideDialog(dialog)

                -- Ok, we have the new user's username and roles. Time to get a
                -- new authcode from the server...

                SBCI.Proxy.registerNewUser(usernameEntry.value, memberRoles):next( function(authCode)
                    -- Now we should send the auth-code to the new user.
                    print('Sending auth code "'..authCode..'" to user: '..usernameEntry.value)
                    local message = "Hello " .. usernameEntry.value .. ". You have been invited to join SBCI. Your auth code is: " .. authCode .. ". Please download SBCI from XXX and use this auth code to create a new account."
                    SendChat(message, "PRIVATE", usernameEntry.value)
                end)
            end,
            function()
                SBCI.debugprint('Dialog Cancelled.')
                HideDialog(dialog)
            end
            )
        p:resolve(dialog)
    end)
    return p
end

function SBCI.UIRegisterUser:showDialog()
    local fut_dialog = self:createUI()
    fut_dialog:next( function(dialog)
        PopupDialog(dialog, iup.CENTER, iup.CENTER)
    end)
end
