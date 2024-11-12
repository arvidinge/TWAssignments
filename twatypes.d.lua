---@meta

---@alias TWAGroupState 'alone' | 'party'| 'raid'
---@alias TWAWowClass 'druid' | 'hunter' | 'mage' | 'paladin' | 'priest' | 'rogue' | 'shaman' | 'warlock' | 'warrior'
---@alias TWARoster table<TWAWowClass, table<integer, string>>
---@alias TWAPlayer string
---@alias TWAConversationId string
---@alias TWADataHash string
---@alias TWAMsgCallbackFn fun(packet: TWAPacket): nil

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

---@class TWASendAddonMessageArgs
---@field text string
---@field prefix string|nil Default "TWA"
---@field prio "BULK"|"NORMAL"|"ALERT"|nil Default "ALERT". Seems like only ALERT guarantees order.
---@field chattype "PARTY"|"RAID"|"GUILD"|"OFFICER"|"BATTLEGROUND"|nil Default "RAID"
---@field conversationId string|nil Optional conversationId for back-and-forth addon message conversations. Auto-generated when not provided.
---@field callbackFn TWAMsgCallbackFn|nil Optional callback when message has been sent and received.
TWASendAddonMessageArgs = {}

---@class TWAPacketHeaders
---@field version string Addon version of sender
---@field messageId string Id of the message
---@field conversationId string Id of the conversation (set of related back-and-forth messages)
---@field RESERVED_1 '-' Reserved for future use
---@field RESERVED_2 '-' Reserved for future use
---@field RESERVED_3 '-' Reserved for future use
TWAPacketHeaders = {}

---@class TWAPacketMessage
---@field type string One of the entries of TWA.MESSAGE, example "FullSync"
---@field args table<integer, string> Arguments for the message, for example cell values or 'start'/'end' during FullSync
TWAMessage = {}

---@class TWAPacket
---@field headers TWAPacketHeaders Packet headers
---@field message TWAPacketMessage Packet message
TWAPacket = {}


