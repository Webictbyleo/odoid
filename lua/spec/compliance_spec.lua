-- Compliance test vectors as defined in SPEC.md § 8.
-- Every compliant implementation MUST pass these tests unchanged.

local odoid = require("odoid")

describe("Compliance", function()

  -- § 8.1 Encode
  describe("§ 8.1 encode", function()
    it("encode(0, 6) == '0A0000'",            function() assert.equal("0A0000",   odoid.encode(0, 6)) end)
    it("encode(1234567, 6) == '0D7NM7'",      function() assert.equal("0D7NM7",   odoid.encode(1234567, 6)) end)
    it("encode(1234567, 7) == '0A15NM7'",     function() assert.equal("0A15NM7",  odoid.encode(1234567, 7)) end)
    it("encode(236223201279, 8) == 'ZZ9ZZZZZ'", function() assert.equal("ZZ9ZZZZZ", odoid.encode(236223201279, 8)) end)
    it("encode(230686719, 6) == 'ZZ9ZZZ'",    function() assert.equal("ZZ9ZZZ",   odoid.encode(230686719, 6)) end)
  end)

  -- § 8.2 Decode round-trips
  describe("§ 8.2 decode round-trips", function()
    it("decode('0A0000') == 0",            function() assert.equal(0,            odoid.decode("0A0000")) end)
    it("decode('0D7NM7') == 1234567",      function() assert.equal(1234567,      odoid.decode("0D7NM7")) end)
    it("decode('0A15NM7') == 1234567",     function() assert.equal(1234567,      odoid.decode("0A15NM7")) end)
    it("decode('ZZ9ZZZZZ') == 236223201279", function() assert.equal(236223201279, odoid.decode("ZZ9ZZZZZ")) end)
    it("decode('ZZ9ZZZ') == 230686719",    function() assert.equal(230686719,    odoid.decode("ZZ9ZZZ")) end)
  end)

  -- § 8.3 Error cases
  describe("§ 8.3 error cases", function()
    it("encode(MAX[6], 6) returns OverflowError", function()
      local id, err = odoid.encode(odoid.MAX[6], 6)
      assert.is_nil(id)
      assert.equal("OverflowError", err.type)
    end)

    it("encode(0, 5) returns UnsupportedLengthError", function()
      local id, err = odoid.encode(0, 5)
      assert.is_nil(id)
      assert.equal("UnsupportedLengthError", err.type)
    end)

    it("decode('0A000O') returns InvalidCharacterError at position 6", function()
      local n, err = odoid.decode("0A000O")
      assert.is_nil(n)
      assert.equal("InvalidCharacterError", err.type)
      assert.equal(6, err.position)
      assert.equal("O", err.ch)
    end)

    it("decode('0A000I') returns InvalidCharacterError at position 6", function()
      local n, err = odoid.decode("0A000I")
      assert.is_nil(n)
      assert.equal("InvalidCharacterError", err.type)
      assert.equal(6, err.position)
    end)

    it("decode('0A000l') returns InvalidCharacterError (l -> L excluded)", function()
      local n, err = odoid.decode("0A000l")
      assert.is_nil(n)
      assert.equal("InvalidCharacterError", err.type)
    end)

    it("decode('') returns EmptyInputError", function()
      local n, err = odoid.decode("")
      assert.is_nil(n)
      assert.is_not_nil(err)
    end)
  end)

end)
