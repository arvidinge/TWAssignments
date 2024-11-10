---@type table<integer, TWATimeoutCallback>
local callbacks = {}

---@return Frame
local function getTimeoutFrame()
    local frameName = "TWA_TimeOutFrame"
    return getglobal(frameName) or CreateFrame("Frame", frameName)
end

-- https://gist.github.com/jrus/3197011
local function uuid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end

local frameCounter = 0
local function checkCallbacks()
    frameCounter = frameCounter + 1
    if TWA.util.mod(frameCounter, TWA.CHECK_TIMEOUTS_EACH_N_FRAMES) ~= 0 then return end

    local curTime = GetTime()
    local invokedCallbacks = {}

    for i, tc in ipairs(callbacks) do
        if tc.startTime + tc.delay <= curTime then
            tc.callback()
            table.insert(invokedCallbacks, i)
        end
    end

    local i = table.getn(invokedCallbacks)
    while i > 0 do
        table.remove(callbacks, invokedCallbacks[i]);
        i = i - 1
    end

    if table.getn(callbacks) == 0 then
        getTimeoutFrame():SetScript("OnUpdate", nil);
    end
end

---Set a callback function to be called after a timeout.
---@param callback function The function to call after the delay
---@param delay number Number of seconds to delay, accepts decimals
---@return string id The id of the timeout
function TWA.setTimeout(callback, delay)
    local waitFrame = getTimeoutFrame()
    local timeoutId = uuid()

    ---@type TWATWATimeoutCallback
    local tc = {
        id = timeoutId,
        callback = callback,
        delay = delay,
        startTime = GetTime()
    }
    table.insert(callbacks, tc)

    waitFrame:SetScript("OnUpdate", checkCallbacks)
    return timeoutId;
end

---Cancel an already queued timeout
---@param id string The id of the timeout
function TWA.clearTimeout(id)
    if id == nil then return end
    ---@type integer|nil
    local timeoutToDelete = nil

    for i, tc in ipairs(callbacks) do
        if timeoutToDelete ~= nil then break end
        if tc.id == id then
            timeoutToDelete = i
        end
    end

    if timeoutToDelete == nil then return end

    table.remove(callbacks, timeoutToDelete);

    if table.getn(callbacks) == 0 then
        getTimeoutFrame():SetScript("OnUpdate", nil);
    end
end
