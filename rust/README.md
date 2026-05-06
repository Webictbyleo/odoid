# odoid

Deterministic mixed-radix ID encoding. Maps a `u64` to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

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
- **Zero dependencies** — pure Rust standard library only.

## Install

```toml
[dependencies]
odoid = "1.0.0"
```

## Usage

### Encode

```rust
use odoid::encode;

encode(0,            6).unwrap(); // "0A0000"
encode(1234567,      6).unwrap(); // "0D7NM7"
encode(1234567,      7).unwrap(); // "0A15NM7"
encode(236223201279, 8).unwrap(); // "ZZ9ZZZZZ"
```

### Decode

```rust
use odoid::decode;

decode("0A0000").unwrap(); // 0u64
decode("0D7NM7").unwrap(); // 1234567u64
decode("0a0000").unwrap(); // 0u64  (lowercase accepted)
```

### OdoIDGenerator

```rust
use odoid::{OdoIDGenerator, GeneratorConfig};

let mut g = OdoIDGenerator::new(GeneratorConfig {
    namespace: "orders".into(),
    length: 7,
    ..Default::default()
}).unwrap();

let result = g.next().unwrap();
// result.id        → e.g. "3H5NV2K"
// result.n         → the raw u64
// result.length    → 7
// result.namespace → "orders"
```

## Lengths and Capacity

| Length | Max integer (exclusive) |
|--------|------------------------|
| 6      | 230,686,720            |
| 7      | 7,381,975,040          |
| 8      | 236,223,201,280        |

## Errors

All functions return `Result<_, OdoError>`. Variants:

| Variant | When |
|---------|------|
| `OdoError::Overflow` | `n >= MAX[length]` |
| `OdoError::UnsupportedLength` | length is not 6, 7, or 8 |
| `OdoError::InvalidCharacter` | character not in positional charset during decode |
| `OdoError::EmptyInput` | empty string passed to decode |

## Run tests

```sh
cargo test
```

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
