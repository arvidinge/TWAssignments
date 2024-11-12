function TWA.sync.processMessage_LEGACY(message, sender)
    -- todo: warn about raid member that has outdated version. show suggestion to force sync for them.
    return true
end

---Extracts the headers from a packet
---@param strPacket string
---@return TWAPacketHeaders headers The parsed headers of the packet.
local function getHeaders(strPacket)
    local headersList = string.split(string.split(string.sub(strPacket, 2), ']:')[1], '=')
    ---@type TWAPacketHeaders
    return {
        version = headersList[1],
        messageId = headersList[2],
        conversationId = headersList[3],
        RESERVED_1 = headersList[4],
        RESERVED_2 = headersList[5],
        RESERVED_3 = headersList[6]
    }
end

---Extracts the message from a packet
local function getMessage(packet)
    return string.split(packet, ']:')[2]
end

---comment
---@param strPacket any
---@return TWAPacket packet
local function parseStrPacket(strPacket)
    local headersList = string.split(string.split(string.sub(strPacket, 2), ']:')[1], '=')
    ---@type TWAPacketHeaders
    local headers = {
        version = headersList[1],
        messageId = headersList[2],
        conversationId = headersList[3],
        RESERVED_1 = headersList[4],
        RESERVED_2 = headersList[5],
        RESERVED_3 = headersList[6]
    }

    local msg = string.split(strPacket, ']:')[2]
    local parts = string.split(msg, '=')
    local msgType = parts[1]
    local args = TWA.util.tableSlice(parts, 2)

    ---@type TWAPacketMessage
    local message = {
        type = msgType,
        args = args
    }

    ---@type TWAPacket
    return {
        headers = headers,
        message = message
    }
end

function TWA.sync.processPacket(_, strPacket, _, sender)
    if TWA.MESSAGE[string.split(strPacket, '=')[1]] ~= nil then
        return TWA.sync.processMessage_LEGACY(strPacket, sender)
    end

    ---@type TWAPacket
    local packet = parseStrPacket(strPacket)
    local headers = packet.headers
    local msgType = packet.message.type
    local args = packet.message.args

    if TWA._messageCallbacks[headers.messageId] then
        TWA._messageCallbacks[headers.messageId](packet)
    end

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
            TWA.sync.BroadcastRoster(TWA.roster, true, headers.conversationId)
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
            TWA.sync.BroadcastRoster(TWA.roster, true, headers.conversationId)
        end
        return true
    end

    if msgType == TWA.MESSAGE.DataHash then
        local hash = args[1]
        if not TWA._syncConversations[headers.conversationId] then return end -- i didnt start this conversation
        if not TWA._syncConversations[headers.conversationId][hash] then
            TWA._syncConversations[headers.conversationId][hash] = {}
        end
        table.insert(TWA._syncConversations[headers.conversationId][hash], sender)
        -- todo handle sync timeout and then select player to broadcast from hashes
    end

    if msgType == TWA.MESSAGE.RequestSync then
        twadebug(sender .. ' requested full sync')
        TWA.sync.BroadcastDataHash(headers.conversationId)
        return true
    end

    if msgType == TWA.MESSAGE.SyncPlayerSelected and args[1] == TWA.me then
        TWA.sync.BroadcastFullSync(headers.conversationId)
    end

    if msgType == TWA.MESSAGE.FullSync and sender ~= TWA.me then
        if args[1] == 'start' then
            TWA.data = {}
        elseif args[1] == 'end' then
            TWA.fillRaidData()
            TWA.PopulateTWA()
            if TWA._syncConversations[headers.conversationId] then
                TWA._syncConversations[headers.conversationId] = nil;
                twaprint('Full sync complete')
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
    local hex = TWA.util.hashToHex(TWA.util.djb2_hash(TWA.SerializeCurrentData()))

    TWA.sync.SendAddonMessage({
        text = TWA.MESSAGE.DataHash .. "=" .. hex,
        conversationId = conversationId
    })
end

---Acknowledge that everyone had the correct hash and that no player will be selected to broadcast a full sync.
function TWA.sync.ConcludeSync(conversationId)
    TWA.sync.SendAddonMessage({
        text = TWA.MESSAGE.ConcludeSync,
        conversationId = conversationId
    })
end

---Ask a player that has the correct hash to broadcast full sync.
function TWA.sync.SelectPlayerToSync(player, conversationId)
    local debug = function(str) twadebug('cid ' .. conversationId .. ': ' .. str) end
    debug('selected player ' .. player .. ' for sync')

    TWA.sync.SendAddonMessage({
        text = TWA.MESSAGE.SyncPlayerSelected .. "=" .. player,
        conversationId = conversationId
    })
end

---Initiate a full sync (when you join the group for example)
function TWA.sync.RequestFullSync()
    twadebug('i request sync')
    local conversationId = TWA.sync.newId()
    twaprint('Requesting full sync of data...')
    TWA._syncConversations[conversationId] = {}
    TWA.sync.SendAddonMessage({
        text = TWA.MESSAGE.RequestSync .. "=" .. TWA.me,
        conversationId = conversationId,
        callbackFn = function(packet)
            local debug = function(str) twadebug('cid ' .. conversationId .. ': ' .. str) end
            debug('sync request initiated. timeout in ' .. TWA.SYNC_REQUEST_TIMEOUT .. ' seconds.')
            TWA.syncRequestTimeouts[conversationId] = TWA.timeout.set(function()
                debug('sync request timeout')

                local totalHashes = 0
                for _, _ in pairs(TWA._syncConversations[conversationId]) do
                    totalHashes = totalHashes + 1
                end
                debug('received hashes: ' .. totalHashes)
                if totalHashes == 0 then
                    debug('no hashes received')
                    twaprint('No response from group members.')
                    return
                end
                local hashCounts = {} ---@type table<string, integer>
                local maxCount = -1
                for hash, players in pairs(TWA._syncConversations[conversationId]) do
                    hashCounts[hash] = table.getn(players)
                    debug('hash: ' .. hash .. ', amount: ' .. hashCounts[hash])
                    if hashCounts[hash] > maxCount then maxCount = hashCounts[hash] end
                end
                debug('maxCount: ' .. maxCount)
                local biggestHashes = {} ---@type table<integer, string>
                for hash, players in pairs(TWA._syncConversations[conversationId]) do
                    if table.getn(players) == maxCount then table.insert(biggestHashes, hash) end
                end
                if table.getn(biggestHashes) > 1 then
                    twaprint('There were conflicts when synchronizing tables from different players.')
                    twaprint('The data from the player with the highest rank will be selected.')

                    ---@type table<'leader'|'assistants'|'plebs', table<string, string>>
                    local playerRanks = {
                        ['leader'] = {},
                        ['assistants'] = {},
                        ['plebs'] = {}
                    }
                    for _, hash in ipairs(biggestHashes) do
                        for _, player in TWA._syncConversations[conversationId][hash] do
                            if player == TWA._leader then
                                playerRanks['leader'][player] = hash
                            elseif TWA._assistants[player] then
                                playerRanks['assistants'][player] = hash
                            else
                                playerRanks['plebs'][player] = hash
                            end
                        end
                    end
                    for player, hash in pairs(playerRanks['leader']) do
                        TWA.sync.SelectPlayerToSync(player, conversationId)
                        return
                    end
                    for player, hash in pairs(playerRanks['assistants']) do
                        TWA.sync.SelectPlayerToSync(player, conversationId)
                        return
                    end
                    for player, hash in pairs(playerRanks['plebs']) do
                        TWA.sync.SelectPlayerToSync(player, conversationId)
                        return
                    end
                else
                    -- one winner hash.
                    -- if anyone has a mismatched hash then select any player with the majority hash to broadcast.
                    -- Otherwise, end the conversation.
                    local uniqueHashList = {} ---@type table<integer, string>
                    for hash, _ in pairs(TWA._syncConversations[conversationId]) do
                        if not TWA.util.tableContains(uniqueHashList, hash) then
                            table.insert(uniqueHashList, hash)
                        end
                    end
                    if table.getn(uniqueHashList) > 1 then
                        TWA.sync.SelectPlayerToSync(TWA._syncConversations[conversationId][biggestHashes[1]][1], conversationId)
                    else
                        TWA.sync.ConcludeSync(conversationId)
                    end

                    
                end
            end, TWA.SYNC_REQUEST_TIMEOUT)
        end,
    })
end

---As a leader, broadcast a full sync of data (when a player requests it, or the group is converted from party to raid).
---Does nothing if not a raid leader.
---@param conversationId string|nil Provide if broadcasting as part of conversation
function TWA.sync.BroadcastFullSync(conversationId)
    -- if not IsRaidLeader() then return end
    conversationId = conversationId and conversationId or TWA.sync.newId()
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
    -- if not TWA.InRaid() and not (IsRaidLeader() or IsRaidOfficer()) then return end

    conversationId = conversationId and conversationId or TWA.sync.newId()
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
    TWA.sync.SendAddonMessage(TWA.MESSAGE.RosterEntryDeleted .. "=" .. class .. "=" .. name)
end

function TWA.sync.BroadcastWipeTable()
    TWA.sync.SendAddonMessage(TWA.MESSAGE.WipeTable)
end

--- Requests all assistant rosters (and leader roster) in the raid by broadcasting hashes.
--- <br/>
--- The function hashes the rosters of all current assistants and broadcasts the hashes
--- to the raid. If an assistant receives an incorrect hash of their roster, they will
--- broadcast their roster.
--- <br/>
--- It also handles the case where rosters for certain assistants are missing by
--- directly requesting their rosters.
--- <br/>
--- If in a party, only the leader's roster is requested.
function TWA.sync.RequestAssistantRosters()
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
        local cid = TWA.sync.newId()
        TWA.sync.SendAddonMessage({
            text = TWA.MESSAGE.RosterRequestHash .. "=" .. assistant .. "=" .. hash,
            conversationId = cid
        })
    end

    -- For missing hashes, request the roster directly
    if TWA.InRaid() then
        for i = 1, GetNumRaidMembers() do
            if GetRaidRosterInfo(i) then
                local name, rank, _, _, _, _, z = GetRaidRosterInfo(i);
                if name ~= TWA.me and (rank == 1 or rank == 2) and hashes[name] == nil then
                    local cid = TWA.sync.newId()
                    TWA.sync.SendAddonMessage({
                        text = TWA.MESSAGE.RosterRequest .. "=" .. name,
                        conversationId = cid
                    })
                end
            end
        end
    elseif TWA.InParty() then
        if not IsPartyLeader() then
            local leader = (GetPartyLeaderIndex() == 0 and TWA.me or UnitName("party" .. GetPartyLeaderIndex()))
            if hashes[leader] == nil then
                local cid = TWA.sync.newId()
                TWA.sync.SendAddonMessage({
                    text = TWA.MESSAGE.RosterRequest .. "=" .. leader,
                    conversationId = cid
                })
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

function TWA.sync.newId()
    return TWA.util.hashToHex(math.random(1, 2147483647))
end

---Wrapper around ChatThrottleLib:SendAddonMessage, but most parameters optional to clean up code.
---<br/>
---Also takes an optional callback function, invoked when the message has been received by the player that sent it.
---@param arg string|TWASendAddonMessageArgs Either provide just the message as a string, or provide a table if you want to overwrite defaults of the optional values.
---@return string messageId Id of the message sent
function TWA.sync.SendAddonMessage(arg)
    -- set defaults
    local text = arg
    local prefix = "TWA";
    local prio = "ALERT";
    local chattype = TWA._playerGroupState == 'party' and "PARTY" or "RAID";
    local conversationId = '-';

    local messageId = TWA.sync.newId();
    local addonVersion = TWA.version;

    -- overwrite with table values if arg is table
    if type(arg) == "table" then
        text = arg.text and arg.text or text
        prefix = arg.prefix and arg.prefix or prefix
        prio = arg.prio and arg.prio or prio
        chattype = arg.chattype and arg.chattype or chattype
        conversationId = arg.conversationId and arg.conversationId or conversationId

        if arg.callbackFn ~= nil then
            TWA._messageCallbacks[messageId] = arg.callbackFn
        end
    end

    local headers = {}
    table.insert(headers, addonVersion)
    table.insert(headers, messageId)
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

    return messageId;
end
