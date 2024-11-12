if TWA.util == nil then TWA.util = {} end

---Find the position of a value in a simple list.
---The table should be a sequential list of comparable values (e.g., numbers or strings).
---@param tbl table<integer, any> -- Sequential list to search.
---@param value any -- Value to search for in the list.
---@return integer|nil -- Index of the value if found, otherwise nil.
function TWA.util.tablePosOf(tbl, value)
    for i, val in ipairs(tbl) do
        if val == value then return i end
    end
    return nil
end

-- https://gist.github.com/jrus/3197011
TWA.util.random = math.random

---Check if a value exists in a simple list.
---The table should be a sequential list of comparable values (e.g., numbers or strings).
---@param tbl table<integer, any> -- Sequential list to search.
---@param value any -- Value to search for in the list.
---@return boolean -- Returns true if the value is found in the table, otherwise false.
function TWA.util.tableContains(tbl, value)
    for _, val in ipairs(tbl) do
        if val == value then return true end
    end
    return false
end

---Hashes a string to a 32-bit number using djb2_hash
---@param str string The string to hash.
---@return number hash The 32-bit hash of the string.
function TWA.util.djb2_hash(str)
    local hash = 5381 -- Starting constant
    for i = 1, string.len(str) do
        local byte = string.byte(str, i)
        hash = TWA.util.mod(((hash * 33) + byte), 2147483647) -- Keep it within signed 32 bits
    end

    return hash
end

---Converts a 32-bit hash number to an 8-character hex string
---@param hash number The 32-bit hash to convert.
---@return string hex Hexadecimal representation of the hash.
function TWA.util.hashToHex(hash)
    return string.format("%08x", hash)
end

--- Converts an 8-character hexadecimal string back to a 32-bit hash number.
---@param hex string The hexadecimal representation of the hash.
---@return number hash The 32-bit hash number.
function TWA.util.hexToHash(hex)
    return tonumber(hex, 16)
end

--- Returns the mathematical modulus of `a` and `b`, handling negative values of `a`.
--- @param a number The dividend.
--- @param b number The divisor.
--- @return number The remainder in the range [0, b).
function TWA.util.mod(a, b)
    return a - math.floor(a / b) * b
end

--- Returns a new table containing a range of elements from the given table.
--- @param tbl table The original table.
--- @param startIdx integer The starting index of the range (inclusive).
--- @param endIdx integer|nil The ending index of the range (inclusive). If nil, defaults to the last element in the table.
--- @return table A new table containing elements from `startIdx` to `endIdx`.
function TWA.util.tableSlice(tbl, startIdx, endIdx)
    local result = {}
    endIdx = endIdx or table.getn(tbl)
    for i = startIdx, endIdx do
        table.insert(result, tbl[i])
    end
    return result
end