# odoid

Deterministic mixed-radix ID encoding. Maps a `uint64` to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```
Encode(0,            6)  →  "0A0000"
Encode(1234567,      6)  →  "0D7NM7"
Encode(1234567,      7)  →  "0A15NM7"
Encode(236223201279, 8)  →  "ZZ9ZZZZZ"
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **Zero dependencies** — pure Go standard library only.

## Install

```sh
go get github.com/Webictbyleo/odoid/go/odoid
```

## Usage

### Encode

```go
import "github.com/Webictbyleo/odoid/go/odoid"

id, err := odoid.Encode(0, 6)            // "0A0000"
id, err := odoid.Encode(1234567, 6)      // "0D7NM7"
id, err := odoid.Encode(1234567, 7)      // "0A15NM7"
id, err := odoid.Encode(236223201279, 8) // "ZZ9ZZZZZ"
```

### Decode

```go
n, err := odoid.Decode("0D7NM7")  // 1234567
```

Returns `uint64`. Input is uppercased before lookup, so `"0d7nm7"` is valid.

### OdoIDGenerator

```go
g, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{
    Namespace: "orders",
    Length:    7,
})
result, err := g.Next()
// result.ID        → e.g. "3H5NV2K"
// result.N         → the raw uint64
// result.Length    → 7
// result.Namespace → "orders"
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
| `*OverflowError` | `n >= Max[length]` |
| `*UnsupportedLengthError` | length is not 6, 7, or 8 |
| `*InvalidCharacterError` | character not in positional charset during decode |

## Run tests

```sh
go test ./odoid/
```

## Benchmarks

```sh
go test -bench=. -benchtime=5s ./odoid/
```

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
