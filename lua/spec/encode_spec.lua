local odoid = require("odoid")

describe("Encode", function()

  it("default length is 6", function()
    local id = odoid.encode(0)
    assert.equal("0A0000", id)
    assert.equal(6, #id)
  end)

  it("output length matches requested", function()
    for _, length in ipairs({6, 7, 8}) do
      assert.equal(length, #odoid.encode(0, length))
    end
  end)

  it("output is always uppercase", function()
    for _, n in ipairs({0, 1, 100, 999999, 1234567}) do
      local id = odoid.encode(n, 6)
      assert.equal(id, id:upper())
    end
  end)

  it("position 1 (2nd char) is always in ALPHA", function()
    for _, n in ipairs({0, 1, 100, 1234567}) do
      local id = odoid.encode(n, 6)
      local ch = id:sub(2, 2)
      assert.is_truthy(odoid.ALPHA:find(ch, 1, true),
        string.format("pos 1 = '%s' not in ALPHA", ch))
    end
  end)

  it("position 2 (3rd char) is always a digit", function()
    for _, n in ipairs({0, 1, 100, 1234567}) do
      local id = odoid.encode(n, 6)
      local ch = id:sub(3, 3)
      assert.is_truthy(ch:match("%d"), string.format("pos 2 = '%s' not a digit", ch))
    end
  end)

  it("excluded chars I, L, O never appear", function()
    for _, n in ipairs({0, 1, 1000, 1234567, 100000000}) do
      local id = odoid.encode(n, 8)
      assert.is_falsy(id:find("I", 1, true), id .. " contains I")
      assert.is_falsy(id:find("L", 1, true), id .. " contains L")
      assert.is_falsy(id:find("O", 1, true), id .. " contains O")
    end
  end)

  it("encode(0, length) is valid for all supported lengths", function()
    for _, length in ipairs({6, 7, 8}) do
      local id, err = odoid.encode(0, length)
      assert.is_nil(err)
      assert.is_string(id)
    end
  end)

  it("encode(MAX[length]-1, length) is valid", function()
    for _, length in ipairs({6, 7, 8}) do
      local id, err = odoid.encode(odoid.MAX[length] - 1, length)
      assert.is_nil(err)
      assert.is_string(id)
    end
  end)

  it("encode(MAX[length], length) returns OverflowError", function()
    for _, length in ipairs({6, 7, 8}) do
      local id, err = odoid.encode(odoid.MAX[length], length)
      assert.is_nil(id)
      assert.equal("OverflowError", err.type)
    end
  end)

  it("overflow error message contains the violating value", function()
    local _, err = odoid.encode(odoid.MAX[6], 6)
    assert.is_truthy(err.message:find(tostring(odoid.MAX[6]), 1, true))
  end)

  it("unsupported lengths return UnsupportedLengthError", function()
    for _, length in ipairs({0, 1, 5, 9, 100}) do
      local id, err = odoid.encode(0, length)
      assert.is_nil(id)
      assert.equal("UnsupportedLengthError", err.type)
    end
  end)

end)
