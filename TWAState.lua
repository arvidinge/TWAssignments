TWA.data = {}
TWA.rows = {}
TWA.cells = {}
TWA.loadedTemplate = '' ---@type string

TWA._assistants = {} ---@type table<string, boolean>
TWA._leader = nil ---@type string|nil
TWA._playerGroupState = nil ---@type TWAGroupState
TWA._playerGroupStateInitialized = false;
TWA._raidStateInitialized = false;

---Keep track of hashes of data given by other players when you join the group, so that you can select a player to broadcast the data table.<br/>
---Example structure:
---```
--- TWA._syncConversations = {
---     conversationId = {
---         hash1 = { "Player1", "Player2" },
---         hash2 = { "Player3" },
---     }
--- }
--- ```
---@type table<TWAConversationId, table<TWADataHash, table<integer, TWAPlayer>>> 
TWA._syncConversations = {}

---table<conversationId, timeoutId>
---@type table<string, string>
TWA.syncRequestTimeouts = {}

---Holds registered callbacks to invoke when message has looped back.<br/>
---Example structure:
---```
--- TWA._messageCallbacks = {
---     ['messageId1'] = function(packet) twaprint('first message sent') end,
---     ['messageId2'] = function(packet) twaprint('second message sent') end
--- }
---```
---@type table<string, TWAMsgCallbackFn> 
TWA._messageCallbacks = {}

---When a player joins a raid group, both the PARTY_MEMBERS_CHANGED and RAID_ROSTER_UPDATE events are fired, in that order.
---I want to treat them as the same even IF they happen very close in time to each other. That is the purpose of this timeout.
---@type string|nil
TWA.partyAndRaidCombinedEventTimeoutId = nil

---@type TWARoster
TWA.roster = {
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

---@type table<string, TWARoster>
TWA.foreignRosters = {}

---@type TWARoster
TWA.raid = {
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
