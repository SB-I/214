

TBS.vokeys = {};
function TBS.vokeys.IssuingKeysCB(err,result)
    if err then
        if not (result == "That player already has that key.") then
            vokeys.msg(vokeys.colors.white,"Result: "..result)
            end
        end
    end


    function TBS.vokeys.GetKeySlot(keynum)
        for i = 1, GetNumKeysInKeychain(), 1 do
            LK_keyid, LK_description, LK_owner, LK_timestamp, LK_access, LK_possessors, LK_active = GetKeyInfo(i)
            if (tonumber(LK_keyid) == tonumber(keynum)) then return i end
        end
    return -1 -- Not found in the list
    end
