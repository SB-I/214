
TBS.UI = {}

TBS.UI.createOkCancelDialog = function(header, childContents, onOk, onCancel)
    if(header)then
        iup.vbox{ iup.label{title = header}, iup.fill{size=3} };
    else
        header = "";
    end;

    local container = iup.vbox{
        header,
        childContents,
        iup.fill{size=3},
        iup.hbox{
            iup.fill{expand="YES"},
            iup.stationbutton{
                title="Cancel",
                action=function(self) if onCancel ~= nil then onCancel(self) end end
            },
            iup.stationbutton{
                title="OK",
                action=function(self) if onOk ~= nil then onOk(self) end end
            },
            expand="HORIZONTAL",
            alignment="RIGHT"
        },
        expand="YES"
    }
    -- If we are not in a station, we need to do some special stuff to the dialog
    if PlayerInStation() then
        TBS.debugprint("Creating in-station dialog...")
        local dialog = iup.dialog{
            container,
            modal="YES"
        }
        return dialog
    else
        TBS.debugprint("Creating out-of-station dialog...")
        local dialog = iup.dialog{
            iup.stationhighopacityframe{
                iup.stationhighopacityframebg{
                    container
                }
            },
            title=header,
            BORDER="YES",
            TOPMOST="YES"
        }
        return dialog
    end
end

TBS.UI.createMessageDialog = function(title, message)
    local dialog = {}
    local container = iup.vbox{
        iup.label{title=title},
        iup.fill{size=10},
        iup.label{title=message},
        iup.stationbutton{
            title="Close",
            action=function(self) HideDialog(dialog) end
        }
    }
    dialog = iup.dialog{container, modal="YES"}
    return dialog
end
