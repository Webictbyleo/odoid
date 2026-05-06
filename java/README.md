# odoid

Deterministic mixed-radix ID encoding. Maps a `long` to a 6, 7, or 8-character alphanumeric string with a serial-number aesthetic.

```java
OdoId.encode(0,            6)  // "0A0000"
OdoId.encode(1234567,      6)  // "0D7NM7"
OdoId.encode(1234567,      7)  // "0A15NM7"
OdoId.encode(236223201279L, 8) // "ZZ9ZZZZZ"
```

## Features

- **Deterministic** — same integer + length always produces the same string, and vice-versa.
- **Human-readable** — ambiguous characters `I`, `L`, `O` are excluded from all positions.
- **Fixed positional structure** — position 1 is always a letter, position 2 is always a digit.
- **Zero dependencies** — pure Java standard library, Java 17+.

## Install

### Maven

```xml
<dependency>
  <groupId>io.github.webictbyleo</groupId>
  <artifactId>odoid</artifactId>
  <version>1.0.0</version>
</dependency>
```

### Gradle

```groovy
implementation 'io.github.webictbyleo:odoid:1.0.0'
```

## Usage

### Encode

```java
import io.github.webictbyleo.odoid.OdoId;

OdoId.encode(0, 6);            // "0A0000"
OdoId.encode(1234567, 6);      // "0D7NM7"
OdoId.encode(1234567, 7);      // "0A15NM7"
OdoId.encode(236223201279L, 8); // "ZZ9ZZZZZ"
```

### Decode

```java
OdoId.decode("0D7NM7");   // 1234567L
OdoId.decode("0d7nm7");   // 1234567L  (lowercase accepted)
```

### OdoIDGenerator

```java
import io.github.webictbyleo.odoid.*;

var g = new OdoIDGenerator(GeneratorConfig.builder()
    .namespace("orders")
    .length(7)
    .build());

OdoIDResult r = g.next();
// r.getId()        → e.g. "3H5NV2K"
// r.getN()         → the raw long
// r.getLength()    → 7
// r.getNamespace() → "orders"
```

## Lengths and Capacity

| Length | Max integer (exclusive) |
|--------|------------------------|
| 6      | 230,686,720            |
| 7      | 7,381,975,040          |
| 8      | 236,223,201,280        |

## Exceptions

All extend `IllegalArgumentException`:

| Exception | When |
|-----------|------|
| `OdoOverflowException` | `n >= MAX[length]` |
| `UnsupportedLengthException` | length is not 6, 7, or 8 |
| `InvalidCharacterException` | character not in positional charset during decode |

## Run tests

```sh
mvn test
```

## Specification

See [`SPEC.md`](https://github.com/Webictbyleo/odoid/blob/main/SPEC.md) for the full processing instruction document.

## License

MIT
