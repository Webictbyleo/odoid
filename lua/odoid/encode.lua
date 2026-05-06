--- OdoID encoding — integer to string.

local charsets = require("odoid.charsets")
local errors   = require("odoid.errors")

local M = {}

--- Validates that length is 6, 7, or 8.
--- Returns nil on success, or an error table on failure.
function M.assert_length(length)
  if length == 6 or length == 7 or length == 8 then
    return nil
  end
  return errors.unsupported_length(length)
end

--- Encodes non-negative integer n into an OdoID string of the given length.
---
--- @param n      number   Non-negative integer. Must satisfy 0 <= n < MAX[length].
--- @param length number   Target string length: 6 (default), 7, or 8.
--- @return string|nil, table|nil  id on success, or nil + error table on failure.
function M.encode(n, length)
  length = length or 6
  local err = M.assert_length(length)
  if err then return nil, err end

  if n >= charsets.MAX[length] then
    return nil, errors.overflow(n, length, charsets.MAX[length])
  end

  local buf = {}
  for i = length, 1, -1 do
    local charset = charsets.get_charset(i - 1)  -- 0-based
    local base    = #charset
    local idx     = (n % base) + 1               -- Lua 1-based
    buf[i] = charset:sub(idx, idx)
    n = math.floor(n / base)
  end

  return table.concat(buf), nil
end

return M
