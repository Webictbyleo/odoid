# OdoID

Deterministic mixed-radix ID encoding. Maps a `ulong` to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```
OdoId.Encode(0,            6)  →  "0A0000"
OdoId.Encode(1234567,      6)  →  "0D7NM7"
OdoId.Encode(1234567,      7)  →  "0A15NM7"
OdoId.Encode(236223201279, 8)  →  "ZZ9ZZZZZ"
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **Zero dependencies** — pure .NET standard library only.
- **Multi-target** — `net8.0`, `net6.0`, `netstandard2.1`.

## Install

```sh
dotnet add package OdoID
```

## Usage

### Encode

```csharp
using OdoID;

OdoId.Encode(0, 6);            // "0A0000"
OdoId.Encode(1234567, 6);      // "0D7NM7"
OdoId.Encode(1234567, 7);      // "0A15NM7"
OdoId.Encode(236223201279, 8); // "ZZ9ZZZZZ"
```

Default length is `6`:

```csharp
OdoId.Encode(0); // "0A0000"
```

### Decode

```csharp
OdoId.Decode("0A0000");    // 0UL
OdoId.Decode("0D7NM7");    // 1234567UL
```

Returns `ulong`. Input is uppercased before lookup, so `"0d7nm7"` is valid.

### OdoIDGenerator

```csharp
var g = new OdoIDGenerator(new GeneratorConfig
{
    Namespace = "orders",
    Length    = 7
});

var result = g.Next();
// result.Id        → e.g. "3H5NV2K"
// result.N         → the raw ulong
// result.Length    → 7
// result.Namespace → "orders"
```

## Lengths and Capacity

| Length | Max integer (exclusive) |
|--------|------------------------|
| 6      | 230,686,720            |
| 7      | 7,381,975,040          |
| 8      | 236,223,201,280        |

## Exceptions

| Exception | When |
|-----------|------|
| `OdoOverflowException` | `n >= Max[length]` |
| `UnsupportedLengthException` | length is not 6, 7, or 8 |
| `InvalidCharacterException` | character not in positional charset during decode |

All are subclasses of `ArgumentOutOfRangeException` or `ArgumentException`.

## Run tests

```sh
dotnet test
```

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
