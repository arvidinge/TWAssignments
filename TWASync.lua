function TWA.sync.handleSync(_, t, _, sender)
    local msgType = string.split(t, '=')[1]
    -- twadebug('message type is first?: ' .. tostring(TWA.MESSAGE[string.split(t, '=')[1]] ~= nil))

    if msgType == TWA.MESSAGE.LoadTemplate then
        local args = string.split(t, '=')
        if not args[2] then
            return false
        end
        TWA.loadTemplate(args[2], true)
        return true
    end

    if msgType == TWA.MESSAGE.RosterRequest and sender ~= TWA.me then
        local args = string.split(t, '=')
        local name = args[2]
        if name == TWA.me then
            TWA.sync.BroadcastRoster(TWA.roster, true)
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterRequestHash and sender ~= TWA.me then
        local args = string.split(t, '=')
        if not args[2] or not args[3] then return false end
        local name = args[2]
        if name ~= TWA.me then return true end

        local theirHash = TWA.util.hexToHash(args[3])
        local myHash = TWA.util.djb2_hash(TWA.SerializeRoster(TWA.roster))

        if theirHash ~= myHash then
            TWA.sync.BroadcastRoster(TWA.roster, true)
        end
        return true
    end

    if msgType == TWA.MESSAGE.RequestSync and sender ~= TWA.me then
        twadebug(sender .. ' requested full sync')
        if IsRaidLeader() then TWA.sync.BroadcastFullSync() end
        return true
    end

    if msgType == TWA.MESSAGE.FullSync and sender ~= TWA.me then
        local args = string.split(t, '=')
        if args[2] == 'start' then
            TWA.data = {}
        elseif args[2] == 'end' then
            TWA.fillRaidData()
            TWA.PopulateTWA()
            if not TWA._firstSyncComplete then
                twaprint('Full sync complete')
                TWA._firstSyncComplete = true
            end
            TWA.persistForeignRosters()
        elseif args[2] == '#roster' then
            local class = args[3]
            local names = string.split(args[4], ',')
            for _, name in ipairs(names) do
                TWA.addToForeignRoster(sender, class, name)
            end
        else
            if args[2] and args[3] and args[4] and args[5] and args[6] and args[7] and args[8] then
                local index = table.getn(TWA.data) + 1
                TWA.data[index] = {}
                TWA.data[index][1] = args[2]
                TWA.data[index][2] = args[3]
                TWA.data[index][3] = args[4]
                TWA.data[index][4] = args[5]
                TWA.data[index][5] = args[6]
                TWA.data[index][6] = args[7]
                TWA.data[index][7] = args[8]
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterBroadcastPartial and sender ~= TWA.me then
        local args = string.split(t, '=')
        if args[2] == 'start' then
            -- todo: could add some handling for simultaneous incoming broadcasts:
            -- add to list of incoming broadcasts
        elseif args[2] == 'end' then
            -- remove from list of incoming broadcasts
            -- only if list of broadcasts is empty, run the following stuff:
            TWA.fillRaidData()
            TWA.PopulateTWA()
            TWA.persistForeignRosters()
        else
            local class = args[2]
            local names = string.split(args[3], ',')
            for _, name in ipairs(names) do
                TWA.addToForeignRoster(sender, class, name)
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterBroadcastFull and sender ~= TWA.me then
        local args = string.split(t, '=')
        if args[2] == 'start' then
            TWA.foreignRosters[sender] = nil
            -- todo: could add some handling for simultaneous incoming broadcasts:
            -- add to list of incoming broadcasts
        elseif args[2] == 'end' then
            -- remove from list of incoming broadcasts
            -- only if list of broadcasts is empty, run the following stuff:
            TWA.fillRaidData()
            TWA.PopulateTWA()
            TWA.persistForeignRosters()
        else
            local class = args[2]
            local names = string.split(args[3], ',')
            for _, name in ipairs(names) do
                TWA.addToForeignRoster(sender, class, name)
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterEntryDeleted and sender ~= TWA.me then
        local args = string.split(t, '=')
        local class = args[2]
        local name = args[3]

        if TWA.foreignRosters[sender] ~= nil then
            if TWA.foreignRosters[sender][class] ~= nil then
                local nameIndex = TWA.util.tablePosOf(TWA.foreignRosters[sender][class], name)
                if nameIndex ~= nil then
                    table.remove(TWA.foreignRosters[sender][class], nameIndex)
                    TWA.fillRaidData()
                    TWA.PopulateTWA()
                    TWA.persistForeignRosters()
                end
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RemRow then
        local rowEx = string.split(t, '=')
        if not rowEx[2] then
            return false
        end
        if not tonumber(rowEx[2]) then
            return false
        end

        TWA.RemRow(tonumber(rowEx[2]), sender)
        return true
    end

    if msgType == TWA.MESSAGE.ChangeCell then
        local changeEx = string.split(t, '=')
        if not changeEx[2] or not changeEx[3] or not changeEx[4] then
            return false
        end
        if not tonumber(changeEx[2]) or not changeEx[3] or not changeEx[4] then
            return false
        end

        TWA.change(tonumber(changeEx[2]), changeEx[3], sender, changeEx[4] == '1')
        return true
    end

    if string.find(t, 'WipeTable', 1, true) then
        if TWA.isPlayerLeadOrAssist(sender) then
            TWA.WipeTable()
        end
        return true
    end

    if string.find(t, 'Reset', 1, true) then
        TWA.Reset()
        return true
    end

    if string.find(t, 'AddLine', 1, true) then
        TWA.AddLine()
        return true
    end
end

function TWA.sync.handleQHSync(pre, t, ch, sender)
    if sender ~= TWA.me then
        local roster
        local tanks = 'Tanks='
        local healers = 'Healers='

        if string.find(t, 'RequestRoster', 1, true) then -- QH roster request
            for index, data in next, TWA.data do         -- build roster string
                for i, name in data do
                    if i == 2 or i == 3 or i == 4 then
                        if name ~= '-' then
                            if string.len(tanks) == 6 then -- skip ',' delimiter if this is the first tank entry
                                tanks = tanks .. name
                            else
                                tanks = tanks .. "," .. name
                            end
                        end
                    end
                    if i == 5 or i == 6 or i == 7 then
                        if name ~= '-' then
                            if string.len(healers) == 8 then -- skip ',' delimiter if this is the first healer entry
                                healers = healers .. name
                            else
                                healers = healers .. "," .. name
                            end
                        end
                    end
                end
            end
            roster = tanks .. ";" .. healers;
            TWA.sync.SendAddonMessage(roster) -- transmit roster
        end
    end
end

function TWA.sync.BroadcastDataHash()
    local hex = TWA.util.hashToHex(TWA.util.djb2_hash(TWA.SerializeData()))
    TWA.sync.SendAddonMessage("DataHash=" .. hex)
end

---As a non-leader, request full sync of data (when you join the group for example)
function TWA.sync.RequestFullSync()
    twadebug('i request sync')
    twaprint('Requesting full sync of data...')
    TWA.sync.SendAddonMessage(TWA.MESSAGE.RequestSync .. "=" .. TWA.me)
end

---As a leader, broadcast a full sync of data (when a player requests it, or the group is converted from party to raid).
---Does nothing if not a raid leader.
function TWA.sync.BroadcastFullSync()
    if not IsRaidLeader() then return end
    twadebug('i broadcast sync')
    TWA.sync.SendAddonMessage(TWA.MESSAGE.FullSync .. "=start")
    for _, data in next, TWA.data do
        TWA.sync.SendAddonMessage(TWA.MESSAGE.FullSync .. "=" ..
            data[1] .. '=' ..
            data[2] .. '=' ..
            data[3] .. '=' ..
            data[4] .. '=' ..
            data[5] .. '=' ..
            data[6] .. '=' ..
            data[7])
    end

    TWA.sync.SendAddonMessage(TWA.MESSAGE.FullSync .. "=end")
end

---Call to share your roster with other players. You can pass partial rosters when adding new names to save on bandwidth.
---Only works in raid and if you are either assistant or leader. (noop otherwise)
---@param roster TWARoster The roster to broadcast
---@param full boolean Pass true if you're broadcasting your full roster (recipients will wipe your existing roster). False if partial roster (when adding single entries).
function TWA.sync.BroadcastRoster(roster, full)
    if full == nil then error("Argument 'full' is required and cannot be nil", 2) end
    if not TWA.InRaid() and not (IsRaidLeader() or IsRaidOfficer()) then return end

    local broadcasttype = full and TWA.MESSAGE.RosterBroadcastFull or TWA.MESSAGE.RosterBroadcastPartial
    TWA.sync.SendAddonMessage(broadcasttype .. "=start")

    ---@param class string
    ---@param names table<integer, string>
    local sendNames = function(class, names)
        local namesSerialized = ''
        for _, name in ipairs(names) do
            if string.len(namesSerialized) > 0 then
                namesSerialized = namesSerialized .. ',' .. name
            else
                namesSerialized = name
            end
        end
        TWA.sync.SendAddonMessage(broadcasttype .. "=" .. class .. "=" .. namesSerialized)
    end

    for class, _ in pairs(roster) do
        if table.getn(roster[class]) > 0 then
            local curNames = {}
            for _, name in pairs(roster[class]) do
                table.insert(curNames, name)
                if table.getn(curNames) >= TWA.MAX_NAMES_PER_MESSAGE then
                    sendNames(class, curNames)
                    curNames = {}
                end
            end
            sendNames(class, curNames)
        end
    end

    TWA.sync.SendAddonMessage(broadcasttype .. "=end")
end

---Call to share that you've deleted a member of your roster.
---Only works in raid and if you are either assistant or leader. (noop otherwise)
---@param class TWAWowClass
---@param name string
function TWA.sync.BroadcastRosterEntryDeleted(class, name)
    if not TWA.InRaid() and not (IsRaidLeader() or IsRaidOfficer()) then return end
    TWA.sync.SendAddonMessage(TWA.MESSAGE.RosterEntryDeleted .. "=" .. class .. "=" .. name)
end

function TWA.sync.BroadcastWipeTable()
    TWA.sync.SendAddonMessage(TWA.MESSAGE.WipeTable)
end

--- Requests all assistant rosters in the raid by broadcasting hashes.
--- <br/>
--- The function hashes the rosters of all current assistants and broadcasts the hashes
--- to the raid. If an assistant receives an incorrect hash of their roster, they will
--- broadcast their roster.
--- <br/>
--- It also handles the case where rosters for certain assistants are missing by
--- directly requesting their rosters.
function TWA.sync.RequestAssistantRosters()
    if not (TWA.InRaid()) then return end

    ---@type table<string, string>
    local hashes = {}

    -- hash all the rosters you currently have
    for assistant, roster in pairs(TWA.foreignRosters) do
        if roster ~= nil then
            hashes[assistant] = TWA.util.hashToHex(TWA.util.djb2_hash(TWA.SerializeRoster(roster)))
        end
    end

    -- broadcast the hashes. if the hash is not correct, the assistant will respond with their roster.
    for assistant, hash in pairs(hashes) do
        TWA.sync.SendAddonMessage(TWA.MESSAGE.RosterRequestHash .. "=" .. assistant .. "=" .. hash)
    end

    -- if you dont have an assistant's roster at all, request the roster directly
    for i = 1, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local name, rank, _, _, _, _, z = GetRaidRosterInfo(i);
            if name ~= TWA.me and (rank == 1 or rank == 2) and hashes[name] == nil then
                TWA.sync.SendAddonMessage(TWA.MESSAGE.RosterRequest .. "=" .. name)
            end
        end
    end
end

---Wrapper around ChatThrottleLib:SendAddonMessage, but most parameters optional to clean up code.
---<br/>
---Also takes an optional callback function, invoked when the message has been received by the player that sent it.
---@param text string
---@param prefix string|nil Default "TWA"
---@param prio "BULK"|"NORMAL"|"ALERT"|nil Default "ALERT". Seems like only ALERT guarantees order.
---@param chattype "PARTY"|"RAID"|"GUILD"|"OFFICER"|"BATTLEGROUND"|nil Default "RAID"
---@param callbackFn function|nil Optional callback when message goes out the wire.
function TWA.sync.SendAddonMessage(text, prefix, prio, chattype, callbackFn)
    prefix = prefix and prefix or "TWA"
    prio = prio and prio or "ALERT"
    chattype = chattype and chattype or "RAID"

    ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype)
end
