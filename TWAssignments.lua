local addonVer = "1.1.0.0" --don't use letters or numbers > 10
local debugLevel = TWA.DEBUG.VERBOSE;

TWA.version = addonVer;
TWA.me = UnitName('player')

local TWATargetsDropDown = CreateFrame('Frame', 'TWATargetsDropDown', UIParent, 'UIDropDownMenuTemplate')
local TWATanksDropDown = CreateFrame('Frame', 'TWATanksDropDown', UIParent, 'UIDropDownMenuTemplate')
local TWAHealersDropDown = CreateFrame('Frame', 'TWAHealersDropDown', UIParent, 'UIDropDownMenuTemplate')

local TWATemplates = CreateFrame('Frame', 'TWATemplates', UIParent, 'UIDropDownMenuTemplate')

function twaprint(a)
    if a == nil then
        DEFAULT_CHAT_FRAME:AddMessage('|cff69ccf0[TWA]|cff0070de:' ..
            time() .. '|cffffffff attempt to print a nil value.')
        return false
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWA] |cffffffff" .. a)
end

function twaerror(a)
    DEFAULT_CHAT_FRAME:AddMessage('|cff69ccf0[TWA]|cff0070de:' .. time() .. '|cffffffff[' .. a .. ']')
end

function twadebug(a)
    if (TWA.me == 'Kzktst' or TWA.me == 'Xerrtwo' or TWA.me == 'Tantomon' or TWA.me == 'Gergrutaa') and debugLevel > TWA.DEBUG.DISABLED then
        twaprint('|cff0070de[TWADEBUG:' .. time() .. ']|cffffffff[' .. a .. ']')
    end
end

TWA:RegisterEvent("ADDON_LOADED")
TWA:RegisterEvent("PLAYER_LOGIN")
TWA:RegisterEvent("RAID_ROSTER_UPDATE")
TWA:RegisterEvent("CHAT_MSG_ADDON")
TWA:RegisterEvent("CHAT_MSG_WHISPER")
TWA:RegisterEvent("PARTY_MEMBERS_CHANGED")

---All conditions must be satisfied to make changes:
---1. The player is in a raid group
---1. The player is either leader or assistant
---1. The leader of the raid is not offline (since he is syncmaster)
---@return boolean
function TWA_CanMakeChanges()
    if not TWA.InRaid() then
        twaprint('You must be in a raid group to do that.')
        return false
    end
    if not ((IsRaidLeader()) or (IsRaidOfficer())) then
        twaprint("You need to be a raid leader or assistant to do that.")
        return false
    end
    if not TWA._leaderOnline then
        twaprint("The leader of the group must be online to make any changes.")
        return false
    end
    return true
end

local twa_templates = {
    ['trash1'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash2'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash3'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash4'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash5'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['gaar'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [5] = { "Square", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
        [9] = { "Moon", "-", "-", "-", "-", "-", "-" }
    },
    ['domo'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [5] = { "Square", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
        [9] = { "Moon", "-", "-", "-", "-", "-", "-" }
    },
    ['rag'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [3] = { "Ranged", "-", "-", "-", "-", "-", "-" },
    },
    ['razorgore'] = {
        [1] = { "Left", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Left", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Right", "-", "-", "-", "-", "-", "-" },
        [6] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['vael'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Group 1", "-", "-", "-", "-", "-", "-" },
        [3] = { "Group 2", "-", "-", "-", "-", "-", "-" },
        [4] = { "Group 3", "-", "-", "-", "-", "-", "-" },
        [5] = { "Group 4", "-", "-", "-", "-", "-", "-" },
        [6] = { "Group 5", "-", "-", "-", "-", "-", "-" },
        [7] = { "Group 6", "-", "-", "-", "-", "-", "-" },
        [8] = { "Group 7", "-", "-", "-", "-", "-", "-" },
        [9] = { "Group 8", "-", "-", "-", "-", "-", "-" },
    },
    ['lashlayer'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [4] = { "BOSS", "-", "-", "-", "-", "-", "-" },
    },
    ['chromaggus'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Dispels", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dispels", "-", "-", "-", "-", "-", "-" },
        [4] = { "Enrage", "-", "-", "-", "-", "-", "-" },
    },
    ['nef'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Left", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['skeram'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Right", "-", "-", "-", "-", "-", "-" },
        [4] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [5] = { "Left", "-", "-", "-", "-", "-", "-" },
        [6] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['bugtrio'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Diamond", "-", "-", "-", "-", "-", "-" },
    },
    ['sartura'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Square", "-", "-", "-", "-", "-", "-" },
    },
    ['fankriss'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "North", "-", "-", "-", "-", "-", "-" },
        [3] = { "East", "-", "-", "-", "-", "-", "-" },
        [4] = { "West", "-", "-", "-", "-", "-", "-" },
    },
    ['huhu'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [4] = { "Melee", "-", "-", "-", "-", "-", "-" },
    },
    ['twins'] = {
        [1] = { "Left", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Right", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Adds", "-", "-", "-", "-", "-", "-" },
        [6] = { "Adds", "-", "-", "-", "-", "-", "-" },
    },
    ['anub'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Raid", "-", "-", "-", "-", "-", "-" },
    },
    ['faerlina'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Adds", "-", "-", "-", "-", "-", "-" },
        [4] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [5] = { "Cross", "-", "-", "-", "-", "-", "-" },
    },
    ['maexxna'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Wall", "-", "-", "-", "-", "-", "-" },
        [4] = { "Wall", "-", "-", "-", "-", "-", "-" },
    },
    ['noth'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "NorthWest", "-", "-", "-", "-", "-", "-" },
        [3] = { "SouthWest", "-", "-", "-", "-", "-", "-" },
        [4] = { "NorthEast", "-", "-", "-", "-", "-", "-" },
    },
    ['heigan'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dispels", "-", "-", "-", "-", "-", "-" },
    },
    ['raz'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Square", "-", "-", "-", "-", "-", "-" },
    },
    ['gothik'] = {
        [1] = { "Living", "-", "-", "-", "-", "-", "-" },
        [2] = { "Living", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dead", "-", "-", "-", "-", "-", "-" },
        [4] = { "Dead", "-", "-", "-", "-", "-", "-" },
    },
    ['4h'] = {
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [4] = { "Square", "-", "-", "-", "-", "-", "-" },
    },
    ['patchwerk'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Soaker", "-", "-", "-", "-", "-", "-" },
        [3] = { "Soaker", "-", "-", "-", "-", "-", "-" },
        [4] = { "Soaker", "-", "-", "-", "-", "-", "-" },
    },
    ['grobulus'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dispells", "-", "-", "-", "-", "-", "-" },
    },
    ['gluth'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Adds", "-", "-", "-", "-", "-", "-" },
    },
    ['thaddius'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Left", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['saph'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Group 1", "-", "-", "-", "-", "-", "-" },
        [4] = { "Group 2", "-", "-", "-", "-", "-", "-" },
        [5] = { "Group 3", "-", "-", "-", "-", "-", "-" },
        [6] = { "Group 4", "-", "-", "-", "-", "-", "-" },
        [7] = { "Group 5", "-", "-", "-", "-", "-", "-" },
        [8] = { "Group 6", "-", "-", "-", "-", "-", "-" },
        [9] = { "Group 7", "-", "-", "-", "-", "-", "-" },
        [10] = { "Group 8", "-", "-", "-", "-", "-", "-" },
    },
    ['kt'] = {
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Raid", "-", "-", "-", "-", "-", "-" },
    },
}

function TWA.loadTemplate(template, load)
    if load ~= nil and load == true then
        TWA.data = {}
        for i, d in next, twa_templates[template] do
            TWA.data[i] = d
        end
        TWA.PopulateTWA()
        twaprint('Loaded template |cff69ccf0' .. template)
        getglobal('TWA_MainTemplates'):SetText(template)
        TWA.loadedTemplate = template
        return true
    end
    TWA.sync.SendAddonMessage(TWA.MESSAGE.LoadTemplate .. "=" .. template)
end

--testing
-- TWA.raid = {
--    ['warrior'] = { 'Smultron', 'Jeff', 'Reis', 'Mesmorc' },
--    ['paladin'] = { 'Paleddin', 'Laughadin' },
--    ['druid'] = { 'Kashchada', 'Faralynn', 'Lulzer' },
--    ['warlock'] = { 'Baba', 'Furry', 'Faust' },
--    ['mage'] = { 'Momo', 'Trepp', 'Linette' },
--    ['priest'] = { 'Er', 'Dispatch', 'Morrgoth' },
--    ['rogue'] = { 'Tyrelys', 'Smersh', 'Tonysoprano' },
--    ['shaman'] = { 'Ilmane', 'Buffalo', 'Cloudburst' },
--    ['hunter'] = { 'Chlo', 'Zteban', 'Ruari' },
-- }

-- ---@type TWARoster
-- TWA.testRoster = {
--     ['druid'] = { "ChuckTesta" },
--     ['hunter'] = { "LennartBladh" },
--     ['mage'] = {},
--     ['paladin'] = {},
--     ['priest'] = {},
--     ['rogue'] = {},
--     ['shaman'] = {},
--     ['warlock'] = { "HotTopic" },
--     ['warrior'] = { "AnothaOne", "BigGuyForYou" },
-- }
-- TWA.roster = TWA.testRoster

---Get the complete roster, consisting of:
---1. Your own roster
---1. Leader's roster
---1. All assistants' rosters
---@return TWARoster
function TWA.GetCompleteRoster()
    ---@type TWARoster
    local completeRoster = {
        ['druid'] = {},
        ['hunter'] = {},
        ['mage'] = {},
        ['paladin'] = {},
        ['priest'] = {},
        ['rogue'] = {},
        ['shaman'] = {},
        ['warlock'] = {},
        ['warrior'] = {},
    }

    -- Helper function to add names to the completeRoster without duplicates per class
    local function addNamesToRoster(class, names)
        local seenNames = {} -- Track names already added to the class
        -- Add existing names in completeRoster to seenNames
        for _, name in ipairs(completeRoster[class]) do
            seenNames[name] = true
        end
        -- Add new names if they are not already in seenNames
        for _, name in ipairs(names) do
            if not seenNames[name] then
                table.insert(completeRoster[class], name)
                seenNames[name] = true
            end
        end
    end

    -- Merge TWA.roster into completeRoster
    for class, names in pairs(TWA.roster) do
        addNamesToRoster(class, names)
    end

    -- Merge TWA.foreignRosters into completeRoster
    for _, otherRoster in pairs(TWA.foreignRosters) do
        for class, names in pairs(otherRoster) do
            addNamesToRoster(class, names)
        end
    end

    return completeRoster
end

---@return boolean
function TWA.InParty()
    return UnitInParty("player") == 1
end

---@return boolean
function TWA.InRaid()
    return UnitInRaid("player") == 1
end

---Serialize a roster
---To test: set up roster and /script twadebug(TWA.SerializeRoster(TWA.roster))
---@param roster TWARoster The roster to serialize
---@return string serializedRoster The serialized roster
function TWA.SerializeRoster(roster)
    local classesWithNames = {}
    for i, class in ipairs(TWA.SORTED_CLASS_NAMES) do
        if roster[class] ~= nil and table.getn(roster[class]) > 0 then
            table.insert(classesWithNames, class)
        end
    end

    local classesWithNamesLen = table.getn(classesWithNames)
    local result = '{' .. (classesWithNamesLen > 0 and '\n' or '')

    for i, class in ipairs(classesWithNames) do
        result = result .. '  [' .. '\"' .. class .. '\"' .. '] = {'
        for j, name in ipairs(roster[class]) do
            result = result .. ' \"' .. name .. '\"' .. (j < table.getn(roster[class]) and ', ' or ' ')
        end
        result = result .. '}' .. (i < classesWithNamesLen and ',' or '') .. '\n'
    end
    return result .. '}'
end

---Serializes the current content of TWA.data
function TWA.SerializeData()
    local twaDataLen = table.getn(TWA.data)
    local result = '{' .. (twaDataLen > 0 and '\n' or '')
    for i = 1, twaDataLen do
        result = result .. '  [' .. i .. '] = {'
        for j = 1, 7 do
            result = result .. ' \"' .. TWA.data[i][j] .. '\"' .. (j < 7 and ', ' or ' ')
        end
        result = result .. '}' .. (i < twaDataLen and ',' or '') .. '\n'
    end
    return result .. '}'
end

---Remove foreign roster entries from people who are neither an assistant nor leader of the raid
function TWA.CleanUpForeignRoster()
    local assistantCache = {} ---@type table<string, boolean>

    -- Cache names of current assistants in the raid
    for i = 1, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local name, rank, _, _, _, _, z = GetRaidRosterInfo(i);
            if rank == 1 or rank == 2 then
                assistantCache[name] = true
            end
        end
    end

    -- Mark rosters for deletion if they don't match current assistants
    local rostersToDelete = {} ---@type table<string, boolean>
    for name, roster in pairs(TWA.foreignRosters) do
        if not assistantCache[name] then
            rostersToDelete[name] = true
        end
    end

    -- Delete outdated rosters
    for name, _ in pairs(rostersToDelete) do
        TWA.foreignRosters[name] = nil
    end
end

TWA.InitializeGroupState = function()
    if TWA._playerGroupStateInitialized then return end
    TWA._playerGroupStateInitialized = true;
    TWA.CleanUpForeignRoster()
    TWA.PlayerGroupStateUpdate()
end

---Updates the player's group state, and runs appropriate side effects on changes (for example, request sync if logging in while in raid)
function TWA.PlayerGroupStateUpdate()
    if not TWA._playerGroupStateInitialized then
        twadebug('player group state not initialized, ignored update')
        return
    end

    ---@param newState TWAGroupState
    local function setGroupState(newState)
        local oldState = TWA._playerGroupState or 'NIL';
        if oldState ~= newState then
            twadebug('state changed from ' .. oldState .. ' to ' .. newState)
        end

        TWA._playerGroupState = newState
    end

    if TWA._playerGroupState == nil then
        twadebug('i just logged in')
        -- reloaded ui or logged in
        setGroupState('alone')

        if TWA.InParty() then
            -- logged in while in party
            setGroupState('party')
        else
            twadebug('not in party')
        end
        if TWA.InRaid() then
            setGroupState('raid')
            -- logged in while in raid group
            if IsRaidLeader() then
                TWA.sync.BroadcastFullSync() -- overwrite any changes made by assistants while you were offline
            else
                TWA.sync.RequestFullSync()
            end
            TWA.sync.RequestAssistantRosters()
        else
            twadebug('not in raid')
        end
    elseif TWA._playerGroupState == 'alone' and TWA.InParty() then
        -- joined a group
        setGroupState('party')

        if TWA.InRaid() then
            -- joined a raid
            setGroupState('raid')
            TWA.sync.RequestFullSync()
            TWA.sync.RequestAssistantRosters()
        end
    elseif (TWA._playerGroupState == 'party' or TWA._playerGroupState == 'raid') and not TWA.InParty() then
        -- left the group
        TWA.foreignRosters = {}
        TWA.persistForeignRosters()
        setGroupState('alone')
    elseif TWA._playerGroupState == 'party' and TWA.InRaid() then
        -- party was converted to raid
        setGroupState('raid')
        if IsRaidLeader() then
            TWA.sync.BroadcastFullSync()
            TWA.sync.RequestAssistantRosters()
        end
    end
end

TWA:SetScript("OnEvent", function()
    if not event then return end

    if event == "ADDON_LOADED" and arg1 == "TWAssignments" then
        twaprint("ADDON_LOADED")

        if not TWA_PRESETS then
            TWA_PRESETS = {}
        end

        if not TWA_DATA then
            TWA_DATA = {
                [1] = { '-', '-', '-', '-', '-', '-', '-' },
            }
        end
        TWA.data = TWA_DATA

        if TWA_ROSTER and TWA.testRoster == nil then
            TWA.roster = TWA_ROSTER
        end

        if TWA_FOREIGN_ROSTERS then
            TWA.foreignRosters = TWA_FOREIGN_ROSTERS
        end

        TWA.fillRaidData()
        TWA.PopulateTWA()

        tinsert(UISpecialFrames, "TWA_Main") --makes window close with Esc key
        tinsert(UISpecialFrames, "TWA_RosterManager")
    end

    if event == "PLAYER_LOGIN" then
        TWA.setTimeout(function()
            twadebug('initializing group state')
            TWA.InitializeGroupState()
        end, TWA.LOGIN_GRACE_PERIOD)
    end

    if event == "RAID_ROSTER_UPDATE" then
        twadebug("RAID_ROSTER_UPDATE")
        if TWA.partyAndRaidCombinedEventTimeoutId ~= nil then
            TWA.clearTimeout(TWA.partyAndRaidCombinedEventTimeoutId)
            TWA.partyAndRaidCombinedEventTimeoutId = nil
        end
        TWA.PlayerGroupStateUpdate()
        TWA.fillRaidData()
        TWA.PopulateTWA()
    end

    if event == "PARTY_MEMBERS_CHANGED" then
        twadebug("PARTY_MEMBERS_CHANGED")
        TWA.partyAndRaidCombinedEventTimeoutId = TWA.setTimeout(function()
            TWA.PlayerGroupStateUpdate()
        end, TWA.DOUBLE_EVENT_TIMEOUT)
    end

    if event == 'CHAT_MSG_ADDON' and arg1 == "TWA" then
        if debugLevel >= TWA.DEBUG.VERBOSE then
            twadebug(arg4 .. ' says: ' .. arg2)
        end
        TWA.sync.handleSync(arg1, arg2, arg3, arg4)
    end

    if event == 'CHAT_MSG_ADDON' and arg1 == "QH" then
        TWA.sync.handleQHSync(arg1, arg2, arg3, arg4)
    end

    if event == 'CHAT_MSG_WHISPER' then
        if arg1 == 'heal' then
            local lineToSend = ''
            for _, row in next, TWA.data do
                local mark = ''
                local tank = ''
                for i, cell in next, row do
                    if i == 1 then
                        mark = cell
                        tank = mark
                    end
                    if i == 2 or i == 3 or i == 4 then
                        if cell ~= '-' then
                            tank = ''
                        end
                    end
                    if i == 2 or i == 3 or i == 4 then
                        if cell ~= '-' then
                            tank = tank .. cell .. ' '
                        end
                    end
                    if arg2 == cell then
                        if i == 2 or i == 3 or i == 4 then
                            if lineToSend == '' then
                                lineToSend = 'You are assigned to ' .. mark
                            else
                                lineToSend = lineToSend .. ' and ' .. mark
                            end
                        end
                        if i == 5 or i == 6 or i == 7 then
                            if lineToSend == '' then
                                lineToSend = 'You are assigned to Heal ' .. tank
                            else
                                lineToSend = lineToSend .. ' and ' .. tank
                            end
                        end
                    end
                end
            end
            if lineToSend == '' then
                ChatThrottleLib:SendChatMessage("BULK", "TWA", 'You are not assigned.', "WHISPER", "Common", arg2);
            else
                ChatThrottleLib:SendChatMessage("BULK", "TWA", lineToSend, "WHISPER", "Common", arg2);
            end
        end
    end
end)

function TWA.markOrPlayerUsed(markOrPlayer)
    for row, data in next, TWA.data do
        for _, as in next, data do
            if as == markOrPlayer then
                return true
            end
        end
    end
    return false
end

function TWA.persistRoster()
    TWA_ROSTER = TWA.roster
end

function TWA.persistForeignRosters()
    TWA_FOREIGN_ROSTERS = TWA.foreignRosters
end

---@param prev boolean
---@param new boolean
function TWA.OnLeaderOnlineUpdate(prev, new)
    if prev == new then return end
    if prev == false and new == true then
        TWA._leaderOnline = true
        twadebug('leader just came online')
    elseif prev == true and new == false then
        TWA._leaderOnline = false
        twadebug('leader just disconnected')
    end
end

---Call when a player was promoted to raid leader or assist.
---They should broadcast their roster.
---@param name string
function TWA.PlayerWasPromoted(name)
    if TWA._raidStateInitialized then
        twadebug('player was promoted: ' .. name)
        if name == TWA.me then TWA.sync.BroadcastRoster(TWA.roster, true) end
    end
end

---Call when a player is either
---* No longer has either lead or assist role
---* Is removed from the group
---
---Drops their roster entries.
---@param name string
function TWA.PlayerWasDemoted(name)
    twadebug('player was demoted: ' .. name)
    TWA.foreignRosters[name] = nil
    TWA.persistForeignRosters()
end

function TWA.CheckIfPromoted(name, newRank)
    if newRank > 0 then
        if not (TWA._assistants[name] or TWA._leader == name) then
            TWA.PlayerWasPromoted(name)
        end
    end
end

function TWA.CheckIfDemoted(name) -- new rank is always "normal" (neither officer nor leader)
    if TWA._leader == name or TWA._assistants[name] then
        TWA.PlayerWasDemoted(name)
    end
end

function TWA.updateRaidStatus()
    local oldLeader = TWA._leader;
    local newLeader = nil;

    ---Holds the name of the player, and their index in the group (for use in GetRaidRosterInfo(index))
    ---@type table<string, integer>
    local nameCache = {}

    for i = 1, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local name, rank, _, _, _, _, z = GetRaidRosterInfo(i);
            local _, unitClass = UnitClass('raid' .. i)
            unitClass = string.lower(unitClass)
            nameCache[name] = i

            if rank == 2 then -- leader
                TWA.CheckIfPromoted(name, rank)
                newLeader = name
                local prevState = TWA._leaderOnline
                if z == "Offline" then
                    TWA._leaderOnline = false
                else
                    TWA._leaderOnline = true
                end
                TWA.OnLeaderOnlineUpdate(prevState, TWA._leaderOnline)
            elseif rank == 1 then -- assist
                TWA.CheckIfPromoted(name, rank)
                TWA._assistants[name] = true
            else -- pleb
                TWA.CheckIfDemoted(name)
                if TWA._leader == name then
                    TWA._leader = nil
                elseif TWA._assistants[name] then
                    TWA._assistants[name] = nil
                end
            end
        else
            twadebug('GetRaidRosterInfo(' .. i .. ') returned nothing')
        end
    end

    TWA._leader = newLeader;

    -- check all current assists and leader if they have left the group
    if oldLeader ~= nil and nameCache[oldLeader] == nil then
        twadebug('leader left the raid: ' .. oldLeader)
        TWA.foreignRosters[oldLeader] = nil
        TWA.persistForeignRosters()
    end

    for name, _ in pairs(TWA._assistants) do
        if nameCache[name] == nil then
            twadebug('assistant left the raid: ' .. name)
            TWA.foreignRosters[name] = nil
            TWA._assistants[name] = nil
            TWA.persistForeignRosters()
        end
    end

    TWA._raidStateInitialized = true
end

function TWA.fillRaidData()
    twadebug('fill raid data')

    TWA.updateRaidStatus()

    TWA.raid = {
        ['warrior'] = {},
        ['paladin'] = {},
        ['druid'] = {},
        ['warlock'] = {},
        ['mage'] = {},
        ['priest'] = {},
        ['rogue'] = {},
        ['shaman'] = {},
        ['hunter'] = {},
    }
    -- current raid members
    for i = 0, GetNumRaidMembers() do
        if GetRaidRosterInfo(i) then
            local name, _, _, _, _, _, z = GetRaidRosterInfo(i);
            local _, unitClass = UnitClass('raid' .. i)
            unitClass = string.lower(unitClass)
            table.insert(TWA.raid[unitClass], name)
            table.sort(TWA.raid[unitClass])
        end
    end
    -- roster list (see TWA.roster)
    for class, names in pairs(TWA.GetCompleteRoster()) do
        for _, name in pairs(names) do
            if not TWA.util.tableContains(TWA.raid[class], name) then
                table.insert(TWA.raid[class], name)
            end
            table.sort(TWA.raid[class])
        end
    end
end

function TWA.isPlayerLeadOrAssist(name)
    return TWA._assistants[name] ~= nil or TWA._leader == name
end

function TWA.isPlayerOffline(name)
    local playerFound = false;
    for i = 0, GetNumRaidMembers() do
        if (GetRaidRosterInfo(i)) then
            local n, _, _, _, _, _, z = GetRaidRosterInfo(i);
            if n == name then
                playerFound = true
                if z == 'Offline' then
                    return true
                end
            end
        end
        if playerFound then break end
    end
    if not playerFound then
        return true -- if not in group, treat as offline (can be in roster yet not in group)
    end
    return false
end

---Handles adding players from other people's rosters to TWA.foreignRosters.
---Duplicate names are not allowed within a class, but is OK across classes.
---@param rosterOwner any
---@param class any
---@param player any
function TWA.addToForeignRoster(rosterOwner, class, player)
    -- Ensure the rosterOwner has a roster in TWA.foreignRosters
    if not TWA.foreignRosters[rosterOwner] then
        TWA.foreignRosters[rosterOwner] = {
            ['druid'] = {},
            ['hunter'] = {},
            ['mage'] = {},
            ['paladin'] = {},
            ['priest'] = {},
            ['rogue'] = {},
            ['shaman'] = {},
            ['warlock'] = {},
            ['warrior'] = {},
        }
    end

    -- Access the roster for this specific rosterOwner
    local ownerRoster = TWA.foreignRosters[rosterOwner]

    -- Check if the player is already in the class list
    if TWA.util.tableContains(ownerRoster[class], player) then return end

    -- If player isn't in the list, add them to the class
    table.insert(ownerRoster[class], player)
    table.sort(ownerRoster[class])
end

function TWA.buildTargetsDropdown()
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local Title = {}
        Title.text = "Target"
        Title.isTitle = true
        UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

        local Marks = {}
        Marks.text = "Marks"
        Marks.notCheckable = true
        Marks.hasArrow = true
        Marks.value = {
            ['key'] = 'marks'
        }
        UIDropDownMenu_AddButton(Marks, UIDROPDOWNMENU_MENU_LEVEL);

        local Sides = {}
        Sides.text = "Sides"
        Sides.notCheckable = true
        Sides.hasArrow = true
        Sides.value = {
            ['key'] = 'sides'
        }
        UIDropDownMenu_AddButton(Sides, UIDROPDOWNMENU_MENU_LEVEL);

        local Coords = {}
        Coords.text = "Coords"
        Coords.notCheckable = true
        Coords.hasArrow = true
        Coords.value = {
            ['key'] = 'coords'
        }
        UIDropDownMenu_AddButton(Coords, UIDROPDOWNMENU_MENU_LEVEL);

        local Targets = {}
        Targets.text = "Misc"
        Targets.notCheckable = true
        Targets.hasArrow = true
        Targets.value = {
            ['key'] = 'misc'
        }
        UIDropDownMenu_AddButton(Targets, UIDROPDOWNMENU_MENU_LEVEL);

        local Groups = {}
        Groups.text = "Groups"
        Groups.notCheckable = true
        Groups.hasArrow = true
        Groups.value = {
            ['key'] = 'groups'
        }
        UIDropDownMenu_AddButton(Groups, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator);

        local clear = {};
        clear.text = "Clear"
        clear.disabled = false
        clear.isTitle = false
        clear.notCheckable = true
        clear.func = TWA.changeCell
        clear.arg1 = TWA.currentRow * 100 + TWA.currentCell
        clear.arg2 = 'Clear'
        UIDropDownMenu_AddButton(clear, UIDROPDOWNMENU_MENU_LEVEL);
    end

    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        if (UIDROPDOWNMENU_MENU_VALUE["key"] == 'marks') then
            local Title = {}
            Title.text = "Marks"
            Title.isTitle = true
            UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

            local separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            for mark, color in next, TWA.marks do
                local dropdownItem = {}
                dropdownItem.text = color .. mark
                dropdownItem.checked = TWA.markOrPlayerUsed(mark)

                dropdownItem.icon = 'Interface\\TargetingFrame\\UI-RaidTargetingIcons'

                if mark == 'Skull' then
                    dropdownItem.tCoordLeft = 0.75
                    dropdownItem.tCoordRight = 1
                    dropdownItem.tCoordTop = 0.25
                    dropdownItem.tCoordBottom = 0.5
                end
                if mark == 'Cross' then
                    dropdownItem.tCoordLeft = 0.5
                    dropdownItem.tCoordRight = 0.75
                    dropdownItem.tCoordTop = 0.25
                    dropdownItem.tCoordBottom = 0.5
                end
                if mark == 'Square' then
                    dropdownItem.tCoordLeft = 0.25
                    dropdownItem.tCoordRight = 0.5
                    dropdownItem.tCoordTop = 0.25
                    dropdownItem.tCoordBottom = 0.5
                end
                if mark == 'Moon' then
                    dropdownItem.tCoordLeft = 0
                    dropdownItem.tCoordRight = 0.25
                    dropdownItem.tCoordTop = 0.25
                    dropdownItem.tCoordBottom = 0.5
                end
                if mark == 'Triangle' then
                    dropdownItem.tCoordLeft = 0.75
                    dropdownItem.tCoordRight = 1
                    dropdownItem.tCoordTop = 0
                    dropdownItem.tCoordBottom = 0.25
                end
                if mark == 'Diamond' then
                    dropdownItem.tCoordLeft = 0.5
                    dropdownItem.tCoordRight = 0.75
                    dropdownItem.tCoordTop = 0
                    dropdownItem.tCoordBottom = 0.25
                end
                if mark == 'Circle' then
                    dropdownItem.tCoordLeft = 0.25
                    dropdownItem.tCoordRight = 0.5
                    dropdownItem.tCoordTop = 0
                    dropdownItem.tCoordBottom = 0.25
                end
                if mark == 'Star' then
                    dropdownItem.tCoordLeft = 0
                    dropdownItem.tCoordRight = 0.25
                    dropdownItem.tCoordTop = 0
                    dropdownItem.tCoordBottom = 0.25
                end

                dropdownItem.func = TWA.changeCell
                dropdownItem.arg1 = TWA.currentRow * 100 + TWA.currentCell
                dropdownItem.arg2 = mark
                UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
                dropdownItem = nil
            end
        end

        if (UIDROPDOWNMENU_MENU_VALUE["key"] == 'sides') then
            local Title = {}
            Title.text = "Sides"
            Title.isTitle = true
            UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

            local separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            local left = {};
            left.text = TWA.sides['Left'] .. 'Left'
            left.checked = TWA.markOrPlayerUsed('Left')
            left.func = TWA.changeCell
            left.arg1 = TWA.currentRow * 100 + TWA.currentCell
            left.arg2 = 'Left'
            UIDropDownMenu_AddButton(left, UIDROPDOWNMENU_MENU_LEVEL);

            local right = {};
            right.text = TWA.sides['Right'] .. 'Right'
            right.checked = TWA.markOrPlayerUsed('Right')
            right.func = TWA.changeCell
            right.arg1 = TWA.currentRow * 100 + TWA.currentCell
            right.arg2 = 'Right'
            UIDropDownMenu_AddButton(right, UIDROPDOWNMENU_MENU_LEVEL);
        end

        if (UIDROPDOWNMENU_MENU_VALUE["key"] == 'coords') then
            local Title = {}
            Title.text = "Coords"
            Title.isTitle = true
            UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

            local separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            local n = {};
            n.text = TWA.coords['North'] .. 'North'
            n.checked = TWA.markOrPlayerUsed('North')
            n.func = TWA.changeCell
            n.arg1 = TWA.currentRow * 100 + TWA.currentCell
            n.arg2 = 'North'
            UIDropDownMenu_AddButton(n, UIDROPDOWNMENU_MENU_LEVEL);
            local s = {};
            s.text = TWA.coords['South'] .. 'South'
            s.checked = TWA.markOrPlayerUsed('South')
            s.func = TWA.changeCell
            s.arg1 = TWA.currentRow * 100 + TWA.currentCell
            s.arg2 = 'South'
            UIDropDownMenu_AddButton(s, UIDROPDOWNMENU_MENU_LEVEL);
            local e = {};
            e.text = TWA.coords['East'] .. 'East'
            e.checked = TWA.markOrPlayerUsed('East')
            e.func = TWA.changeCell
            e.arg1 = TWA.currentRow * 100 + TWA.currentCell
            e.arg2 = 'East'
            UIDropDownMenu_AddButton(e, UIDROPDOWNMENU_MENU_LEVEL);
            local w = {};
            w.text = TWA.coords['West'] .. 'West'
            w.checked = TWA.markOrPlayerUsed('West')
            w.func = TWA.changeCell
            w.arg1 = TWA.currentRow * 100 + TWA.currentCell
            w.arg2 = 'West'
            UIDropDownMenu_AddButton(w, UIDROPDOWNMENU_MENU_LEVEL);
        end

        if (UIDROPDOWNMENU_MENU_VALUE["key"] == 'misc') then
            local Title = {}
            Title.text = "Misc"
            Title.isTitle = true
            UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

            local separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            for mark, color in next, TWA.misc do
                local markings = {};
                markings.text = color .. mark
                markings.checked = TWA.markOrPlayerUsed(mark)
                markings.func = TWA.changeCell
                markings.arg1 = TWA.currentRow * 100 + TWA.currentCell
                markings.arg2 = mark
                UIDropDownMenu_AddButton(markings, UIDROPDOWNMENU_MENU_LEVEL);
            end
        end

        if (UIDROPDOWNMENU_MENU_VALUE["key"] == 'groups') then
            local Title = {}
            Title.text = "Groups"
            Title.isTitle = true
            UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

            local separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            for mark, color in pairsByKeys(TWA.groups) do
                local markings = {};
                markings.text = color .. mark
                markings.checked = TWA.markOrPlayerUsed(mark)
                markings.func = TWA.changeCell
                markings.arg1 = TWA.currentRow * 100 + TWA.currentCell
                markings.arg2 = mark
                UIDropDownMenu_AddButton(markings, UIDROPDOWNMENU_MENU_LEVEL);
            end
        end
    end
end

function TWA.buildTanksDropdown()
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local Title = {}
        Title.text = "Tanks"
        Title.isTitle = true
        UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

        local Warriors = {}
        Warriors.text = TWA.classColors['warrior'].c .. 'Warriors'
        Warriors.notCheckable = true
        Warriors.hasArrow = true
        Warriors.value = {
            ['key'] = 'warrior'
        }
        UIDropDownMenu_AddButton(Warriors, UIDROPDOWNMENU_MENU_LEVEL);

        local Druids = {}
        Druids.text = TWA.classColors['druid'].c .. 'Druids'
        Druids.notCheckable = true
        Druids.hasArrow = true
        Druids.value = {
            ['key'] = 'druid'
        }
        UIDropDownMenu_AddButton(Druids, UIDROPDOWNMENU_MENU_LEVEL);

        local Paladins = {}
        Paladins.text = TWA.classColors['paladin'].c .. 'Paladins'
        Paladins.notCheckable = true
        Paladins.hasArrow = true
        Paladins.value = {
            ['key'] = 'paladin'
        }
        UIDropDownMenu_AddButton(Paladins, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator);

        local Warlocks = {}
        Warlocks.text = TWA.classColors['warlock'].c .. 'Warlocks'
        Warlocks.notCheckable = true
        Warlocks.hasArrow = true
        Warlocks.value = {
            ['key'] = 'warlock'
        }
        UIDropDownMenu_AddButton(Warlocks, UIDROPDOWNMENU_MENU_LEVEL);

        local Mages = {}
        Mages.text = TWA.classColors['mage'].c .. 'Mages'
        Mages.notCheckable = true
        Mages.hasArrow = true
        Mages.value = {
            ['key'] = 'mage'
        }
        UIDropDownMenu_AddButton(Mages, UIDROPDOWNMENU_MENU_LEVEL);

        local Priests = {}
        Priests.text = TWA.classColors['priest'].c .. 'Priests'
        Priests.notCheckable = true
        Priests.hasArrow = true
        Priests.value = {
            ['key'] = 'priest'
        }
        UIDropDownMenu_AddButton(Priests, UIDROPDOWNMENU_MENU_LEVEL);

        local Rogues = {}
        Rogues.text = TWA.classColors['rogue'].c .. 'Rogues'
        Rogues.notCheckable = true
        Rogues.hasArrow = true
        Rogues.value = {
            ['key'] = 'rogue'
        }
        UIDropDownMenu_AddButton(Rogues, UIDROPDOWNMENU_MENU_LEVEL);

        local Hunters = {}
        Hunters.text = TWA.classColors['hunter'].c .. 'Hunters'
        Hunters.notCheckable = true
        Hunters.hasArrow = true
        Hunters.value = {
            ['key'] = 'hunter'
        }
        UIDropDownMenu_AddButton(Hunters, UIDROPDOWNMENU_MENU_LEVEL);

        local Shamans = {}
        Shamans.text = TWA.classColors['shaman'].c .. 'Shamans'
        Shamans.notCheckable = true
        Shamans.hasArrow = true
        Shamans.value = {
            ['key'] = 'shaman'
        }
        UIDropDownMenu_AddButton(Shamans, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator);

        -- local addRegular = {};
        -- addRegular.text = "|c0000ff00Add Regular"
        -- addRegular.disabled = false
        -- addRegular.isTitle = false
        -- addRegular.notCheckable = true
        -- addRegular.func = TWA.addRegularClicked
        -- addRegular.arg1 = TWA.currentRow * 100 + TWA.currentCell
        -- UIDropDownMenu_AddButton(addRegular, UIDROPDOWNMENU_MENU_LEVEL);

        local clear = {};
        clear.text = "Clear"
        clear.disabled = false
        clear.isTitle = false
        clear.notCheckable = true
        clear.func = TWA.changeCell
        clear.arg1 = TWA.currentRow * 100 + TWA.currentCell
        clear.arg2 = 'Clear'
        UIDropDownMenu_AddButton(clear, UIDROPDOWNMENU_MENU_LEVEL);
    end
    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        for i, tank in next, TWA.raid[UIDROPDOWNMENU_MENU_VALUE['key']] do
            local Tanks = {}

            local color = TWA.classColors[UIDROPDOWNMENU_MENU_VALUE['key']].c

            if TWA.isPlayerOffline(tank) then
                color = '|cffff0000'
            end

            Tanks.text = color .. tank
            Tanks.checked = TWA.markOrPlayerUsed(tank)
            Tanks.func = TWA.changeCell
            Tanks.arg1 = TWA.currentRow * 100 + TWA.currentCell
            Tanks.arg2 = tank
            UIDropDownMenu_AddButton(Tanks, UIDROPDOWNMENU_MENU_LEVEL);
        end
    end
end

function TWA.buildHealersDropdown()
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local Healers = {}
        Healers.text = "Healers"
        Healers.isTitle = true
        UIDropDownMenu_AddButton(Healers, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

        local Priests = {}
        Priests.text = TWA.classColors['priest'].c .. 'Priests'
        Priests.notCheckable = true
        Priests.hasArrow = true
        Priests.value = {
            ['key'] = 'priest'
        }
        UIDropDownMenu_AddButton(Priests, UIDROPDOWNMENU_MENU_LEVEL);

        local Druids = {}
        Druids.text = TWA.classColors['druid'].c .. 'Druids'
        Druids.notCheckable = true
        Druids.hasArrow = true
        Druids.value = {
            ['key'] = 'druid'
        }
        UIDropDownMenu_AddButton(Druids, UIDROPDOWNMENU_MENU_LEVEL);

        local Shamans = {}
        Shamans.text = TWA.classColors['shaman'].c .. 'Shamans'
        Shamans.notCheckable = true
        Shamans.hasArrow = true
        Shamans.value = {
            ['key'] = 'shaman'
        }
        UIDropDownMenu_AddButton(Shamans, UIDROPDOWNMENU_MENU_LEVEL);

        local Paladins = {}
        Paladins.text = TWA.classColors['paladin'].c .. 'Paladins'
        Paladins.notCheckable = true
        Paladins.hasArrow = true
        Paladins.value = {
            ['key'] = 'paladin'
        }
        UIDropDownMenu_AddButton(Paladins, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator);

        local clear = {};
        clear.text = "Clear"
        clear.disabled = false
        clear.isTitle = false
        clear.notCheckable = true
        clear.func = TWA.changeCell
        clear.arg1 = TWA.currentRow * 100 + TWA.currentCell
        clear.arg2 = 'Clear'
        UIDropDownMenu_AddButton(clear, UIDROPDOWNMENU_MENU_LEVEL);
    end
    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        for _, healer in next, TWA.raid[UIDROPDOWNMENU_MENU_VALUE['key']] do
            local Healers = {}

            local color = TWA.classColors[UIDROPDOWNMENU_MENU_VALUE['key']].c

            if TWA.isPlayerOffline(healer) then
                color = '|cffff0000'
            end

            Healers.text = color .. healer
            Healers.checked = TWA.markOrPlayerUsed(healer)
            Healers.func = TWA.changeCell
            Healers.arg1 = TWA.currentRow * 100 + TWA.currentCell
            Healers.arg2 = healer
            UIDropDownMenu_AddButton(Healers, UIDROPDOWNMENU_MENU_LEVEL);
        end
    end
end

function TWA.changeCell(xy, to, dontOpenDropdown)
    dontOpenDropdown = dontOpenDropdown and 1 or 0
    TWA.sync.SendAddonMessage(TWA.MESSAGE.ChangeCell .. "=" .. xy .. "=" .. to .. "=" .. dontOpenDropdown)
    CloseDropDownMenus()
end

function TWA.change(xy, to, sender, dontOpenDropdown)
    local x = math.floor(xy / 100)
    local y = xy - x * 100

    if to ~= 'Clear' then
        TWA.data[x][y] = to
    else
        TWA.data[x][y] = '-'
    end

    TWA.PopulateTWA()
end

function TWA.PopulateTWA()
    twadebug('PopulateTWA')

    for i = 1, 25 do
        if TWA.rows[i] then
            TWA.rows[i]:Hide()
        end
    end

    for index, data in next, TWA.data do
        if not TWA.rows[index] then
            TWA.rows[index] = CreateFrame('Frame', 'TWRow' .. index, getglobal("TWA_Main"), 'TWRow')
        end

        TWA.rows[index]:Show()

        TWA.rows[index]:SetBackdropColor(0, 0, 0, .2);

        TWA.rows[index]:SetPoint("TOP", getglobal("TWA_Main"), "TOP", 0, -25 - index * 21)
        if not TWA.cells[index] then
            TWA.cells[index] = {}
        end

        getglobal('TWRow' .. index .. 'CloseRow'):SetID(index)

        local line = ''

        for i, name in data do
            if not TWA.cells[index][i] then
                TWA.cells[index][i] = CreateFrame('Frame', 'TWCell' .. index .. i, TWA.rows[index], 'TWCell')
            end

            TWA.cells[index][i]:SetPoint("LEFT", TWA.rows[index], "LEFT", -82 + i * 82, 0)

            getglobal('TWCell' .. index .. i .. 'Button'):SetID((index * 100) + i)

            local color = TWA.classColors['priest'].c
            TWA.cells[index][i]:SetBackdropColor(.2, .2, .2, .7);
            if i > 1 then
                for c, n in next, TWA.raid do
                    for _, raidMember in next, n do
                        if raidMember == name then
                            color = TWA.classColors[c].c
                            local r = TWA.classColors[c].r
                            local g = TWA.classColors[c].g
                            local b = TWA.classColors[c].b
                            TWA.cells[index][i]:SetBackdropColor(r, g, b, .7);
                            break
                        end
                    end
                end
            end


            if TWA.marks[name] then
                color = TWA.marks[name]
            end
            if TWA.sides[name] then
                color = TWA.sides[name]
            end
            if TWA.coords[name] then
                color = TWA.coords[name]
            end
            if TWA.misc[name] then
                color = TWA.misc[name]
            end
            if TWA.groups[name] then
                color = TWA.groups[name]
            end

            if name == '-' then
                name = ''
            end

            if i > 1 and name ~= '' and TWA.isPlayerOffline(name) then
                color = '|cffff0000'
            end

            getglobal('TWCell' .. index .. i .. 'Text'):SetText(color .. name)

            getglobal('TWCell' .. index .. i .. 'Icon'):Hide()
            getglobal('TWCell' .. index .. i .. 'Icon'):SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons");

            if name == 'Skull' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0.75, 1, 0.25, 0.5)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Cross' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0.5, 0.75, 0.25, 0.5)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Square' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0.25, 0.5, 0.25, 0.5)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Moon' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0, 0.25, 0.25, 0.5)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Triangle' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0.75, 1, 0, 0.25)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Diamond' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0.5, 0.75, 0, 0.25)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Circle' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0.25, 0.5, 0, 0.25)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end
            if name == 'Star' then
                getglobal('TWCell' .. index .. i .. 'Icon'):SetTexCoord(0, 0.25, 0, 0.25)
                getglobal('TWCell' .. index .. i .. 'Icon'):Show()
            end

            line = line .. name .. '-'
        end
    end

    getglobal('TWA_Main'):SetHeight(50 + table.getn(TWA.data) * 21)
    TWA_DATA = TWA.data
end

function Buttoane_OnEnter(id)
    local index = math.floor(id / 100)

    if id < 100 then
        index = id
    end

    getglobal('TWRow' .. index):SetBackdropColor(1, 1, 1, .2)
end

function Buttoane_OnLeave(id)
    local index = math.floor(id / 100)

    if id < 100 then
        index = id
    end

    getglobal('TWRow' .. index):SetBackdropColor(0, 0, 0, .2)
end

function TWAHandleRosterEditBox(editBox)
    local scrollBar = getglobal(editBox:GetParent():GetName() .. "ScrollBar")
    editBox:GetParent():UpdateScrollChildRect();

    local _, max = scrollBar:GetMinMaxValues();
    scrollBar.prevMaxValue = scrollBar.prevMaxValue or max

    if math.abs(scrollBar.prevMaxValue - scrollBar:GetValue()) <= 1 then
        -- if scroll is down and add new line then move scroll
        scrollBar:SetValue(max);
    end
    if max ~= scrollBar.prevMaxValue then
        -- save max value
        scrollBar.prevMaxValue = max
    end
end

TWA.currentRow = 0
TWA.currentCell = 0

function TWCell_OnClick(id)
    if not TWA_CanMakeChanges() then return end
    TWA.currentRow = math.floor(id / 100)
    TWA.currentCell = id - TWA.currentRow * 100

    --targets
    if TWA.currentCell == 1 then
        UIDropDownMenu_Initialize(TWATargetsDropDown, TWA.buildTargetsDropdown, "MENU");
        ToggleDropDownMenu(1, nil, TWATargetsDropDown, "cursor", 2, 3);
    end

    --tanks
    if TWA.currentCell == 2 or TWA.currentCell == 3 or TWA.currentCell == 4 then
        UIDropDownMenu_Initialize(TWATanksDropDown, TWA.buildTanksDropdown, "MENU");
        ToggleDropDownMenu(1, nil, TWATanksDropDown, "cursor", 2, 3);
    end

    --healers
    if TWA.currentCell == 5 or TWA.currentCell == 6 or TWA.currentCell == 7 then
        UIDropDownMenu_Initialize(TWAHealersDropDown, TWA.buildHealersDropdown, "MENU");
        ToggleDropDownMenu(1, nil, TWAHealersDropDown, "cursor", 2, 3);
    end

    if IsControlKeyDown() then
        CloseDropDownMenus()
        TWA.changeCell(TWA.currentRow * 100 + TWA.currentCell, "Clear")
    end
end

function AddLine_OnClick()
    if not TWA_CanMakeChanges() then return end
    TWA.sync.SendAddonMessage(TWA.MESSAGE.AddLine)
end

function TWA.AddLine()
    if table.getn(TWA.data) < 10 then
        TWA.data[table.getn(TWA.data) + 1] = { '-', '-', '-', '-', '-', '-', '-' };
        TWA.PopulateTWA()
    end
end

function SpamRaid_OnClick()
    if not TWA_CanMakeChanges() then return end
    ChatThrottleLib:SendChatMessage("BULK", "TWA", "======= RAID ASSIGNMENTS =======", "RAID_WARNING")

    for _, data in next, TWA.data do
        local line = ''
        local dontPrintLine = true
        for i, name in data do
            if i > 1 then
                dontPrintLine = dontPrintLine and name == '-'
            end

            local separator = ''
            if i == 1 then
                separator = ' : '
            end
            if i == 4 then
                separator = ' || Healers: '
            end

            if name == '-' then
                name = ''
            end

            if TWA.loadedTemplate == '4h' then
                if name ~= '' and i >= 5 then
                    name = '[' .. i - 4 .. ']' .. name
                end
            end

            line = line .. name .. ' ' .. separator
        end

        if not dontPrintLine then
            ChatThrottleLib:SendChatMessage("BULK", "TWA", line, "RAID")
        end
    end
    ChatThrottleLib:SendChatMessage("BULK", "TWA",
        "Not assigned, heal the raid. Whisper me 'heal' if you forget your assignment.", "RAID")
end

function RemRow_OnClick(id)
    if not TWA_CanMakeChanges() then return end
    TWA.sync.SendAddonMessage(TWA.MESSAGE.RemRow .. "=" .. id)
end

function TWA.RemRow(id, sender)
    if TWA.data[id + 1] then
        TWA.data[id] = TWA.data[id + 1]
    end

    local last

    for i in next, TWA.data do
        if i > id then
            if TWA.data[i + 1] then
                TWA.data[i] = TWA.data[i + 1]
            end
        end
        last = i
    end

    TWA.data[last] = nil

    TWA.PopulateTWA()
end

function Reset_OnClick()
    if not TWA_CanMakeChanges() then return end

    StaticPopupDialogs["TWA_RESET_CONFIRM"] = {
        text = "Are you sure you want to clear current assignments?",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept = function()
            TWA.sync.SendAddonMessage(TWA.MESSAGE.Reset)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    }
    StaticPopup_Show("TWA_RESET_CONFIRM")
end

function TWA.WipeTable()
    for i = 1, table.getn(TWA.data) do
        for j = 2, 7 do -- skip target col
            TWA.data[i][j] = '-'
        end
    end
    TWA.PopulateTWA()
end

function TWA.Reset()
    for index, data in next, TWA.data do
        if TWA.rows[index] then
            TWA.rows[index]:Hide()
        end
        if TWA.data[index] then
            TWA.data[index] = nil
        end
    end
    TWA.data = {
        [1] = { '-', '-', '-', '-', '-', '-', '-' },
    }
    TWA.PopulateTWA()
end

function CloseTWA_OnClick()
    getglobal('TWA_Main'):Hide()
    TWA_CloseRosterFrame()
end

function toggle_TWA_Main()
    if (getglobal('TWA_Main'):IsVisible()) then
        getglobal('TWA_Main'):Hide()
        getglobal('TWA_RosterManager'):Hide()
    else
        getglobal('TWA_Main'):Show()
    end
end

function buildTemplatesDropdown()
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        local Title = {}
        Title.text = "Templates"
        Title.isTitle = true
        UIDropDownMenu_AddButton(Title, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

        local Trash = {}
        Trash.text = "Trash"
        Trash.notCheckable = true
        Trash.hasArrow = true
        Trash.value = {
            ['key'] = 'trash'
        }
        UIDropDownMenu_AddButton(Trash, UIDROPDOWNMENU_MENU_LEVEL);

        local separator = {};
        separator.text = ""
        separator.disabled = true
        UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

        local Raids = {}
        Raids.text = "Molten Core"
        Raids.notCheckable = true
        Raids.hasArrow = true
        Raids.value = {
            ['key'] = 'mc'
        }
        UIDropDownMenu_AddButton(Raids, UIDROPDOWNMENU_MENU_LEVEL);

        Raids = {}
        Raids.text = "Blackwing Lair"
        Raids.notCheckable = true
        Raids.hasArrow = true
        Raids.value = {
            ['key'] = 'bwl'
        }
        UIDropDownMenu_AddButton(Raids, UIDROPDOWNMENU_MENU_LEVEL);

        Raids = {}
        Raids.text = "Ahn\'Quiraj"
        Raids.notCheckable = true
        Raids.hasArrow = true
        Raids.value = {
            ['key'] = 'aq40'
        }
        UIDropDownMenu_AddButton(Raids, UIDROPDOWNMENU_MENU_LEVEL);

        Raids = {}
        Raids.text = "Naxxramas"
        Raids.notCheckable = true
        Raids.hasArrow = true
        Raids.value = {
            ['key'] = 'naxx'
        }
        UIDropDownMenu_AddButton(Raids, UIDROPDOWNMENU_MENU_LEVEL);
    end

    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        if UIDROPDOWNMENU_MENU_VALUE["key"] == 'trash' then
            for i = 1, 5 do
                local dropdownItem = {}
                dropdownItem.text = "Trash #" .. i
                dropdownItem.func = TWA.loadTemplate
                dropdownItem.arg1 = 'trash' .. i
                dropdownItem.arg2 = false
                UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            end
        end

        if UIDROPDOWNMENU_MENU_VALUE["key"] == 'mc' then
            local dropdownItem = {}
            dropdownItem.text = "Gaar"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'gaar'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Majordomo"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'domo'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Ragnaros"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'rag'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil
        end

        if UIDROPDOWNMENU_MENU_VALUE["key"] == 'bwl' then
            local dropdownItem = {}
            dropdownItem.text = "Razorgore"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'razorgore'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Vaelastrasz"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'vael'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Lashlayer"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'lashlayer'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Chromaggus"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'chromaggus'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Nefarian"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'nef'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil
        end

        if UIDROPDOWNMENU_MENU_VALUE["key"] == 'aq40' then
            local dropdownItem = {}
            dropdownItem.text = "The Prophet Skeram"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'skeram'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Bug Trio"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'bugtrio'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Battleguard Sartura"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'sartura'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Fankriss"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'fankriss'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Huhuran"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'huhu'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Twin Emps"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'twins'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil
        end

        if UIDROPDOWNMENU_MENU_VALUE["key"] == 'naxx' then
            local dropdownItem = {}
            dropdownItem.text = "Anub'rekhan"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'anub'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Faerlina"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'faerlina'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Maexxna"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'maexxna'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            local separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            dropdownItem = {}
            dropdownItem.text = "Noth"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'noth'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Heigan"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'heigan'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            dropdownItem = {}
            dropdownItem.text = "Razuvious"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'raz'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Gothik"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'gothik'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Four Horsemen"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = '4h'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            dropdownItem = {}
            dropdownItem.text = "Patchwerk"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'patchwerk'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Grobbulus"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'grobulus'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Gluth"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'gluth'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Thaddius"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'thaddius'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            separator = {};
            separator.text = ""
            separator.disabled = true
            UIDropDownMenu_AddButton(separator, UIDROPDOWNMENU_MENU_LEVEL);

            dropdownItem = {}
            dropdownItem.text = "Sapphiron"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'saph'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil

            dropdownItem = {}
            dropdownItem.text = "Kel'Thusad"
            dropdownItem.func = TWA.loadTemplate
            dropdownItem.arg1 = 'kt'
            dropdownItem.arg2 = false
            UIDropDownMenu_AddButton(dropdownItem, UIDROPDOWNMENU_MENU_LEVEL);
            dropdownItem = nil
        end
    end
end

function Templates_OnClick()
    if not TWA_CanMakeChanges() then return end
    UIDropDownMenu_Initialize(TWATemplates, buildTemplatesDropdown, "MENU");
    ToggleDropDownMenu(1, nil, TWATemplates, "cursor", 2, 3);
end

function LoadPreset_OnClick()
    if not TWA_CanMakeChanges() then return end
    if TWA.loadedTemplate == '' then
        twaprint('Please load a template first.')
    else
        TWA.loadTemplate(TWA.loadedTemplate)
        TWA.sync.BroadcastWipeTable()
        if TWA_PRESETS[TWA.loadedTemplate] then
            for index, data in next, TWA_PRESETS[TWA.loadedTemplate] do
                for i, name in data do
                    if i ~= 1 and name ~= '-' then
                        TWA.changeCell(index * 100 + i, name, true)
                    end
                end
            end
        else
            twaprint('No preset saved for |cff69ccf0' .. TWA.loadedTemplate)
        end
    end
end

function SavePreset_OnClick()
    if not TWA_CanMakeChanges() then return end
    if TWA.loadedTemplate == '' then
        twaprint('Please load a template first.')
    else
        local preset = {}
        for index, data in next, TWA.data do
            preset[index] = {}
            for i, name in data do
                table.insert(preset[index], name)
            end
        end
        TWA_PRESETS[TWA.loadedTemplate] = preset
        twaprint('Saved preset for |cff69ccf0' .. TWA.loadedTemplate)
    end
end

function SyncBW_OnClick()
    if not TWA_CanMakeChanges() then return end
    TWA.sync.SendAddonMessage("BWSynch=start", "TWABW")
    for _, data in next, TWA.data do
        local line = ''
        local dontPrintLine = true
        for i, name in data do
            dontPrintLine = dontPrintLine and name == '-'
            local separator = ''
            if i == 1 then
                separator = ' : '
            end
            if i == 4 then
                separator = ' || Healers: '
            end

            if name == '-' then
                name = ''
            end

            if TWA.loadedTemplate == '4h' then
                if name ~= '' and i >= 5 then
                    name = '[' .. i - 4 .. ']' .. name
                end
            end

            line = line .. name .. ' ' .. separator
        end

        if not dontPrintLine then
            TWA.sync.SendAddonMessage("BWSynch=" .. line, "TWABW")
        end
    end
    TWA.sync.SendAddonMessage("BWSynch=end", "TWABW")
end

---@param delimiter string
---@return table<integer, string>
function string:split(delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(self, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(self, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(self, delimiter, from)
    end
    table.insert(result, string.sub(self, from))
    return result
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, function(a, b)
        return a < b
    end)
    local i = 0 -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end
