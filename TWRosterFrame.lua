local function strCapitalize(str)
  return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

-- TWAAddPlayers Start #########################
TWAAddPlayers = {}
TWAAddPlayers.__index = TWAAddPlayers

--- Creates a new TWAAddPlayers instance
---@param frame Frame
---@param editBox EditBox
---@param class TWAWowClass|nil
---@param header FontString
---@param help FontString
---@param done Button
---@param cancel Button
---@return TWAAddPlayers
function TWAAddPlayers:new(frame, editBox, header, help, done, cancel, class)
  ---@type TWAAddPlayers
  local obj = {
    currentClass = class, -- Initialize with nil class
    frame = frame,
    editBox = editBox,
    header = header,
    done = done,
    cancel = cancel,
    help = help
  }
  setmetatable(obj, TWAAddPlayers)
  return obj
end

--- Gets the text from the editbox
---@param self TWAAddPlayers
---@return string
function TWAAddPlayers:GetText()
  return self.editBox:GetText() -- Assume EditBox has a method GetText
end

--- Sets the text in the editbox
---@param self TWAAddPlayers
---@param text string
function TWAAddPlayers:SetText(text)
  self.editBox:SetText(text) -- Assume EditBox has a method SetText
end

--- Sets the class you're adding players to
---@param self TWAAddPlayers
---@param class TWAWowClass
function TWAAddPlayers:SetClass(class)
  self._currentClass = class
  local color = TWA.classColors[class].c;
  local reset = '|r'
  self.header:SetText('Add new ' .. TWA.classColors[class].c .. strCapitalize(class) .. 's')
  self.help:SetText('Please enter one ' ..
    color .. class .. reset .. ' name \nper row, then click Done to \nadd them to your roster.')
end

--- Gets the class you're adding players to
---@param self TWAAddPlayers
---@return TWAWowClass
function TWAAddPlayers:GetClass()
  return self._currentClass
end

-- TWAAddPlayers End #########################



---@return Frame
local getRosterFrame = function() return getglobal('TWA_RosterManager') end

---@type Frame
local RosterFrameBox = nil;
---@type Frame
local RosterFrameScroll = nil;
---@type Frame
local RosterFrameContainer = nil;

---@type TWAAddPlayers
local addPlayers;



-- TWAClassSection Start #########################
TWAClassSection = {}
TWAClassSection.__index = TWAClassSection

---@param frame Frame
---@param expandButton Button
---@param addPlayerButton Button
---@param class TWAWowClass
function TWAClassSection:new(frame, expandButton, addPlayerButton, class)
  ---@type TWAClassSection
  local obj = {
    class = class,
    frame = frame,
    expandButton = expandButton,
    addPlayerButton = addPlayerButton,
    expanded = false,
    frames = {}
  }

  setmetatable(obj, TWAClassSection)
  return obj
end

---@param self TWAClassSection
---@param name string
---@param class TWAWowClass
---@return Frame
function TWAClassSection:_buildNameFrame(name, class)
  local parent = self.frame;
  local frameName = "TWA_RosterEntry" .. name;
  local frame = CreateFrame("Frame", "TWA_RosterEntry" .. name, parent)
  frame:Hide()
  frame:SetPoint('Right', parent, 'Right', 0, 0)
  frame:SetHeight(TWA.ROSTERFRAME_CLASSSECTION_ENTRY_HEIGHT)
  frame:SetWidth(parent:GetWidth() - 7)
  frame:EnableMouse(true);

  local texture = frame:CreateTexture("blabla", "ARTWORK")
  texture:SetPoint("TopLeft", frame, "TopLeft", 0, 0)
  texture:SetHeight(frame:GetHeight())
  texture:SetWidth(frame:GetWidth())
  texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
  texture:SetBlendMode("ADD")
  texture:SetVertexColor(1, 1, 0, 1)
  texture:Hide()

  frame:SetScript("OnEnter", function() texture:Show() end)
  frame:SetScript("OnLeave", function() texture:Hide() end)

  local text = frame:CreateFontString(frameName .. 'text', "OVERLAY", "GameFontNormalSmall")
  text:SetPoint('Left', frame, "Left", 0, 0)
  text:SetTextColor(
    TWA.classColors[class].r,
    TWA.classColors[class].g,
    TWA.classColors[class].b
  );
  text:SetText(name)

  local removeButton = CreateFrame("Button", "TWA_RosterEntryRemove" .. name, frame, "UIPanelCloseButton")
  removeButton:SetPoint("Right", frame, "Right", 0, 0)
  removeButton:SetHeight(20);
  removeButton:SetWidth(20);
  removeButton:SetScript("OnClick", function()
    if CloseDropDownMenus then CloseDropDownMenus() end
    local classRoster = TWA.roster[self.class];
    local indexToDelete = TWA.util.tablePosOf(classRoster, name)
    if indexToDelete ~= nil then
      table.remove(classRoster, indexToDelete);
      TWA.BroadcastRosterEntryDeleted(self.class, name)
    end
    self:Update();
  end)

  removeButton:SetScript("OnEnter", function() texture:Show() end)
  removeButton:SetScript("OnLeave", function() texture:Hide() end)

  return frame;
end

---@param self TWAClassSection
function TWAClassSection:Expand()
  local class = self.class
  local names = TWA.roster[class]
  table.sort(names)

  for i, name in pairs(names) do
    ---@type Frame
    local frame = self.frames[name]

    -- Build missing frame
    if frame == nil then
      frame = self:_buildNameFrame(name, class)
      self.frames[name] = frame;
    end

    frame:SetPoint("TopRight", self.frame, "TopRight", 0,
      -TWA.ROSTERFRAME_CLASSSECTION_BASE_HEIGHT - (i - 1) * TWA.ROSTERFRAME_CLASSSECTION_ENTRY_HEIGHT)
    frame:Show();
  end

  self.frame:SetHeight(
    TWA.ROSTERFRAME_CLASSSECTION_BASE_HEIGHT +
    table.getn(names) * TWA.ROSTERFRAME_CLASSSECTION_ENTRY_HEIGHT +
    TWA.ROSTERFRAME_CLASSSECTION_EXPANDMARGIN)

  self.expanded = true;
  self.expandButton:SetText("v");
end

---@param self TWAClassSection
function TWAClassSection:Collapse()
  for _, frame in pairs(self.frames) do
    frame:Hide()
  end
  self.frame:SetHeight(TWA.ROSTERFRAME_CLASSSECTION_BASE_HEIGHT);
  self.expandButton:SetText(">");
  self.expanded = false;
end

---@param self TWAClassSection
---@return table<integer, string>
function TWAClassSection:GetRoster()
  return TWA.roster[self.class]
end

---@param self TWAClassSection
function TWAClassSection:Update()
  TWA.fillRaidData()
  TWA.PopulateTWA()
  TWA.persistRoster()

  if table.getn(self:GetRoster()) > 0 then
    self.expandButton:Enable()
  else
    self:Collapse()
    self.expandButton:Disable()
  end

  if self.expanded then
    self:Collapse()
    self:Expand() -- this builds missing frames
  end
end

-- TWAClassSection end #########################

---@type table<TWAWowClass, TWAClassSection|nil>
local ClassSections = {
  ['druid'] = nil,
  ['hunter'] = nil,
  ['mage'] = nil,
  ['paladin'] = nil,
  ['priest'] = nil,
  ['rogue'] = nil,
  ['shaman'] = nil,
  ['warlock'] = nil,
  ['warrior'] = nil,
}

function TWA_CloseRosterFrame()
  getRosterFrame():Hide()
end

function TWA_ShowRosterFrame()
  getRosterFrame():Show()
end

function TWA_AddPlayersFrameLoaded()
  local basename = 'TWA_RosterManagerAddPlayersFrame'
  addPlayers = TWAAddPlayers:new(
    getglobal(basename),
    getglobal(basename .. 'EditBox'),
    getglobal(basename .. 'Header'),
    getglobal(basename .. 'HelpText'),
    getglobal(basename .. 'Done'),
    getglobal(basename .. 'Cancel'),
    nil
  )
end

local function HandleRosterExpandClick(class)
  CloseDropDownMenus()
  local classSection = ClassSections[class];
  if classSection == nil then return end

  if not classSection.expanded then
    classSection:Expand()
  else
    classSection:Collapse()
  end
end

function TWA_HandleEditBox(editBox)
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

local function parseNames(input)
  ---@type table<integer, string>
  local result = {}
  local start = 1
  while true do
    local newlineStart, newlineEnd = string.find(input, "\n", start)
    local line
    if newlineStart then
      line = string.sub(input, start, newlineStart - 1)
      start = newlineEnd + 1
    else
      line = string.sub(input, start)
    end
    local trimmed = string.gsub(line, "^%s*(.-)%s*$", "%1")
    if trimmed ~= "" then
      table.insert(result, strCapitalize(trimmed))
    end
    if not newlineStart then
      break
    end
  end

  return result
end

function TWA_AddPlayersDoneClick()
  local eb = addPlayers.editBox;
  local inputstr = eb:GetText();
  local class = addPlayers:GetClass()

  local newnames = parseNames(inputstr)
  local invalidNames = {}

  -- If any invalid names, error messaage and return
  for i, name in ipairs(newnames) do
    if string.find(name, "[0-9%s]") or string.len(name) > 12 then
      table.insert(invalidNames, name);
    end
  end
  if table.getn(invalidNames) > 0 then
    local errmsg = "These names are invalid:\n"
    for i, name in pairs(invalidNames) do
      errmsg = errmsg .. name .. '\n'
    end
    twaprint(errmsg)
    return
  end

  -- Insert into roster if they don't already exist
  local classNames = TWA.roster[class];
  ---@type table<integer, string>
  local newNames = {}
  for _, newname in ipairs(newnames) do
    local capitalizedNewName = strCapitalize(newname)
    if not TWA.util.tableContains(classNames, capitalizedNewName) then
      table.insert(classNames, capitalizedNewName);
      table.insert(newNames, capitalizedNewName)
    end
  end

  if table.getn(newNames) > 0 then
    ---@type TWARoster
    local newClassRoster = {
      [class] = newNames
    }
    TWA.BroadcastRoster(newClassRoster, false)
  end

  addPlayers:SetText('')
  addPlayers.frame:Hide()

  local section = ClassSections[addPlayers:GetClass()];
  assert(section ~= nil);

  section:Update()
end

function TWA_AddPlayersCancelClick()
  addPlayers:SetText('')
  addPlayers.frame:Hide();
end

local function HandleRosterAddPlayersClick(class)
  CloseDropDownMenus()
  addPlayers:SetClass(class)
  addPlayers.frame:Show()
  addPlayers.editBox:SetFocus();
end

local function CalcNewContainerHeight()
  local totalHeight = 0;
  for class, data in pairs(ClassSections) do
    totalHeight = totalHeight + data.frame:GetHeight()
  end
  return totalHeight;
end

local function CalcTopOfClassSection(class)
  local indexOfClass = 0;
  for i, curClass in ipairs(TWA.SORTED_CLASS_NAMES) do
    if curClass == class then
      indexOfClass = i;
      break;
    end
  end

  local heightOfPrecedingSections = 0;
  for i = 1, indexOfClass - 1 do
    heightOfPrecedingSections = heightOfPrecedingSections + ClassSections[TWA.SORTED_CLASS_NAMES[i]].frame:GetHeight()
  end
  return -heightOfPrecedingSections;
end

local function ResizeListAfter_aux(class)
  ClassSections[class].frame:SetPoint("TopLeft", RosterFrameContainer, "TopLeft", 0, CalcTopOfClassSection(class));

  if class == TWA.SORTED_CLASS_NAMES[9] then return end
  for i, name in ipairs(TWA.SORTED_CLASS_NAMES) do
    if name == class then
      ResizeListAfter_aux(TWA.SORTED_CLASS_NAMES[i + 1])
    end
  end
end

function ResizeListAfter(class)
  ResizeListAfter_aux(class)
  RosterFrameContainer:SetHeight(CalcNewContainerHeight())
end

local resizeCallbacks = {
  ['druid'] = function() ResizeListAfter('druid') end,
  ['hunter'] = function() ResizeListAfter('hunter') end,
  ['mage'] = function() ResizeListAfter('mage') end,
  ['paladin'] = function() ResizeListAfter('paladin') end,
  ['priest'] = function() ResizeListAfter('priest') end,
  ['rogue'] = function() ResizeListAfter('rogue') end,
  ['shaman'] = function() ResizeListAfter('shaman') end,
  ['warlock'] = function() ResizeListAfter('warlock') end,
  ['warrior'] = function() ResizeListAfter('warrior') end,
}

local rosterFrameBuilt = false;
function TWA_BuildRosterFrame()
  if rosterFrameBuilt then return end
  -- https://www.wowinterface.com/forums/showthread.php?t=38961

  local rosterFrame = getRosterFrame();

  local backdrop = {
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    edgeSize = 16,
    insets = { left = 4, right = 3, top = 4, bottom = 3 }
  }

  RosterFrameBox = CreateFrame("Frame", nil, rosterFrame);
  RosterFrameBox:SetPoint("TopLeft", rosterFrame, "TopLeft", 10, -30)
  RosterFrameBox:SetPoint("BottomRight", rosterFrame, "BottomRight", -10, 10)
  RosterFrameBox:SetBackdrop(backdrop);
  RosterFrameBox:SetBackdropColor(0, 0, 0)
  RosterFrameBox:SetBackdropBorderColor(0.4, 0.4, 0.4)

  RosterFrameScroll = CreateFrame("ScrollFrame", "TWA_RosterManagerScrollFrame", RosterFrameBox,
    "UIPanelScrollFrameTemplate")
  RosterFrameScroll:SetPoint("TopLeft", RosterFrameBox, "TopLeft", 5, -5)
  RosterFrameScroll:SetPoint("BottomRight", RosterFrameBox, "BottomRight", -26, 4)
  RosterFrameScroll:EnableMouse(true)

  RosterFrameContainer = CreateFrame("Frame", "TWA_RosterManagerScrollFrameChild", RosterFrameScroll)
  RosterFrameContainer:SetPoint("Top", RosterFrameScroll, "Top", 0, 0)
  RosterFrameContainer:SetWidth(RosterFrameScroll:GetWidth() * (1 / UIParent:GetScale())) -- fuck you wow xml

  RosterFrameContainer:SetScript("OnSizeChanged", function()
    RosterFrameScroll:SetScrollChild(RosterFrameContainer);
  end)
  RosterFrameScroll:SetScrollChild(RosterFrameContainer);

  local i = 1;
  for _, class in ipairs(TWA.SORTED_CLASS_NAMES) do
    local classSection = TWARoster_BuildClassSection(RosterFrameContainer, class);
    ClassSections[class] = classSection;
    classSection.frame:SetPoint("TopLeft", RosterFrameContainer, "TopLeft", 0, -TWA.ROSTERFRAME_CLASSSECTION_BASE_HEIGHT * i)
    classSection.frame:SetScript("OnSizeChanged", resizeCallbacks[class])
  end

  for class, _ in pairs(ClassSections) do
    resizeCallbacks[class]();
  end

  rosterFrameBuilt = true;
end

function TWARoster_BuildClassSection(container, class)
  local baseName = 'TWA_RosterClassSection' .. class;
  local backdrop = {
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    edgeSize = 16,
    insets = { left = 4, right = 3, top = 4, bottom = 3 }
  }
  local classSectionFrame = CreateFrame("Frame", baseName, container)
  classSectionFrame:SetPoint("TopLeft", container, "TopLeft", 0, 0)
  -- classSectionFrame:SetPoint("TopRight", container, "TopRight", 0, 0)
  classSectionFrame:SetHeight(TWA.ROSTERFRAME_CLASSSECTION_BASE_HEIGHT);
  classSectionFrame:SetWidth(container:GetWidth())
  classSectionFrame:SetBackdrop(backdrop);
  classSectionFrame:SetBackdropColor(1, 1, 1, 0.05)

  local expandButton = CreateFrame("Button", baseName .. "Expand", classSectionFrame, "UIPanelButtonTemplate2")
  expandButton:SetPoint("TopLeft", classSectionFrame, "TopLeft", 4, 0)
  expandButton:SetHeight(30);
  expandButton:SetWidth(25);
  expandButton:SetText('>')
  expandButton:SetScript("OnClick", function() HandleRosterExpandClick(class) end)
  if table.getn(TWA.roster[class]) == 0 then
    expandButton:Disable();
  end

  local className = classSectionFrame:CreateFontString(baseName .. "Header", "OVERLAY", "GameTooltipText")
  className:SetTextColor(
    TWA.classColors[class].r,
    TWA.classColors[class].g,
    TWA.classColors[class].b
  )
  className:SetPoint("TopLeft", classSectionFrame, "TopLeft", 32, -9)
  className:SetText(strCapitalize(class) .. 's')

  local addPlayerButton = CreateFrame("Button", baseName .. "AddPlayer", classSectionFrame, "UIPanelButtonTemplate2")
  addPlayerButton:SetPoint("TopRight", classSectionFrame, "TopRight", -4, 0)
  addPlayerButton:SetWidth(100)
  addPlayerButton:SetHeight(30)
  addPlayerButton:SetText('Add Player(s)')
  addPlayerButton:SetScript("OnClick", function() HandleRosterAddPlayersClick(class) end)

  return TWAClassSection:new(classSectionFrame, expandButton, addPlayerButton, class);
end

function TWARoster_OnClick()
  TWA_BuildRosterFrame()
  local frame = getglobal('TWA_RosterManager');

  if not frame:IsVisible() then
    TWA_ShowRosterFrame()
  else
    TWA_CloseRosterFrame()
  end
end

function CloseTWARoster_OnClick()
  getglobal('TWA_RosterManager'):Hide()
end

function TWA_RosterManager_OnHide()
  addPlayers:SetText('')
  addPlayers.frame:Hide();
end
