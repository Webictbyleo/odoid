--- OdoID decoding — string to integer.

local charsets = require("odoid.charsets")
local errors   = require("odoid.errors")
local enc      = require("odoid.encode")

local M = {}

--- Decodes an OdoID string back to its originating integer.
---
--- The input is uppercased before lookup, so lowercase letters that are valid
--- in the charset (e.g. "0a0000") are accepted. The excluded characters
--- I, L, and O remain invalid even after uppercasing.
---
--- @param  id string   OdoID string (6, 7, or 8 characters).
--- @return number|nil, table|nil  n on success, or nil + error table on failure.
function M.decode(id)
  if not id or id == "" then
    return nil, { type = "EmptyInputError", message = "OdoID must be a non-empty string" }
  end

  local upper  = id:upper()
  local length = #upper

  local err = enc.assert_length(length)
  if err then return nil, err end

  local n = 0
  for i = 1, length do
    local charset = charsets.get_charset(i - 1)  -- 0-based
    local base    = #charset
    local ch      = upper:sub(i, i)
    local v       = charset:find(ch, 1, true)     -- plain find, 1-based
    if not v then
      return nil, errors.invalid_character(ch, i)
    end
    n = n * base + (v - 1)
  end

  return n, nil
end

return M
