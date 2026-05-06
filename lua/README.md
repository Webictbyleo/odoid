# odoid

Deterministic mixed-radix ID encoding. Maps a non-negative integer to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```lua
local odoid = require("odoid")
odoid.encode(0,            6)  -- "0A0000"
odoid.encode(1234567,      6)  -- "0D7NM7"
odoid.encode(1234567,      7)  -- "0A15NM7"
odoid.encode(236223201279, 8)  -- "ZZ9ZZZZZ"
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **Zero dependencies** — pure Lua standard library only (Lua 5.1+).

## Install

```sh
luarocks install odoid
```

## Usage

### Encode

```lua
local odoid = require("odoid")

local id, err = odoid.encode(0, 6)            -- "0A0000"
local id, err = odoid.encode(1234567, 6)      -- "0D7NM7"
local id, err = odoid.encode(1234567, 7)      -- "0A15NM7"
local id, err = odoid.encode(236223201279, 8) -- "ZZ9ZZZZZ"
```

Default length is `6`:

```lua
local id = odoid.encode(0)  -- "0A0000"
```

### Decode

```lua
local n, err = odoid.decode("0D7NM7")  -- 1234567
local n, err = odoid.decode("0d7nm7")  -- 1234567 (lowercase accepted)
```

### OdoIDGenerator

```lua
local g = odoid.generator.new({
  namespace = "orders",
  length    = 7,
})
local result = g:next()
-- result.id        → e.g. "3H5NV2K"
-- result.n         → the raw integer
-- result.length    → 7
-- result.namespace → "orders"
```

## Lengths and Capacity

| Length | Max integer (exclusive) |
|--------|------------------------|
| 6      | 230,686,720            |
| 7      | 7,381,975,040          |
| 8      | 236,223,201,280        |

## Errors

All functions return `value, nil` on success or `nil, err` on failure.  
The `err` table has a `type` field and a `message` field:

| `err.type` | When |
|------------|------|
| `"OverflowError"` | `n >= MAX[length]` |
| `"UnsupportedLengthError"` | length is not 6, 7, or 8 |
| `"InvalidCharacterError"` | character not in positional charset during decode |
| `"EmptyInputError"` | empty string passed to decode |

## Run tests

```sh
busted spec/
```

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
