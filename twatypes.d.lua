---@meta

---@alias WowClass 'druid' | 'hunter' | 'mage' | 'paladin' | 'priest' | 'rogue' | 'shaman' | 'warlock' | 'warrior'
---@alias Roster table<WowClass, table<integer, string>>

---@class ClassSection
---@field expanded boolean
---@field frame Frame
---@field expandButton Button
---@field addPlayerButton Button
---@field class WowClass
---@field frames table<integer, Frame>
ClassSection = {}

---@class AddPlayers
---@field _currentClass WowClass|nil
---@field header FontString
---@field help FontString
---@field frame Frame
---@field done Button
---@field cancel Button
---@field editBox EditBox
AddPlayers = {}

