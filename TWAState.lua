TWA.data = {}
TWA.rows = {}
TWA.cells = {}
TWA.loadedTemplate = '' ---@type string

TWA._assistants = {} ---@type table<integer, string>
TWA._firstSyncComplete = false;
TWA._leader = nil ---@type string|nil
TWA._leaderOnline = false ---@type boolean
TWA._playerGroupState = nil ---@type TWAGroupState
TWA._playerGroupStateInitialized = false
TWA._raidStateInitialized = false;

---When a player joins a raid group, both the PARTY_MEMBERS_CHANGED and RAID_ROSTER_UPDATE events are fired, in that order.
---I want to treat them as the same even IF they happen within half a second of each other. That is the purpose of this timeout.
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
TWA.otherPeoplesRosters = {}

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
