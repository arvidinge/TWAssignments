---@type table<integer, TWATimeoutCallback>
local callbacks = {}

---@return Frame
local function getTimeoutFrame()
    local frameName = "TWA_TimeOutFrame"
    return getglobal(frameName) or CreateFrame("Frame", frameName)
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
function TWA.timeout.set(callback, delay)
    local waitFrame = getTimeoutFrame()
    local timeoutId = TWA.sync.newId()

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
function TWA.timeout.clear(id)
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
