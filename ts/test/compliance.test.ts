import { describe, test, expect } from "vitest";
import { encode, decode, OverflowError, UnsupportedLengthError, InvalidCharacterError, MAX } from "../src/index.js";

/**
 * Compliance test vectors as defined in SPEC.md § 8.
 * Every compliant implementation MUST pass these tests unchanged.
 */
describe("Spec Compliance", () => {
  // ── § 8.1 Encode ──────────────────────────────────────────────────────────

  describe("§ 8.1 encode", () => {
    test("encode(0n, 6) === '0A0000'", () => {
      expect(encode(0n, 6)).toBe("0A0000");
    });

    test("encode(1234567n, 6) === '0D7NM7'", () => {
      expect(encode(1234567n, 6)).toBe("0D7NM7");
    });

    test("encode(1234567n, 7) === '0A15NM7'", () => {
      expect(encode(1234567n, 7)).toBe("0A15NM7");
    });

    test("encode(236223201279n, 8) === 'ZZ9ZZZZZ'", () => {
      expect(encode(236223201279n, 8)).toBe("ZZ9ZZZZZ");
    });

    test("encode(230686719n, 6) === 'ZZ9ZZZ' (max valid for L=6)", () => {
      expect(encode(230686719n, 6)).toBe("ZZ9ZZZ");
    });
  });

  // ── § 8.2 Decode round-trips ───────────────────────────────────────────────

  describe("§ 8.2 decode round-trips", () => {
    const vectors: [string, bigint][] = [
      ["0A0000", 0n],
      ["0D7NM7", 1234567n],
      ["0A15NM7", 1234567n],
      ["ZZ9ZZZZZ", 236223201279n],
      ["ZZ9ZZZ", 230686719n],
    ];

    for (const [id, expected] of vectors) {
      test(`decode("${id}") === ${expected}n`, () => {
        expect(decode(id)).toBe(expected);
      });
    }
  });

  // ── § 8.3 Error cases ─────────────────────────────────────────────────────

  describe("§ 8.3 error cases", () => {
    test("encode(MAX[6], 6) throws OverflowError", () => {
      expect(() => encode(MAX[6], 6)).toThrowError(OverflowError);
    });

    test("encode(-1, 6) throws OverflowError", () => {
      expect(() => encode(-1, 6)).toThrowError(OverflowError);
    });

    test("encode(0, 5) throws UnsupportedLengthError", () => {
      // @ts-expect-error intentionally passing unsupported length
      expect(() => encode(0, 5)).toThrowError(UnsupportedLengthError);
    });

    test("decode('0A000O') — contains 'O' — throws InvalidCharacterError at position 6", () => {
      const err = (() => {
        try { decode("0A000O"); }
        catch (e) { return e; }
      })();
      expect(err).toBeInstanceOf(InvalidCharacterError);
      expect((err as InvalidCharacterError).position).toBe(6);
      expect((err as InvalidCharacterError).char).toBe("O");
    });

    test("decode('0A000I') — contains 'I' — throws InvalidCharacterError at position 6", () => {
      const err = (() => {
        try { decode("0A000I"); }
        catch (e) { return e; }
      })();
      expect(err).toBeInstanceOf(InvalidCharacterError);
      expect((err as InvalidCharacterError).position).toBe(6);
    });

    test("decode('0A000l') — lowercase 'l' uppercases to 'L' which is invalid — throws InvalidCharacterError", () => {
      expect(() => decode("0A000l")).toThrowError(InvalidCharacterError);
    });

    test("decode('') — empty string — throws TypeError", () => {
      expect(() => decode("")).toThrowError(TypeError);
    });
  });
});
