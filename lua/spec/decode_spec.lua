local odoid = require("odoid")

describe("Decode", function()

  it("round-trips for various n and lengths", function()
    local cases = {
      {0, 6}, {1, 6}, {255, 6}, {65535, 6}, {1234567, 6},
      {0, 7}, {1234567, 7},
      {0, 8}, {1234567, 8},
    }
    for _, c in ipairs(cases) do
      local n, length = c[1], c[2]
      local id = odoid.encode(n, length)
      local got, err = odoid.decode(id)
      assert.is_nil(err, string.format("decode error for (%d, %d): %s", n, length, err and err.message or ""))
      assert.equal(n, got, string.format("round-trip failed for (%d, %d)", n, length))
    end
  end)

  it("accepts lowercase input", function()
    local n, err = odoid.decode("0a0000")
    assert.is_nil(err)
    assert.equal(0, n)
  end)

  it("lowercase matches uppercase result", function()
    local lower = odoid.decode("0d7nm7")
    local upper = odoid.decode("0D7NM7")
    assert.equal(upper, lower)
  end)

  it("excluded chars I, L, O are rejected", function()
    for _, ch in ipairs({"I", "L", "O"}) do
      local id = "0A0" .. ch .. "00"
      local n, err = odoid.decode(id)
      assert.is_nil(n)
      assert.equal("InvalidCharacterError", err.type)
    end
  end)

  it("error reports correct position", function()
    local _, err = odoid.decode("0A000O")
    assert.equal(6, err.position)
    assert.equal("O", err.ch)
  end)

  it("special character '-' is rejected", function()
    local n, err = odoid.decode("0A00-0")
    assert.is_nil(n)
    assert.equal("InvalidCharacterError", err.type)
  end)

  it("unsupported lengths return UnsupportedLengthError", function()
    for _, id in ipairs({"0A000", "0A000000000"}) do
      local n, err = odoid.decode(id)
      assert.is_nil(n)
      assert.equal("UnsupportedLengthError", err.type)
    end
  end)

  it("empty string returns error", function()
    local n, err = odoid.decode("")
    assert.is_nil(n)
    assert.is_not_nil(err)
  end)

end)
