# odoid

Deterministic mixed-radix ID encoding. Maps a 64-bit unsigned integer to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```
0A0000   →  0
0D7NM7   →  1234567
ZZ9ZZZZZ →  236223201279
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **64-bit safe** — all arithmetic uses `BigInt` internally.
- **Tiny** — zero runtime dependencies.

## Install

```sh
npm install odoid
```

## Usage

### Encode

```ts
import { encode } from "odoid";

encode(0n, 6);          // "0A0000"
encode(1234567n, 6);    // "0D7NM7"
encode(1234567n, 7);    // "0A15NM7"
encode(236223201279n, 8); // "ZZ9ZZZZZ"
```

`encode(n, length?)` accepts both `number` and `bigint`. Default length is `6`.

### Decode

```ts
import { decode } from "odoid";

decode("0A0000");   // 0n
decode("0D7NM7");   // 1234567n
decode("0A15NM7");  // 1234567n
```

Returns `bigint`. Input is uppercased before lookup, so lowercase letters that are valid in the charset are accepted.

### OdoIDGenerator

A time-seeded, namespace-scoped monotonic generator:

```ts
import { OdoIDGenerator } from "odoid";

const g = new OdoIDGenerator({ namespace: "orders", length: 7 });

const { id, n } = g.next();
// id  → e.g. "3H5NV2K"
// n   → the raw bigint
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

All three extend `RangeError`.

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
