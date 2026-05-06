## 1.0.0

- Initial release.
- `OdoId.encode(n, length)` — maps integer to 6, 7, or 8-character OdoID string.
- `OdoId.decode(id)` — maps OdoID string back to integer, accepts lowercase input.
- `OdoIDGenerator` — distributed monotonic generator with namespace isolation and FNV-1a / XOR-shift seeding.
- 100 tests covering compliance vectors, encode/decode, generator behaviour, and performance (≤ 0.1 ms per call).
