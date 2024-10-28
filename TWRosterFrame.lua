local getRosterFrame = function() return getglobal('TWA_RosterManager') end

local RosterClassSection_BaseHeight = 30;
local RosterClassEntry_Height = 15;
local RosterClassEntry_ExtraWidth = 40;
local RosterClassSection_ExpandMargin = 6;
local RosterContainerInexplicableOffset = 57

---@type Frame
local RosterFrameBox = nil;
---@type Frame
local RosterFrameScroll = nil;
---@type Frame
local RosterFrameContainer = nil;

---@param frame Frame
---@param expandButton Button
---@param addPlayerButton Button
local function newClassSection(frame, expandButton, addPlayerButton)
  ---@type ClassSection
  local classSection = {
    frame = frame,
    expandButton = expandButton,
    addPlayerButton = addPlayerButton,
    expanded = false,
    frames = {}
  }
  return classSection
end

---@type table<string, ClassSection|nil>
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
local sortedClassNames = {'druid','hunter','mage','paladin','priest','rogue','shaman','warlock','warrior'}

function TWA_CloseRosterFrame()
  getRosterFrame():Hide()
end

function TWA_ShowRosterFrame()
  getRosterFrame():Show()
end

function BuildNameFrame(name, class)
  local frameName = "TWA_RosterEntry" .. name;
  local parent = ClassSections[class].frame;
  local frame = CreateFrame("Frame", "TWA_RosterEntry" .. name, parent)
  frame:Hide()
  frame:SetPoint('Right', parent, 'Right', 0, 0)
  frame:SetHeight(RosterClassEntry_Height)
  frame:SetWidth(parent:GetWidth() - 7)

  local text = frame:CreateFontString(frameName .. 'text', "OVERLAY", "GameFontNormalSmall")
  text:SetPoint('Left', frame, "Left", 0, 0)
  text:SetTextColor(
    TWA.classColors[class].r,
    TWA.classColors[class].g,
    TWA.classColors[class].b
  );
  text:SetText(name)

  return frame;
end

function TWAHandleRosterExpandClick(class)
  local classSection = ClassSections[class];
  if classSection == nil then twadebug('WTF?!?!') return end
  local names = TWA.roster[class]

  if not classSection.expanded then
    for i, name in pairs(names) do
      ---@type Frame
      local frame = classSection.frames[name]

      -- Build missing frame
      if frame == nil then
        frame = BuildNameFrame(name, class)
        classSection.frames[name] = frame;
      end

      frame:SetPoint("TopRight", classSection.frame, "TopRight", 0,
        -RosterClassSection_BaseHeight - (i - 1) * RosterClassEntry_Height)
      frame:Show();
    end

    classSection.frame:SetHeight(
      RosterClassSection_BaseHeight +
      table.getn(names) * RosterClassEntry_Height +
      RosterClassSection_ExpandMargin)

    classSection.expanded = true;
    classSection.expandButton:SetText("v");
  else
    for _, frame in pairs(classSection.frames) do
      frame:Hide()
    end
    classSection.frame:SetHeight(RosterClassSection_BaseHeight);
    classSection.expandButton:SetText(">");
    classSection.expanded = false;
  end
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
  for i, curClass in ipairs(sortedClassNames) do
    if curClass == class then
      indexOfClass = i;
      break;
    end
  end

  local heightOfPrecedingSections = 0;
  for i=1, indexOfClass-1 do
    heightOfPrecedingSections = heightOfPrecedingSections + ClassSections[sortedClassNames[i]].frame:GetHeight()
  end
  return -heightOfPrecedingSections;
end

local function ResizeListAfter_aux(class)
  ClassSections[class].frame:SetPoint("Top", RosterFrameContainer, "Top", RosterContainerInexplicableOffset/2, CalcTopOfClassSection(class));
  if class == sortedClassNames[9] then return end
  for i, name in ipairs(sortedClassNames) do
    if name == class then
      ResizeListAfter_aux(sortedClassNames[i+1])
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
  RosterFrameBox:SetPoint("BottomRight", rosterFrame, "BottomRight", -10, 30)
  RosterFrameBox:SetBackdrop(backdrop);
  RosterFrameBox:SetBackdropColor(0, 0, 0)
  RosterFrameBox:SetBackdropBorderColor(0.4, 0.4, 0.4)

  RosterFrameScroll = CreateFrame("ScrollFrame", "TWA_RosterManagerScrollFrame", RosterFrameBox,
    "UIPanelScrollFrameTemplate")
  RosterFrameScroll:SetPoint("TopLeft", RosterFrameBox, "TopLeft", 5, -5)
  RosterFrameScroll:SetPoint("BottomRight", RosterFrameBox, "BottomRight", -26, 4)
  RosterFrameScroll:EnableMouse(true)

  RosterFrameContainer = CreateFrame("Frame", "TWA_RosterManagerScrollFrameChild", RosterFrameScroll)
  RosterFrameContainer:SetWidth(RosterFrameScroll:GetWidth())
  RosterFrameContainer:SetScript("OnSizeChanged", function() 
    RosterFrameScroll:SetScrollChild(RosterFrameContainer);
  end)
  RosterFrameScroll:SetScrollChild(RosterFrameContainer);

  RosterFrameContainer:SetPoint("Top", RosterFrameBox, "Top", RosterContainerInexplicableOffset/2, 0)

  local i = 1;
  for _, class in ipairs(sortedClassNames) do
    local classSection = TWARoster_BuildClassSection(RosterFrameContainer, class);
    ClassSections[class] = classSection;
    classSection.frame:SetPoint("Top", RosterFrameContainer, "Top", 0, -RosterClassSection_BaseHeight * i)
    classSection.frame:SetScript("OnSizeChanged", resizeCallbacks[class])
  end

  for class, _ in pairs(ClassSections) do
    resizeCallbacks[class]();
  end

  rosterFrameBuilt = true;
end

function TWARoster_BuildClassSection(container, class)
  local baseName = 'TWA_RosterClassSection';
  local backdrop = {
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    edgeSize = 16,
    insets = { left = 4, right = 3, top = 4, bottom = 3 }
  }
  local classSectionFrame = CreateFrame("Frame", baseName .. class, container)
  classSectionFrame:SetPoint("Top", container, "Top", 0, 0)
  classSectionFrame:SetHeight(RosterClassSection_BaseHeight);
  classSectionFrame:SetWidth(container:GetWidth() + RosterContainerInexplicableOffset)
  classSectionFrame:SetBackdrop(backdrop);
  classSectionFrame:SetBackdropColor(1, 1, 1, 0.05)

  local expandButton = CreateFrame("Button", baseName.."expand"..class, classSectionFrame, "UIPanelButtonTemplate2")
  expandButton:SetPoint("TopLeft", classSectionFrame, "TopLeft", 4, 0)
  expandButton:SetHeight(30);
  expandButton:SetWidth(25);
  expandButton:SetText('>')
  expandButton:SetScript("OnClick", function() TWAHandleRosterExpandClick(class) end)
  if table.getn(TWA.roster[class]) == 0 then
    expandButton:Disable();
  end

  local className = classSectionFrame:CreateFontString(baseName .. "Header" .. class, "OVERLAY", "GameTooltipText")
  className:SetTextColor(
    TWA.classColors[class].r,
    TWA.classColors[class].g,
    TWA.classColors[class].b
  )
  className:SetPoint("TopLeft", classSectionFrame, "TopLeft", 32, -9)
  local classNameCapitalizedAndPlural = string.upper(string.sub(class, 1, 1)) .. string.sub(class, 2) .. 's'
  className:SetText(classNameCapitalizedAndPlural)

  return newClassSection(classSectionFrame, expandButton, nil); -- todo add player button
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
