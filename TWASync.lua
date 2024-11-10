function TWA.handleSync(_, t, _, sender)
  if string.find(t, 'LoadTemplate=', 1, true) then
    local args = string.split(t, '=')
    if not args[2] then
      return false
    end
    TWA.loadTemplate(args[2], true)
    return true
  end

  if string.find(t, 'RosterRequest=', 1, true) and sender ~= TWA.me then
    local args = string.split(t, '=')
    local name = args[2]
    if name == TWA.me then
      TWA.BroadcastRoster(TWA.roster, true)
    end
    return true
  end

  if string.find(t, 'RosterRequestHash=', 1, true) and sender ~= TWA.me then
    local args = string.split(t, '=')
    if not args[2] or not args[3] then return false end
    local name = args[2]
    if name ~= TWA.me then return true end

    local theirHash = TWA.util.hexToHash(args[3])
    local myHash = TWA.util.djb2_hash(TWA.SerializeRoster(TWA.roster))

    if theirHash ~= myHash then
      TWA.BroadcastRoster(TWA.roster, true)
    end
    return true
  end

  if string.find(t, 'RequestSync=', 1, true) and sender ~= TWA.me then
    twadebug(sender .. ' requested full sync')
    if IsRaidLeader() then TWA.BroadcastSync() end
    return true
  end

  if string.find(t, 'FullSync=', 1, true) and sender ~= TWA.me then
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
        TWA.addUniqueToRoster(sender, class, name)
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

  if string.find(t, 'RosterBroadcastPartial=', 1, true) and sender ~= TWA.me then
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
        TWA.addUniqueToRoster(sender, class, name)
      end
    end
    return true
  end

  if string.find(t, 'RosterBroadcastFull=', 1, true) and sender ~= TWA.me then
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
        TWA.addUniqueToRoster(sender, class, name)
      end
    end
    return true
  end

  if string.find(t, 'RosterEntryDeleted=', 1, true) and sender ~= TWA.me then
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

  if string.find(t, 'RemRow=', 1, true) then
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

  if string.find(t, 'ChangeCell=', 1, true) then
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

function TWA.handleQHSync(pre, t, ch, sender)
  if sender ~= TWA.me then
    local roster
    local tanks = 'Tanks='
    local healers = 'Healers='

    if string.find(t, 'RequestRoster', 1, true) then -- QH roster request
      for index, data in next, TWA.data do           -- build roster string
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
      ChatThrottleLib:SendAddonMessage("ALERT", "TWA", roster, "RAID") -- transmit roster
    end
  end
end

---As a non-leader, request full sync of data (when you join the group for example)
function TWA.RequestSync()
  twadebug('i request sync')
  twaprint('Requesting full sync of data...')
  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "RequestSync=" .. TWA.me, "RAID")
end

---As a leader, broadcast a full sync of data (when a player requests it, or the group is converted from party to raid).
---Does nothing if not a raid leader.
function TWA.BroadcastSync()
  if not IsRaidLeader() then return end
  twadebug('i broadcast sync')
  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "FullSync=start", "RAID")
  for _, data in next, TWA.data do
    ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "FullSync=" ..
      data[1] .. '=' ..
      data[2] .. '=' ..
      data[3] .. '=' ..
      data[4] .. '=' ..
      data[5] .. '=' ..
      data[6] .. '=' ..
      data[7], "RAID")
  end

  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "FullSync=end", "RAID")
end

---Call to share your roster with other players. You can pass partial rosters when adding new names to save on bandwidth.
---Only works in raid and if you are either assistant or leader. (noop otherwise)
---@param roster TWARoster The roster to broadcast
---@param full boolean Pass true if you're broadcasting your full roster (recipients will wipe your existing roster). False if partial roster (when adding single entries).
function TWA.BroadcastRoster(roster, full)
  if full == nil then error("Argument 'full' is required and cannot be nil", 2) end
  if not TWA.InRaid() and not (IsRaidLeader() or IsRaidOfficer()) then return end

  local broadcasttype = 'RosterBroadcast' .. (full and 'Full' or 'Partial')
  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", broadcasttype .. "=start", "RAID")

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
    ChatThrottleLib:SendAddonMessage("ALERT", "TWA", broadcasttype .. "=" .. class .. "=" .. namesSerialized, "RAID")
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

  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", broadcasttype .. "=end", "RAID")
end

---Call to share that you've deleted a member of your roster.
---Only works in raid and if you are either assistant or leader. (noop otherwise)
---@param class TWAWowClass
---@param name string
function TWA.BroadcastRosterEntryDeleted(class, name)
  if not TWA.InRaid() and not (IsRaidLeader() or IsRaidOfficer()) then return end
  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "RosterEntryDeleted=" .. class .. "=" .. name, "RAID")
end

function TWA.WipeTableBroadcast()
  ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "WipeTable", "RAID")
end

--- Requests all assistant rosters in the raid by broadcasting hashes.
---
--- The function hashes the rosters of all current assistants and broadcasts the hashes
--- to the raid. If an assistant receives an incorrect hash of their roster, they will
--- broadcast their roster.
---
--- It also handles the case where rosters for certain assistants are missing by
--- directly requesting their rosters.
function TWA.RequestAllAssistantRosters()
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
    ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "RosterRequestHash=" .. assistant .. "=" .. hash, "RAID")
  end

  -- if you dont have an assistant's roster at all, request the roster directly
  for i = 1, GetNumRaidMembers() do
    if GetRaidRosterInfo(i) then
      local name, rank, _, _, _, _, z = GetRaidRosterInfo(i);
      if name ~= TWA.me and (rank == 1 or rank == 2) and hashes[name] == nil then
        ChatThrottleLib:SendAddonMessage("ALERT", "TWA", "RosterRequest=" .. name, "RAID")
      end
    end
  end
end
