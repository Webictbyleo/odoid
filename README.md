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
| Python | [`python/`](python/) | [![PyPI](https://img.shields.io/pypi/v/odoid)](https://pypi.org/project/odoid/) |
| Go | [`go/`](go/) | `go get github.com/Webictbyleo/odoid/go/odoid` |
| C# | [`csharp/`](csharp/) | [![NuGet](https://img.shields.io/nuget/v/OdoID)](https://www.nuget.org/packages/OdoID) |
| Rust | [`rust/`](rust/) | [![crates.io](https://img.shields.io/crates/v/odoid)](https://crates.io/crates/odoid) |
| Lua | [`lua/`](lua/) | [![LuaRocks](https://img.shields.io/luarocks/v/webictbyleo/odoid)](https://luarocks.org/modules/webictbyleo/odoid) |
| Java | [`java/`](java/) | [![Maven Central](https://img.shields.io/maven-central/v/io.github.webictbyleo/odoid)](https://central.sonatype.com/artifact/io.github.webictbyleo/odoid) |
| PHP | [`php/`](php/) | [![Packagist](https://img.shields.io/packagist/v/webictbyleo/odoid)](https://packagist.org/packages/webictbyleo/odoid) |
| Dart | [`dart/`](dart/) | [![pub.dev](https://img.shields.io/pub/v/odoid)](https://pub.dev/packages/odoid) |
| **CLI** | [`cli/`](cli/) | [![GitHub release](https://img.shields.io/github/v/release/Webictbyleo/odoid?filter=cli*)](https://github.com/Webictbyleo/odoid/releases/tag/cli%2Fv1.0.1) |

## Specification

The full processing instruction document is in [SPEC.md](SPEC.md). All implementations are derived from and tested against this spec.

## Quick Start

### CLI (no runtime required)

Download the binary for your platform from the [latest CLI release](https://github.com/Webictbyleo/odoid/releases/tag/cli%2Fv1.0.1):

| Platform | Binary |
|----------|--------|
| Linux x64 | [`odoid-linux-amd64`](https://github.com/Webictbyleo/odoid/releases/download/cli%2Fv1.0.1/odoid-linux-amd64) |
| Linux ARM64 | [`odoid-linux-arm64`](https://github.com/Webictbyleo/odoid/releases/download/cli%2Fv1.0.1/odoid-linux-arm64) |
| Windows x64 | [`odoid-windows-amd64.exe`](https://github.com/Webictbyleo/odoid/releases/download/cli%2Fv1.0.1/odoid-windows-amd64.exe) |
| Windows ARM64 | [`odoid-windows-arm64.exe`](https://github.com/Webictbyleo/odoid/releases/download/cli%2Fv1.0.1/odoid-windows-arm64.exe) |
| macOS x64 | [`odoid-darwin-amd64`](https://github.com/Webictbyleo/odoid/releases/download/cli%2Fv1.0.1/odoid-darwin-amd64) |
| macOS Apple Silicon | [`odoid-darwin-arm64`](https://github.com/Webictbyleo/odoid/releases/download/cli%2Fv1.0.1/odoid-darwin-arm64) |

```sh
# Linux / macOS
chmod +x odoid-linux-amd64
./odoid-linux-amd64 encode 1234567           # 0D7NM7
./odoid-linux-amd64 encode 1234567 --length 7  # 0A15NM7
./odoid-linux-amd64 decode 0D7NM7           # 1234567
./odoid-linux-amd64 generate --namespace orders --length 7 --count 5
```

```bat
REM Windows
odoid-windows-amd64.exe encode 1234567
odoid-windows-amd64.exe decode 0D7NM7
odoid-windows-amd64.exe generate --count 5 --ids-only
```

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

### Python

```sh
pip install odoid
```

```python
from odoid import encode, decode, OdoIDGenerator

encode(1234567, 6)   # "0D7NM7"
decode("0D7NM7")     # 1234567

g = OdoIDGenerator(namespace="orders", length=7)
g.next()  # OdoIDResult(id="...", n=..., length=7, namespace="orders")
```

### Go

```sh
go get github.com/Webictbyleo/odoid/go/odoid
```

```go
import "github.com/Webictbyleo/odoid/go/odoid"

odoid.Encode(1234567, 6)  // "0D7NM7", nil
odoid.Decode("0D7NM7")    // 1234567, nil

g, _ := odoid.NewGenerator(odoid.Config{Namespace: "orders", Length: 7})
g.Next() // &OdoIDResult{ID: "...", N: ..., Length: 7, Namespace: "orders"}
```

### C# / .NET

```sh
dotnet add package OdoID
```

```csharp
using OdoID;

OdoId.Encode(1234567, 6);  // "0D7NM7"
OdoId.Decode("0D7NM7");    // 1234567

var g = new OdoIDGenerator(new GeneratorConfig { Namespace = "orders", Length = 7 });
g.Next(); // OdoIDResult { Id = "...", N = ..., Length = 7, Namespace = "orders" }
```

### Rust

```toml
[dependencies]
odoid = "1.0.3"
```

```rust
use odoid::{encode, decode, OdoIDGenerator, GeneratorConfig};

encode(1234567, 6)?;  // "0D7NM7"
decode("0D7NM7")?;    // 1234567u64

let mut g = OdoIDGenerator::new(GeneratorConfig { namespace: "orders".into(), length: 7, ..Default::default() })?;
g.next()?; // OdoIDResult { id: "...", n: ..., length: 7, namespace: "orders" }
```

### Lua

```sh
luarocks install odoid
```

```lua
local odoid = require("odoid")

odoid.encode(1234567, 6)  -- "0D7NM7"
odoid.decode("0D7NM7")    -- 1234567

local g = odoid.generator.new({ namespace = "orders", length = 7 })
g:next()  -- { id = "...", n = ..., length = 7, namespace = "orders" }
```

### Java

```xml
<dependency>
  <groupId>io.github.webictbyleo</groupId>
  <artifactId>odoid</artifactId>
  <version>1.0.1</version>
</dependency>
```

```java
import io.github.webictbyleo.odoid.*;

OdoId.encode(1234567, 6);  // "0D7NM7"
OdoId.decode("0D7NM7");    // 1234567L

var g = new OdoIDGenerator(GeneratorConfig.builder().namespace("orders").length(7).build());
g.next(); // OdoIDResult { id = "...", n = ..., length = 7, namespace = "orders" }
```

### PHP

```sh
composer require webictbyleo/odoid
```

```php
use Webictbyleo\OdoID\OdoId;
use Webictbyleo\OdoID\OdoIDGenerator;

OdoId::encode(1234567, 6);  // "0D7NM7"
OdoId::decode("0D7NM7");    // 1234567

$g = new OdoIDGenerator(namespace: 'orders', length: 7);
$g->next(); // ['id' => '...', 'n' => ..., 'length' => 7, 'namespace' => 'orders']
```

### Dart

```yaml
dependencies:
  odoid: ^1.0.1
```

```dart
import 'package:odoid/odoid.dart';

OdoId.encode(1234567, 6);  // "0D7NM7"
OdoId.decode('0D7NM7');    // 1234567

final g = OdoIDGenerator(namespace: 'orders', length: 7);
g.next(); // OdoIDResult(id: '...', n: ..., length: 7, namespace: 'orders')
```

## License

MIT
