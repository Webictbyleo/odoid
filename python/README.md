# odoid

Deterministic mixed-radix ID encoding. Maps a non-negative integer to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```
encode(0,            6)  →  "0A0000"
encode(1234567,      6)  →  "0D7NM7"
encode(1234567,      7)  →  "0A15NM7"
encode(236223201279, 8)  →  "ZZ9ZZZZZ"
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **Pure Python** — no dependencies, works on Python 3.8+.

## Install

```sh
pip install odoid
```

## Usage

### Encode

```python
from odoid import encode

encode(0, 6)            # "0A0000"
encode(1234567, 6)      # "0D7NM7"
encode(1234567, 7)      # "0A15NM7"
encode(236223201279, 8) # "ZZ9ZZZZZ"
```

`encode(n, length=6)` — default length is `6`.

### Decode

```python
from odoid import decode

decode("0A0000")    # 0
decode("0D7NM7")    # 1234567
decode("0A15NM7")   # 1234567
```

Returns `int`. Input is uppercased before lookup, so `decode("0d7nm7")` is valid.

### OdoIDGenerator

```python
from odoid import OdoIDGenerator

g = OdoIDGenerator(namespace="orders", length=7)
result = g.next()
# result.id        → e.g. "3H5NV2K"
# result.n         → the raw integer
# result.length    → 7
# result.namespace → "orders"
```

## Lengths and Capacity

| Length | Max integer (exclusive) |
|--------|------------------------|
| 6      | 230,686,720            |
| 7      | 7,381,975,040          |
| 8      | 236,223,201,280        |

## Errors

| Error | When |
|-------|------|
| `OverflowError` | `n < 0` or `n >= MAX[length]` |
| `UnsupportedLengthError` | length is not 6, 7, or 8 |
| `InvalidCharacterError` | character not in positional charset during decode |

All three are subclasses of `ValueError`.

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
