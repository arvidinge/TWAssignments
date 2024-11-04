---Find the position of a value in a simple list.
---The table should be a sequential list of comparable values (e.g., numbers or strings).
---@param tbl table<integer, any> -- Sequential list to search.
---@param value any -- Value to search for in the list.
---@return integer|nil -- Index of the value if found, otherwise nil.
TWA.tablePosOf = function(tbl, value)
  for i, val in ipairs(tbl) do
    if val == value then return i end
  end
  return nil
end

---Check if a value exists in a simple list.
---The table should be a sequential list of comparable values (e.g., numbers or strings).
---@param tbl table<integer, any> -- Sequential list to search.
---@param value any -- Value to search for in the list.
---@return boolean -- Returns true if the value is found in the table, otherwise false.
TWA.tableContains = function(tbl, value)
  for _, val in ipairs(tbl) do
    if val == value then return true end
  end
  return false
end
