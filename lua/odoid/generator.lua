--- OdoIDGenerator — distributed monotonic generator.

local charsets = require("odoid.charsets")
local encode_m = require("odoid.encode")
local decode_m = require("odoid.decode")

local M = {}

--- FNV-1a 32-bit hash.
--- Constants are normative: offset basis = 2166136261, prime = 16777619.
local function fnv1a32(value)
  local h = 2166136261
  for i = 1, #value do
    h = h ~ value:byte(i)               -- XOR  (Lua 5.3+ bitwise)
    h = (h * 16777619) & 0xFFFFFFFF     -- multiply, keep 32 bits
  end
  return h
end

--- Returns current Unix time in milliseconds.
local function now_ms()
  -- os.clock() is CPU time; os.time() is wall-clock seconds.
  -- Lua has no built-in ms clock, so we use os.time() * 1000 as a
  -- stable tick. Each call within the same second shares a tick, and
  -- the sequence counter guarantees uniqueness within that tick.
  return math.floor(os.time() * 1000)
end

--- Creates a new OdoIDGenerator.
---
--- @param cfg table  Optional config:
---   cfg.namespace string   Logical partition (default "default").
---   cfg.length    number   OdoID length: 6 (default), 7, or 8.
---   cfg.epoch     number   Millisecond epoch origin (default now).
--- @return table|nil, table|nil  generator on success, or nil + error table.
function M.new(cfg)
  cfg = cfg or {}
  local namespace = cfg.namespace or "default"
  local length    = cfg.length or 6
  local epoch     = cfg.epoch or now_ms()

  local err = encode_m.assert_length(length)
  if err then return nil, err end

  local g = {
    namespace = namespace,
    length    = length,
    capacity  = charsets.MAX[length],
    _epoch    = epoch,
    _sequence = 0,
    _last_tick = -1,
  }

  --- Returns the next raw integer n in [0, capacity).
  function g:next_n()
    local tick = math.floor(now_ms() - self._epoch)
    if tick == self._last_tick then
      self._sequence = self._sequence + 1
    else
      self._sequence = 0
      self._last_tick = tick
    end

    local key  = self.namespace .. "|" .. tostring(tick)
    local seed = fnv1a32(key)
    seed = seed ~ (seed << 13) & 0xFFFFFFFF
    seed = seed ~ (seed >> 7)
    seed = seed ~ (seed << 17) & 0xFFFFFFFF

    return (seed + self._sequence) % self.capacity
  end

  --- Generates and returns the next OdoID result.
  --- @return table|nil, table|nil  {id, n, length, namespace} or nil + error.
  function g:next()
    local n        = self:next_n()
    local id, err2 = encode_m.encode(n, self.length)
    if err2 then return nil, err2 end
    return { id = id, n = n, length = self.length, namespace = self.namespace }, nil
  end

  --- Encodes n using this generator's configured length.
  function g:encode(n)
    return encode_m.encode(n, self.length)
  end

  --- Decodes an OdoID string to its originating integer.
  function g:decode(id)
    return decode_m.decode(id)
  end

  return g, nil
end

return M
