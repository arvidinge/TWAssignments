---@meta

---@alias TWAGroupState 'alone' | 'party'| 'raid'
---@alias TWAWowClass 'druid' | 'hunter' | 'mage' | 'paladin' | 'priest' | 'rogue' | 'shaman' | 'warlock' | 'warrior'
---@alias TWARoster table<TWAWowClass, table<integer, string>>

---@class TWAClassSection
---@field expanded boolean
---@field frame Frame
---@field expandButton Button
---@field addPlayerButton Button
---@field class TWAWowClass
---@field frames table<integer, Frame>
TWAClassSection = {}

---@class TWAAddPlayers
---@field _currentClass TWAWowClass|nil
---@field header FontString
---@field help FontString
---@field frame Frame
---@field done Button
---@field cancel Button
---@field editBox EditBox
TWAAddPlayers = {}

---@class TWAWowColor
---@field r number
---@field g number
---@field b number
---@field a number|nil
---@field c string Color code for use in fonstrings, example <code>|cffff7d0a</code>
TWAWowColor = {}

---@class TWATimeoutCallback
---@field id string
---@field startTime number
---@field delay number
---@field callback function
TWATimeoutCallback = {}