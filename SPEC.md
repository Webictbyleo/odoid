# OdoID — Processing Instruction Specification

**Version:** 1.0.2
**Date:** 2026-05-06  
**Status:** Normative

---

## Table of Contents

1. [Overview](#1-overview)  
2. [Character Set Definitions](#2-character-set-definitions)  
3. [Positional Charset Mapping](#3-positional-charset-mapping)  
4. [Capacity Table](#4-capacity-table)  
5. [Encoding Algorithm — Integer to String](#5-encoding-algorithm--integer-to-string)  
6. [Decoding Algorithm — String to Integer](#6-decoding-algorithm--string-to-integer)  
7. [OdoIDGenerator — Optional Component](#7-odoidgenerator--optional-component)  
8. [Compliance Test Vectors](#8-compliance-test-vectors)  
9. [Performance Requirement](#9-performance-requirement)  
10. [Language Implementation Notes](#10-language-implementation-notes)

---

## 1. Overview

OdoID is a **deterministic, mixed-radix encoding scheme** that maps a 64-bit unsigned integer to an alphanumeric string of exactly 6, 7, or 8 characters.

Design goals:

- **Serial-number aesthetic** — the fixed positional structure produces IDs that look like product or license serial numbers.
- **Human readability** — ambiguous characters (`I`, `L`, `O`) are excluded from all character sets to prevent transcription errors.
- **Determinism** — the same integer and length always produce the same string, and vice-versa.
- **Cross-language compatibility** — all character strings and algorithmic constants are fixed; implementations in different languages must produce identical output for identical input.

---

## 2. Character Set Definitions

Three character sets are used. Implementations **must** reproduce these exact strings in the given order to maintain cross-language compatibility.

```
NUM   = "0123456789"                  radix 10
ALPHA = "ABCDEFGHJKMNPQRSTVWXYZ"      radix 22
ALL   = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"   radix 32
```

`ALL` is the concatenation of `NUM` followed by `ALPHA`.

**Excluded characters:** `I`, `L`, and `O` are intentionally absent from every set.

- `I` and `L` are excluded because they are visually indistinguishable from `1` in many fonts.
- `O` is excluded because it is visually indistinguishable from `0`.
- `U` is **retained** to preserve character-set capacity.

---

## 3. Positional Charset Mapping

An OdoID string is indexed from left to right starting at **position 0**.

The charset for a given position index `i` is determined as follows:

| Position index `i` | Charset | Radix |
|--------------------|---------|-------|
| `0` | `ALL` | 32 |
| `1` | `ALPHA` | 22 |
| `2` | `NUM` | 10 |
| `3` through `L-1` | `ALL` | 32 |

`L` is the chosen total length (6, 7, or 8).

This produces an output that always begins with a full-set character, has a letter in the second position, a digit in the third, and full-set characters for all remaining positions — the serial-number aesthetic described above.

**Pseudocode helper:**

```
function getCharset(i):
    if i == 1: return ALPHA
    if i == 2: return NUM
    return ALL
```

---

## 4. Capacity Table

The total number of representable values for each supported length is:

$$\text{Capacity}(L) = 32 \times 22 \times 10 \times 32^{L-3} = 220 \times 32^{L-2}$$

| Length `L` | Max `n` (exclusive) |
|------------|---------------------|
| 6 | 230,686,720 |
| 7 | 7,381,975,040 |
| 8 | 236,223,201,280 |

These values match `MAX[6]`, `MAX[7]`, and `MAX[8]` respectively. The valid integer range for a given length is `0 ≤ n < MAX[L]`.

---

## 5. Encoding Algorithm — Integer to String

### Pre-conditions

1. `L` must be one of `{6, 7, 8}`. Any other value **must** raise an `UnsupportedLengthError`.
2. `n` must satisfy `0 ≤ n < MAX[L]`. If `n < 0` or `n ≥ MAX[L]`, the implementation **must** raise an `OverflowError` with a descriptive message including the violated bound.

### Algorithm

Extraction proceeds **right-to-left** (least-significant position first), populating an output array of length `L`.

```
function encode(n, L):
    assertLength(L)

    if n < 0 or n >= MAX[L]:
        raise OverflowError("n=" + n + " is out of range for length " + L)

    out = array of length L

    for i from L-1 down to 0:
        set  = getCharset(i)
        base = len(set)
        out[i] = set[n mod base]
        n = floor(n / base)

    return join(out)
```

At the end of the loop `n` must equal `0`. If it does not, the implementation has a logic error.

### Worked example — encode(1234567, 6)

| Step (i) | Charset | Base | `n mod base` | Character | `n` after |
|----------|---------|------|--------------|-----------|-----------|
| 5 | ALL | 32 | 7 | `7` | 38580 |
| 4 | ALL | 32 | 20 | `M` | 1205 |
| 3 | ALL | 32 | 21 | `N` | 37 |
| 2 | NUM | 10 | 7 | `7` | 3 |
| 1 | ALPHA | 22 | 3 | `D` | 0 |
| 0 | ALL | 32 | 0 | `0` | 0 |

Result: **`0D7NM7`**

---

## 6. Decoding Algorithm — String to Integer

### Pre-conditions

1. The input must be a non-empty string.
2. `L = len(id)` must be one of `{6, 7, 8}`. Any other value **must** raise an `UnsupportedLengthError`.
3. Before looking up characters, implementations **must** uppercase the string.
4. There is **no** automatic normalization of lookalike characters. `I`, `L`, and `O` are not valid in any position; if they appear after uppercasing, the implementation **must** raise an `InvalidCharacterError` identifying the position.

### Algorithm

Accumulation proceeds **left-to-right** (most-significant position first).

```
function decode(id):
    if not id or not string(id):
        raise TypeError("id must be a non-empty string")

    id = uppercase(id)
    L  = len(id)

    assertLength(L)

    n = 0

    for i from 0 to L-1:
        set   = getCharset(i)
        base  = len(set)
        v     = indexOf(set, id[i])

        if v < 0:
            raise InvalidCharacterError(
                "Invalid character '" + id[i] + "' at position " + (i+1))

        n = n * base + v

    return n
```

### Worked example — decode("0D7NM7")

| Step (i) | Charset | Base | Char | Index `v` | `n` after |
|----------|---------|------|------|-----------|-----------|
| 0 | ALL | 32 | `0` | 0 | 0 |
| 1 | ALPHA | 22 | `D` | 3 | 3 |
| 2 | NUM | 10 | `7` | 7 | 37 |
| 3 | ALL | 32 | `N` | 21 | 1205 |
| 4 | ALL | 32 | `M` | 20 | 38580 |
| 5 | ALL | 32 | `7` | 7 | 1234567 |

Result: **`1234567`**

---

## 7. OdoIDGenerator — Optional Component

`OdoIDGenerator` is a **distributed monotonic generator** that produces OdoID strings driven by a namespace-scoped, time-seeded pseudo-random integer. It is an **optional** component; a compliant core implementation of `encode` / `decode` does not require it.

### 7.1 Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `namespace` | string | `"default"` | Logical partition for this generator instance. Different namespaces produce different output for the same tick. |
| `length` | integer | `6` | OdoID length; must be one of `{6, 7, 8}`. |
| `epoch` | integer (ms) | `0` | Millisecond timestamp used as the time origin. Stored as a BigInt-compatible integer. |

### 7.2 Internal State

| Field | Type | Initial Value | Description |
|-------|------|---------------|-------------|
| `sequence` | uint64 | `0` | Incremental counter for same-tick calls. |
| `lastTick` | uint64 | `0` | Last millisecond timestamp processed. |
| `instanceSalt` | uint32 | `random` | A cryptographically secure random 32-bit integer generated at construction. |

### 7.3 Hash Function

`hash(value)` computes a **FNV-1a 32-bit** hash of a string.

```
function hash(value):
    h = 2166136261    // FNV offset basis (unsigned 32-bit)

    for each character c in value:
        h = h XOR charCode(c)
        h = h * 16777619    // FNV prime
        h = h AND 0xFFFFFFFF  // keep 32 bits unsigned

    return h
```

Constants are normative. Implementations must use exactly `2166136261` as the offset basis and `16777619` as the prime. The final `AND 0xFFFFFFFF` (or unsigned right-shift by 0 in JavaScript) ensures an unsigned 32-bit result.

### 7.4 XOR-Shift PRNG Step

After computing `seed = hash(namespace + "|" + tick)` (converted to BigInt / uint64), apply a 64-bit-safe XOR-shift:

```
seed = seed XOR (seed << 13)
seed = seed XOR (seed >> 7)
seed = seed XOR (seed << 17)
```

The bit-shift parameters `13`, `7`, `17` are normative.  
In languages with fixed-width integers, all intermediate values must be masked to 64 bits.  
In JavaScript, seed is a `BigInt`; arithmetic overflow is not a concern, but bitwise ops on `BigInt` must be used explicitly.

### 7.5 nextN() — Monotonic Integer Generation

```
function nextN():
    tick = currentTimeMs() - epoch

    if tick == lastTick:
        sequence += 1
    else:
        sequence = 0
        lastTick = tick

    seed = BigInt(hash(namespace + "|" + instanceSalt + "|" + tick))

    // XOR-shift
    seed = seed XOR (seed << 13)
    seed = seed XOR (seed >> 7)
    seed = seed XOR (seed << 17)

    n = (seed + sequence) mod capacity
    return n
```

Because `n` is always in `[0, capacity)`, passing it to `encode(n, length)` will never trigger `OverflowError`.

### 7.6 next() — Public Entry Point

```
function next():
    n  = nextN()
    id = encode(n, length)
    return { id, n, length, namespace }
```

---

## 8. Compliance Test Vectors

All compliant implementations **must** produce the following outputs. The test vectors were derived by tracing the reference TypeScript implementation.

### 8.1 Encode

| Input `n` | Length `L` | Expected output |
|-----------|-----------|-----------------|
| `0` | 6 | `0A0000` |
| `1234567` | 6 | `0D7NM7` |
| `1234567` | 7 | `0A15NM7` |
| `236223201279` | 8 | `ZZ9ZZZZZ` |
| `230686719` | 6 | `ZZ9ZZZ` *(maximum valid value for L=6)* |

### 8.2 Decode (round-trip)

For each pair above, `decode(encode(n, L)) == n` must hold.

| Input string | Expected integer |
|--------------|-----------------|
| `0A0000` | `0` |
| `0D7NM7` | `1234567` |
| `0A15NM7` | `1234567` |
| `ZZ9ZZZZZ` | `236223201279` |
| `ZZ9ZZZ` | `230686719` |

### 8.3 Error Cases

| Scenario | Expected error |
|----------|----------------|
| `encode(230686720, 6)` — equals `MAX[6]` | `OverflowError` |
| `encode(-1, 6)` | `OverflowError` |
| `encode(0, 5)` | `UnsupportedLengthError` |
| `decode("0A000O")` — contains `O` | `InvalidCharacterError` at position 6 |
| `decode("0A000I")` — contains `I` | `InvalidCharacterError` at position 6 |
| `decode("0A000l")` — contains lowercase `l` (L) | `InvalidCharacterError` at position 6 |
| `decode("")` — empty string | `TypeError` |

> **Note on uppercase normalization in decode:** Decode uppercases its input before lookup. Therefore `decode("0a0000")` is valid and returns `0`. Only the three excluded characters `I`, `L`, `O` are permanently invalid after uppercasing; all other lowercase inputs are valid.

---

## 9. Performance Requirement

Each call to `encode()` and `decode()` must complete in **≤ 0.1000 ms** as measured by wall-clock time on the target hardware.

Implementations should verify this with a benchmark that encodes and decodes a representative load of values (minimum 10,000 calls after a warm-up of at least 2,000 calls to allow JIT optimisation) and asserts that the **average time per call** does not exceed the limit. Measuring worst-case individual calls is not a valid method because JIT cold-start and timer resolution produce misleading outliers.

---

## 10. Language Implementation Notes

### JavaScript / TypeScript

- `n` parameters should accept both `number` and `bigint`. Convert to `BigInt` at the start of `encode`.
- All arithmetic inside `encode` and `decode` must use `BigInt` to avoid precision loss on values above `2^53 - 1`.
- The `hash()` function operates on regular 32-bit integers (use `Math.imul` and `>>> 0` for unsigned coercion). Convert to `BigInt` before the XOR-shift step.

### Python

- Python's native `int` is arbitrary precision. No special handling is needed for 64-bit overflow.
- Use `//` for integer division.
- The `hash()` function must mask to 32 bits: `h = (h * 16777619) & 0xFFFFFFFF`.

### C# / Java

- Use `ulong` (C#) or `long` with unsigned semantics (Java `Long.compareUnsigned`, `Long.divideUnsigned`) or `uint64` for `n`.
- Reject negative inputs explicitly before the range check.
- `String.IndexOf` returns `-1` for missing characters — treat this as `InvalidCharacterError`.

### Go

- Use `uint64` for `n` and all intermediate values.
- Bitwise operations on `uint64` are inherently unsigned; no masking is needed.
- The XOR-shift step on a 32-bit seed stored in `uint64` is equivalent to the BigInt version.

---

## Appendix A — Character Index Reference

### ALL (radix 32)

| Index | Char | Index | Char | Index | Char | Index | Char |
|-------|------|-------|------|-------|------|-------|------|
| 0 | `0` | 8 | `8` | 16 | `G` | 24 | `Q` |
| 1 | `1` | 9 | `9` | 17 | `H` | 25 | `R` |
| 2 | `2` | 10 | `A` | 18 | `J` | 26 | `S` |
| 3 | `3` | 11 | `B` | 19 | `K` | 27 | `T` |
| 4 | `4` | 12 | `C` | 20 | `M` | 28 | `V` |
| 5 | `5` | 13 | `D` | 21 | `N` | 29 | `W` |
| 6 | `6` | 14 | `E` | 22 | `P` | 30 | `X` |
| 7 | `7` | 15 | `F` | 23 | `Q` | 31 | `Z` |

> Full string: `0123456789ABCDEFGHJKMNPQRSTVWXYZ`

### ALPHA (radix 22)

| Index | Char | Index | Char | Index | Char | Index | Char |
|-------|------|-------|------|-------|------|-------|------|
| 0 | `A` | 6 | `G` | 12 | `P` | 18 | `W` |
| 1 | `B` | 7 | `H` | 13 | `Q` | 19 | `X` |
| 2 | `C` | 8 | `J` | 14 | `R` | 20 | `Y` |
| 3 | `D` | 9 | `K` | 15 | `S` | 21 | `Z` |
| 4 | `E` | 10 | `M` | 16 | `T` | | |
| 5 | `F` | 11 | `N` | 17 | `V` | | |

> Full string: `ABCDEFGHJKMNPQRSTVWXYZ`

### NUM (radix 10)

| Index | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|-------|---|---|---|---|---|---|---|---|---|---|
| Char | `0` | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9` |

---

*End of specification.*
