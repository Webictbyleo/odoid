# OdoID

A deterministic, mixed-radix ID encoding scheme that maps a 64-bit unsigned integer to a 6, 7, or 8-character alphanumeric string.

```
encode(0,           6)  →  "0A0000"
encode(1234567,     6)  →  "0D7NM7"
encode(1234567,     7)  →  "0A15NM7"
encode(236223201279, 8) →  "ZZ9ZZZZZ"
```

## Design

- **Serial-number aesthetic** — the fixed positional structure makes every ID look like a product or license serial number.
- **Human-readable** — the characters `I`, `L`, and `O` are excluded from all positions to prevent transcription errors with `1` and `0`.
- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **64-bit safe** — supports integers up to 236 billion (length 8).

## Lengths and Capacity

| Length | Max integer (exclusive) | Example |
|--------|------------------------|---------|
| 6 | 230,686,720 | `0D7NM7` |
| 7 | 7,381,975,040 | `0A15NM7` |
| 8 | 236,223,201,280 | `ZZ9ZZZZZ` |

## Implementations

| Language | Directory | Package |
|----------|-----------|---------|
| TypeScript / JavaScript | [`ts/`](ts/) | [![npm](https://img.shields.io/npm/v/odoid)](https://www.npmjs.com/package/odoid) |
| Python | `python/` | *(coming soon)* |
| Go | `go/` | *(coming soon)* |
| C# | `csharp/` | *(coming soon)* |

## Specification

The full processing instruction document is in [SPEC.md](SPEC.md). All implementations are derived from and tested against this spec.

## Quick Start

### TypeScript / JavaScript

```sh
npm install odoid
```

```ts
import { encode, decode, OdoIDGenerator } from "odoid";

encode(1234567n, 6);   // "0D7NM7"
decode("0D7NM7");      // 1234567n

const g = new OdoIDGenerator({ namespace: "orders", length: 7 });
g.next(); // { id: "...", n: ..., length: 7, namespace: "orders" }
```

**CDN (no build step):**

```html
<script src="https://cdn.jsdelivr.net/npm/odoid/dist/index.iife.min.js"></script>
<script>
  const { encode, decode } = OdoID;
  console.log(encode(1234567n, 6)); // "0D7NM7"
</script>
```

## License

MIT
