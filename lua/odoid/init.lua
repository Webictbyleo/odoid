--- odoid — public API.
---
--- Usage:
---   local odoid = require("odoid")
---   local id = odoid.encode(1234567, 6)   -- "0D7NM7"
---   local n  = odoid.decode("0D7NM7")     -- 1234567
---   local g  = odoid.generator.new({ namespace = "orders", length = 7 })
---   local r  = g:next()

local charsets  = require("odoid.charsets")
local encode_m  = require("odoid.encode")
local decode_m  = require("odoid.decode")
local generator = require("odoid.generator")

local M = {}

M.NUM       = charsets.NUM
M.ALPHA     = charsets.ALPHA
M.ALL       = charsets.ALL
M.MAX       = charsets.MAX

--- Encodes n into an OdoID string of the given length (default 6).
--- Returns id, nil on success or nil, err on failure.
M.encode    = encode_m.encode

--- Decodes an OdoID string to its originating integer.
--- Returns n, nil on success or nil, err on failure.
M.decode    = decode_m.decode

--- Generator constructor. See odoid.generator for full docs.
M.generator = generator

return M
