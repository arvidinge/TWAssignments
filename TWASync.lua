function TWA.sync.handleLegacyMessage(t, sender)
    -- todo: warn about raid member that has outdated version
    return true
end

local function parseHeaders(message)
    local headersList = string.split(string.split(string.sub(message, 2), ']:')[1], '=')
    local version, conversationId = headersList[1], headersList[2]
    return version, conversationId
end

local function parseMessage(message)
    return string.split(message, ']:')[2]
end

function TWA.sync.parseMessage(_, packet, _, sender)
    if TWA.MESSAGE[string.split(packet, '=')[1]] ~= nil then
        return TWA.sync.handleLegacyMessage(packet, sender)
    end

    local version, conversationId = parseHeaders(packet)
    local msg = parseMessage(packet)
    local parts = string.split(msg, '=')
    local msgType = parts[1]
    local args = TWA.util.tableSlice(parts, 2)

    if msgType == TWA.MESSAGE.LoadTemplate then
        if not args[1] then
            return false
        end
        TWA.loadTemplate(args[2], true)
        return true
    end

    if msgType == TWA.MESSAGE.RosterRequest and sender ~= TWA.me then
        local name = args[1]
        if name == TWA.me then
            TWA.sync.BroadcastRoster(TWA.roster, true, conversationId)
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterRequestHash and sender ~= TWA.me then
        if not args[1] or not args[2] then return false end
        local name = args[1]
        if name ~= TWA.me then return true end

        local theirHash = TWA.util.hexToHash(args[2])
        local myHash = TWA.util.djb2_hash(TWA.SerializeRoster(TWA.roster))

        if theirHash ~= myHash then
            TWA.sync.BroadcastRoster(TWA.roster, true, conversationId)
        end
        return true
    end

    if msgType == TWA.MESSAGE.RequestSync and sender ~= TWA.me then
        twadebug(sender .. ' requested full sync')
        TWA.sync.BroadcastDataHash(conversationId)
        return true
    end

    if msgType == TWA.MESSAGE.FullSync and sender ~= TWA.me then
        if args[1] == 'start' then
            TWA.data = {}
        elseif args[1] == 'end' then
            TWA.fillRaidData()
            TWA.PopulateTWA()
            if not TWA._firstSyncComplete then
                twaprint('Full sync complete')
                TWA._firstSyncComplete = true
            end
        else
            if args[1] and args[2] and args[3] and args[4] and args[5] and args[6] and args[7] then
                local index = table.getn(TWA.data) + 1
                TWA.data[index] = {}
                TWA.data[index][1] = args[1]
                TWA.data[index][2] = args[2]
                TWA.data[index][3] = args[3]
                TWA.data[index][4] = args[4]
                TWA.data[index][5] = args[5]
                TWA.data[index][6] = args[6]
                TWA.data[index][7] = args[7]
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterBroadcastPartial and sender ~= TWA.me then
        if args[1] == 'start' then
            -- todo: could add some handling for simultaneous incoming broadcasts:
            -- add to list of incoming broadcasts
        elseif args[1] == 'end' then
            -- remove from list of incoming broadcasts
            -- only if list of broadcasts is empty, run the following stuff:
            TWA.fillRaidData()
            TWA.PopulateTWA()
            TWA.persistForeignRosters()
        else
            local class = args[1]
            local names = string.split(args[3], ',')
            for _, name in ipairs(names) do
                TWA.addToForeignRoster(sender, class, name)
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterBroadcastFull and sender ~= TWA.me then
        if args[1] == 'start' then
            TWA.foreignRosters[sender] = nil
            -- todo: could add some handling for simultaneous incoming broadcasts:
            -- add to list of incoming broadcasts
        elseif args[1] == 'end' then
            -- remove from list of incoming broadcasts
            -- only if list of broadcasts is empty, run the following stuff:
            TWA.fillRaidData()
            TWA.PopulateTWA()
            TWA.persistForeignRosters()
        else
            local class = args[1]
            local names = string.split(args[2], ',')
            for _, name in ipairs(names) do
                TWA.addToForeignRoster(sender, class, name)
            end
        end
        return true
    end

    if msgType == TWA.MESSAGE.RosterEntryDeleted and sender ~= TWA.me then
        local class = args[1]
        local name = args[2]

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
        if not args[1] then
            return false
        end
        if not tonumber(args[1]) then
            return false
        end

        TWA.RemRow(tonumber(args[1]), sender)
        return true
    end

    if msgType == TWA.MESSAGE.ChangeCell then
        if not args[1] or not args[2] or not args[3] then
            return false
        end
        if not tonumber(args[1]) or not args[2] or not args[3] then
            return false
        end

        TWA.change(tonumber(args[1]), args[2], sender, args[3] == '1')
        return true
    end

    if msgType == TWA.MESSAGE.WipeTable then
        if TWA.isPlayerLeadOrAssist(sender) then
            TWA.WipeTable()
        end
        return true
    end

    if msgType == TWA.MESSAGE.Reset then
        TWA.Reset()
        return true
    end

    if msgType == TWA.MESSAGE.AddLine then
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

function TWA.sync.BroadcastDataHash(conversationId)
    local hex = TWA.util.hashToHex(TWA.util.djb2_hash(TWA.SerializeData()))
    TWA.sync.SendAddonMessage({ text = "DataHash=" .. hex, conversationId = conversationId })
end

---As a non-leader, request full sync of data (when you join the group for example)
function TWA.sync.RequestFullSync()
    twadebug('i request sync')
    twaprint('Requesting full sync of data...')
    TWA.sync.SendAddonMessage(TWA.MESSAGE.RequestSync .. "=" .. TWA.me)
end

---As a leader, broadcast a full sync of data (when a player requests it, or the group is converted from party to raid).
---Does nothing if not a raid leader.
---@param conversationId string|nil Provide if broadcasting as part of conversation
function TWA.sync.BroadcastFullSync(conversationId)
    if not IsRaidLeader() then return end
    conversationId = conversationId and conversationId or TWA.sync.newConversationId()
    twadebug('i broadcast sync')
    TWA.sync.SendAddonMessage({
        text = TWA.MESSAGE.FullSync .. "=start",
        conversationId = conversationId
    })
    for _, data in next, TWA.data do
        TWA.sync.SendAddonMessage({
            text = TWA.MESSAGE.FullSync .. "=" ..
                data[1] .. '=' ..
                data[2] .. '=' ..
                data[3] .. '=' ..
                data[4] .. '=' ..
                data[5] .. '=' ..
                data[6] .. '=' ..
                data[7],
            conversationId = conversationId
        })
    end

    TWA.sync.SendAddonMessage({
        text = TWA.MESSAGE.FullSync .. "=end",
        conversationId = conversationId
    })
end

---Call to share your roster with other players. You can pass partial rosters when adding new names to save on bandwidth.
---Only works in raid and if you are either assistant or leader. (noop otherwise)
---@param roster TWARoster The roster to broadcast
---@param full boolean Pass true if you're broadcasting your full roster (recipients will wipe your existing roster). False if partial roster (when adding single entries).
---@param conversationId string|nil Provide if broadcasting as part of conversation
function TWA.sync.BroadcastRoster(roster, full, conversationId)
    if full == nil then error("Argument 'full' is required and cannot be nil", 2) end
    if not TWA.InRaid() and not (IsRaidLeader() or IsRaidOfficer()) then return end

    conversationId = conversationId and conversationId or TWA.sync.newConversationId()
    local broadcasttype = full and TWA.MESSAGE.RosterBroadcastFull or TWA.MESSAGE.RosterBroadcastPartial
    TWA.sync.SendAddonMessage({
        text = broadcasttype .. "=start",
        conversationId = conversationId
    })

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
        TWA.sync.SendAddonMessage({
            text = broadcasttype .. "=" .. class .. "=" .. namesSerialized,
            conversationId = conversationId
        })
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

    TWA.sync.SendAddonMessage({
        text = broadcasttype .. "=end",
        conversationId = conversationId
    })
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
        TWA.sync.SendAddonMessage({text = TWA.MESSAGE.RosterRequestHash .. "=" .. assistant .. "=" .. hash})
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
---This version does not wrap the message with headers; it is intended for communicating with old clients that did not make use of headers.
---<br/>
---Also takes an optional callback function, invoked when the message has been received by the player that sent it.
---@param text string
---@param prefix string|nil Default "TWA"
---@param prio "BULK"|"NORMAL"|"ALERT"|nil Default "ALERT". Seems like only ALERT guarantees order.
---@param chattype "PARTY"|"RAID"|"GUILD"|"OFFICER"|"BATTLEGROUND"|nil Default "RAID"
---@param callbackFn function|nil Optional callback when message has been sent (checks for loopback).
function TWA.sync.SendAddonMessage_LEGACY(text, prefix, prio, chattype, callbackFn)
    prefix = prefix and prefix or "TWA"
    prio = prio and prio or "ALERT"
    chattype = chattype and chattype or "RAID"

    ChatThrottleLib:SendAddonMessage(prio, prefix, text, chattype)
end

function TWA.sync.newConversationId()
    return TWA.util.hashToHex(TWA.util.djb2_hash(TWA.util.uuid()))
end

---Wrapper around ChatThrottleLib:SendAddonMessage, but most parameters optional to clean up code.
---<br/>
---Also takes an optional callback function, invoked when the message has been received by the player that sent it.
---@param arg string|TWASendAddonMessageArgs Either provide just the message as a string, or provide a table if you want to overwrite defaults of the optional values.
function TWA.sync.SendAddonMessage(arg)
    -- set defaults
    local text = arg
    local prefix = "TWA";
    local prio = "ALERT";
    local chattype = "RAID";
    local conversationId = TWA.sync.newConversationId();

    -- overwrite with table values if arg is table
    if type(arg) == "table" then
        text = arg.text and arg.text or text
        prefix = arg.prefix and arg.prefix or prefix
        prio = arg.prio and arg.prio or prio
        chattype = arg.chattype and arg.chattype or chattype
        conversationId = arg.conversationId and arg.conversationId or conversationId
    end

    local addonVersion = TWA.version;
    local headers = {}
    table.insert(headers, addonVersion)
    table.insert(headers, conversationId)
    table.insert(headers, '-') -- reserved for future use
    table.insert(headers, '-') -- reserved for future use
    table.insert(headers, '-') -- reserved for future use

    local headerN = table.getn(headers)
    local finalMessage = '['
    for i, header in ipairs(headers) do
        finalMessage = finalMessage .. header .. (i < headerN and '=' or '')
    end
    finalMessage = finalMessage .. ']:' .. text

    ChatThrottleLib:SendAddonMessage(prio, prefix, finalMessage, chattype)
end
