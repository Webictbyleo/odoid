local odoid = require("odoid")

describe("OdoIDGenerator", function()

  it("default config has correct defaults", function()
    local g = odoid.generator.new()
    assert.equal("default", g.namespace)
    assert.equal(6, g.length)
  end)

  it("custom namespace and length", function()
    local g = odoid.generator.new({ namespace = "acme", length = 8 })
    assert.equal("acme", g.namespace)
    assert.equal(8, g.length)
  end)

  it("capacity matches MAX[length]", function()
    for _, length in ipairs({6, 7, 8}) do
      local g = odoid.generator.new({ length = length })
      assert.equal(odoid.MAX[length], g.capacity)
    end
  end)

  it("unsupported length returns error", function()
    local g, err = odoid.generator.new({ length = 5 })
    assert.is_nil(g)
    assert.equal("UnsupportedLengthError", err.type)
  end)

  it("next() result has correct shape", function()
    local g = odoid.generator.new({ namespace = "test", length = 6 })
    local r, err = g:next()
    assert.is_nil(err)
    assert.is_string(r.id)
    assert.equal(6, r.length)
    assert.equal("test", r.namespace)
  end)

  it("id has correct length", function()
    for _, length in ipairs({6, 7, 8}) do
      local g = odoid.generator.new({ length = length })
      local r = g:next()
      assert.equal(length, #r.id)
    end
  end)

  it("excluded chars I, L, O never appear in output", function()
    local g = odoid.generator.new({ length = 8 })
    for _ = 1, 50 do
      local r = g:next()
      assert.is_falsy(r.id:find("I", 1, true))
      assert.is_falsy(r.id:find("L", 1, true))
      assert.is_falsy(r.id:find("O", 1, true))
    end
  end)

  it("n is always in [0, MAX[length])", function()
    for _, length in ipairs({6, 7, 8}) do
      local g = odoid.generator.new({ length = length })
      for _ = 1, 50 do
        local r = g:next()
        assert.is_true(r.n >= 0 and r.n < odoid.MAX[length])
      end
    end
  end)

  it("n matches decode(id)", function()
    local g = odoid.generator.new({ namespace = "verify", length = 6 })
    for _ = 1, 20 do
      local r = g:next()
      local decoded = odoid.decode(r.id)
      assert.equal(r.n, decoded)
    end
  end)

  it("monotonic sequencing: same tick produces distinct ids", function()
    -- Use a future epoch so tick stays at 0 for all calls
    local future_epoch = os.time() * 1000 + 60000
    local g = odoid.generator.new({ namespace = "seq-test", epoch = future_epoch })
    local seen = {}
    for _ = 1, 20 do
      local r = g:next()
      assert.is_falsy(seen[r.id], "duplicate ID: " .. r.id)
      seen[r.id] = true
    end
  end)

  it("namespace isolation: different namespaces produce different ids", function()
    local future_epoch = os.time() * 1000 + 60000
    local g1 = odoid.generator.new({ namespace = "ns-a", length = 8, epoch = future_epoch })
    local g2 = odoid.generator.new({ namespace = "ns-b", length = 8, epoch = future_epoch })
    assert.not_equal(g1:next().id, g2:next().id)
  end)

  it("proxy encode uses generator length", function()
    local g = odoid.generator.new({ length = 7 })
    local id = g:encode(0)
    assert.equal(7, #id)
  end)

  it("proxy decode returns correct n", function()
    local g = odoid.generator.new({ length = 6 })
    local r = g:next()
    assert.equal(r.n, g:decode(r.id))
  end)

end)
