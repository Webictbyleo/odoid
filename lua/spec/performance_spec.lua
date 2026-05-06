-- Performance tests — SPEC.md § 9.
-- Each encode / decode call must average <= 0.1000 ms.

local odoid = require("odoid")

local LIMIT_MS  = 0.1
local WARMUP    = 2000
local ITERS     = 10000

local function avg_ms(fn)
  for _ = 1, WARMUP do fn() end
  local t0 = os.clock()
  for _ = 1, ITERS do fn() end
  return (os.clock() - t0) * 1000 / ITERS
end

describe("Performance", function()

  it("encode length 6 averages <= 0.1 ms", function()
    local n = 0
    local ms = avg_ms(function()
      n = (n + 1) % odoid.MAX[6]
      odoid.encode(n, 6)
    end)
    assert.is_true(ms <= LIMIT_MS,
      string.format("encode/6: %.4f ms exceeded %.4f ms", ms, LIMIT_MS))
  end)

  it("encode length 7 averages <= 0.1 ms", function()
    local n = 0
    local ms = avg_ms(function()
      n = (n + 1) % odoid.MAX[7]
      odoid.encode(n, 7)
    end)
    assert.is_true(ms <= LIMIT_MS,
      string.format("encode/7: %.4f ms exceeded %.4f ms", ms, LIMIT_MS))
  end)

  it("encode length 8 averages <= 0.1 ms", function()
    local n = 0
    local ms = avg_ms(function()
      n = (n + 1) % odoid.MAX[8]
      odoid.encode(n, 8)
    end)
    assert.is_true(ms <= LIMIT_MS,
      string.format("encode/8: %.4f ms exceeded %.4f ms", ms, LIMIT_MS))
  end)

  it("decode length 6 averages <= 0.1 ms", function()
    local ids = {"0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"}
    local i = 0
    local ms = avg_ms(function()
      i = i + 1
      odoid.decode(ids[(i % #ids) + 1])
    end)
    assert.is_true(ms <= LIMIT_MS,
      string.format("decode/6: %.4f ms exceeded %.4f ms", ms, LIMIT_MS))
  end)

  it("decode length 7 averages <= 0.1 ms", function()
    local ids = {"0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000"}
    local i = 0
    local ms = avg_ms(function()
      i = i + 1
      odoid.decode(ids[(i % #ids) + 1])
    end)
    assert.is_true(ms <= LIMIT_MS,
      string.format("decode/7: %.4f ms exceeded %.4f ms", ms, LIMIT_MS))
  end)

  it("decode length 8 averages <= 0.1 ms", function()
    local ids = {"0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"}
    local i = 0
    local ms = avg_ms(function()
      i = i + 1
      odoid.decode(ids[(i % #ids) + 1])
    end)
    assert.is_true(ms <= LIMIT_MS,
      string.format("decode/8: %.4f ms exceeded %.4f ms", ms, LIMIT_MS))
  end)

end)
