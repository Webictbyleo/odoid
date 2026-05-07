## 1.0.5

- Automated release bump to 1.0.5.

## 1.0.4

- Expanded DartDoc documentation for core classes, exceptions, and charsets.
- Architectural context added to the mixed-radix encoding logic.
- Synchronized with the monorepo modular release pipeline.

## 1.0.1

- Fix: Changed default generator behavior from relative to absolute time to prevent deterministic generation in short-lived instances.
- Re-synced specification and all implementations to 1.0.1.

## 1.0.0

- Initial release.
- `OdoId.encode(n, length)` — maps integer to 6, 7, or 8-character OdoID string.
- `OdoId.decode(id)` — maps OdoID string back to integer, accepts lowercase input.
- `OdoIDGenerator` — distributed monotonic generator with namespace isolation and FNV-1a / XOR-shift seeding.
- 100 tests covering compliance vectors, encode/decode, generator behaviour, and performance (≤ 0.1 ms per call).
