TWA.CHECK_TIMEOUTS_EACH_N_FRAMES = 10
TWA.DOUBLE_EVENT_TIMEOUT = 0.5 -- seconds
TWA.LOGIN_GRACE_PERIOD = 2.0   -- seconds
TWA.MAX_NAMES_PER_MESSAGE = 10
TWA.ROSTERFRAME_CLASSSECTION_BASE_HEIGHT = 30;
TWA.ROSTERFRAME_CLASSSECTION_ENTRY_HEIGHT = 15;
TWA.ROSTERFRAME_CLASSSECTION_EXPANDMARGIN = 6;
TWA.SORTED_CLASS_NAMES = { 'druid', 'hunter', 'mage', 'paladin', 'priest', 'rogue', 'shaman', 'warlock', 'warrior' }

TWA.DEBUG = {
    DISABLED = 1,
    NORMAL = 2,
    VERBOSE = 3,
}



---@type table<TWAWowClass, TWAWowColor>
TWA.classColors = {
    ["druid"] = { r = 1, g = 0.49, b = 0.04, c = "|cffff7d0a" },
    ["hunter"] = { r = 0.67, g = 0.83, b = 0.45, c = "|cffabd473" },
    ["mage"] = { r = 0.41, g = 0.8, b = 0.94, c = "|cff69ccf0" },
    ["paladin"] = { r = 0.96, g = 0.55, b = 0.73, c = "|cfff58cba" },
    ["priest"] = { r = 1, g = 1, b = 1, c = "|cffffffff" },
    ["rogue"] = { r = 1, g = 0.96, b = 0.41, c = "|cfffff569" },
    ["shaman"] = { r = 0.14, g = 0.35, b = 1.0, c = "|cff0070de" },
    ["warlock"] = { r = 0.58, g = 0.51, b = 0.79, c = "|cff9482c9" },
    ["warrior"] = { r = 0.78, g = 0.61, b = 0.43, c = "|cffc79c6e" },
}

TWA.marks = {
    ['Star'] = TWA.classColors['rogue'].c,
    ['Circle'] = TWA.classColors['druid'].c,
    ['Diamond'] = TWA.classColors['paladin'].c,
    ['Triangle'] = TWA.classColors['hunter'].c,
    ['Moon'] = '|cffffffff',
    ['Square'] = TWA.classColors['mage'].c,
    ['Cross'] = '|cffff0000',
    ['Skull'] = '|cffffffff',
}

TWA.sides = {
    --if changed also change in buildTargetsDropdown !
    ['Left'] = TWA.classColors['warlock'].c,
    ['Right'] = TWA.classColors['mage'].c,
}

TWA.coords = {
    --if changed also change in buildTargetsDropdown !
    ['North'] = '|cffffffff',
    ['South'] = '|cffffffff',
    ['East'] = '|cffffffff',
    ['West'] = '|cffffffff',
    ['NorthWest'] = TWA.classColors['rogue'].c,
    ['NorthEast'] = TWA.classColors['rogue'].c,
    ['SouthEast'] = TWA.classColors['rogue'].c,
    ['SouthWest'] = TWA.classColors['rogue'].c,
}
TWA.misc = {
    ['Raid'] = TWA.classColors['shaman'].c,
    ['Melee'] = TWA.classColors['rogue'].c,
    ['Ranged'] = TWA.classColors['mage'].c,
    ['Adds'] = TWA.classColors['paladin'].c,
    ['BOSS'] = '|cffff3333',
    ['Enrage'] = '|cffff7777',
    ['Wall'] = TWA.classColors['hunter'].c,
    ['Living'] = TWA.classColors['warrior'].c,
    ['Dead'] = TWA.classColors['druid'].c,
    ['Dispels'] = TWA.classColors['mage'].c,
    ['Soaker'] = TWA.classColors['druid'].c,
}

TWA.groups = {
    ['Group 1'] = TWA.classColors['priest'].c,
    ['Group 2'] = TWA.classColors['priest'].c,
    ['Group 3'] = TWA.classColors['priest'].c,
    ['Group 4'] = TWA.classColors['priest'].c,
    ['Group 5'] = TWA.classColors['priest'].c,
    ['Group 6'] = TWA.classColors['priest'].c,
    ['Group 7'] = TWA.classColors['priest'].c,
    ['Group 8'] = TWA.classColors['priest'].c,
}
