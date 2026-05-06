# odoid

Deterministic mixed-radix ID encoding. Maps a non-negative integer to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```dart
import 'package:odoid/odoid.dart';

OdoId.encode(0,            6);  // "0A0000"
OdoId.encode(1234567,      6);  // "0D7NM7"
OdoId.encode(1234567,      7);  // "0A15NM7"
OdoId.encode(236223201279, 8);  // "ZZ9ZZZZZ"

OdoId.decode('0D7NM7');         // 1234567
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **Zero dependencies** — pure Dart SDK, no external packages at runtime.

## Install

```yaml
dependencies:
  odoid: ^1.0.0
```

## Usage

### Encode

```dart
import 'package:odoid/odoid.dart';

OdoId.encode(0, 6);            // "0A0000"
OdoId.encode(1234567, 6);      // "0D7NM7"
OdoId.encode(1234567, 7);      // "0A15NM7"
OdoId.encode(236223201279, 8); // "ZZ9ZZZZZ"

// Default length is 6
OdoId.encode(0); // "0A0000"
```

### Decode

```dart
OdoId.decode('0D7NM7');   // 1234567
OdoId.decode('0d7nm7');   // 1234567 (lowercase accepted)
```

### OdoIDGenerator

```dart
final g = OdoIDGenerator(namespace: 'orders', length: 7);
final r = g.next();
// r.id        → e.g. "3H5NV2K"
// r.n         → the raw integer
// r.length    → 7
// r.namespace → "orders"
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
| `OdoOverflowException` | `n >= kMax[length]` |
| `UnsupportedLengthException` | length is not 6, 7, or 8 |
| `InvalidCharacterException` | character not in positional charset during decode |

```dart
try {
  OdoId.decode('0A000O');
} on InvalidCharacterException catch (e) {
  print(e.char);     // "O"
  print(e.position); // 6
}
```

## Run tests

```sh
dart pub get
dart test
```

## Monorepo

This package is part of the [Webictbyleo/odoid](https://github.com/Webictbyleo/odoid) monorepo, which contains implementations in TypeScript, Python, Go, C#, Rust, Lua, Java, and PHP.

## Specification

See [SPEC.md](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
