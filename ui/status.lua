TBS.UIStatus = {};

function TBS.UIStatus:createUI()
    local p = Promise.new()

    TBS.Proxy.getAllStatus():next( function(statuses)
        local playerLabel = iup.label{title='Players:'}
        local playerEntry = iup.text{value="", expand="YES", size="80x"}
        local guildLabel = iup.label{title='Guilds:'}
        local guildEntry = iup.text{value="", expand="YES", size="80x"}

        local statusToggles = {}
        local friendly_togglesVbox = iup.vbox{}
        local hostile_togglesVbox = iup.vbox{}

        for i,v in pairs(statuses) do
            statusToggles[i] = iup.stationtoggle{ title=v[2], value='OFF' }
            if(v[1] > 0)then
                iup.Append(friendly_togglesVbox, statusToggles[i])
            else
                iup.Append(hostile_togglesVbox, statusToggles[i])
            end
        end



        -- Create a vbox with the toggle switches

        local container = iup.vbox{
            iup.label{title="Seperate entires with ;"},
            iup.vbox{
                iup.hbox{ playerLabel, playerEntry },
                iup.hbox{ guildLabel, guildEntry },
            },
            iup.fill{size=3},
            iup.label{title="Select a single status:"},
            iup.hbox{ friendly_togglesVbox, iup.fill{size=7}, hostile_togglesVbox },
            iup.fill{size=5},
            iup.stationtoggle{ title="Protected?", value="OFF", align="ACENTER" }
        }
        local dialog = {}
        dialog = TBS.UI.createOkCancelDialog(
            'Update Status',
            container,
            function()
                TBS.debugprint('OK clicked.')
                TBS.debugprint('Username: ' .. usernameEntry.value)

                local status = {}
                for _,v in ipairs(statusToggles) do
                    TBS.debugprint(v.title .. ":" .. v.value)
                    if v.value == 'ON' then
                        table.insert(status, v.title)
                    end
                end

                if #usernameEntry.value == 0 then
                    local err_dialog = TBS.UI.createMessageDialog(
                        "ERROR",
                        "Please enter a quoted player name, or a unquoted guildtag.\nSeperate multiple entries with comas. ( , )")
                    ShowDialog(err_dialog)
                    return
                end

                if #status == 0 or #status > 1 then
                    local err_dialog = TBS.UI.createMessageDialog(
                        "ERROR",
                        "Please select 1 status.")
                    ShowDialog(err_dialog)
                    return
                end

                HideDialog(dialog)

                -- Ok, we have the new user's username and roles. Time to get a
                -- new authcode from the server...

                --[[TBS.Proxy.updateStatus(usernameEntry.value, memberRoles):next( function(authCode)

                end)]]
            end,
            function()
                TBS.debugprint('Dialog Cancelled.')
                HideDialog(dialog)
            end
        )
        p:resolve(dialog)
    end)
    return p
end;

function TBS.UIStatus:showDialog()
    local fut_dialog = self:createUI()
    fut_dialog:next( function(dialog)
        PopupDialog(dialog, iup.CENTER, iup.CENTER)
    end)
end
