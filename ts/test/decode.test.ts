import { describe, test, expect } from "vitest";
import { decode, encode, InvalidCharacterError, UnsupportedLengthError, MAX } from "../src/index.js";

describe("decode()", () => {
  describe("round-trip correctness", () => {
    const lengths = [6, 7, 8] as const;
    const samples = [0n, 1n, 255n, 65535n, 1234567n, 9999999n];

    for (const length of lengths) {
      for (const n of samples) {
        if (n < MAX[length]) {
          test(`decode(encode(${n}n, ${length})) === ${n}n`, () => {
            expect(decode(encode(n, length))).toBe(n);
          });
        }
      }
    }
  });

  describe("case insensitivity", () => {
    test("decode('0a0000') === 0n (lowercase accepted via uppercasing)", () => {
      expect(decode("0a0000")).toBe(0n);
    });

    test("decode('0d7nm7') === decode('0D7NM7')", () => {
      expect(decode("0d7nm7")).toBe(decode("0D7NM7"));
    });
  });

  describe("returns bigint", () => {
    test("result is always bigint", () => {
      expect(typeof decode("0A0000")).toBe("bigint");
    });
  });

  describe("invalid characters", () => {
    const excluded = ["I", "L", "O"];
    for (const ch of excluded) {
      test(`decode with '${ch}' in position 4 throws InvalidCharacterError`, () => {
        // Position 4 (index 3) is an ALL-set slot; I/L/O not in ALL
        const id = `0A0${ch}00`;
        expect(() => decode(id)).toThrowError(InvalidCharacterError);
      });
    }

    test("error reports the correct 1-based position", () => {
      // 'O' at index 5 → position 6
      try {
        decode("0A000O");
      } catch (e) {
        expect(e).toBeInstanceOf(InvalidCharacterError);
        expect((e as InvalidCharacterError).position).toBe(6);
      }
    });

    test("error reports the offending character", () => {
      try {
        decode("0A000O");
      } catch (e) {
        expect((e as InvalidCharacterError).char).toBe("O");
      }
    });

    test("InvalidCharacterError is instance of RangeError", () => {
      try {
        decode("0A000O");
      } catch (e) {
        expect(e).toBeInstanceOf(RangeError);
      }
    });

    test("special characters throw InvalidCharacterError", () => {
      expect(() => decode("0A00-0")).toThrowError(InvalidCharacterError);
    });

    test("space character throws InvalidCharacterError", () => {
      expect(() => decode("0A00 0")).toThrowError(InvalidCharacterError);
    });
  });

  describe("unsupported length", () => {
    const badIds = ["0A000", "0A00000000"];
    for (const id of badIds) {
      test(`decode("${id}") — length ${id.length} — throws UnsupportedLengthError`, () => {
        expect(() => decode(id)).toThrowError(UnsupportedLengthError);
      });
    }
  });

  describe("type errors", () => {
    test("decode('') throws TypeError", () => {
      expect(() => decode("")).toThrowError(TypeError);
    });

    test("decode(null as any) throws TypeError", () => {
      expect(() => decode(null as unknown as string)).toThrowError(TypeError);
    });

    test("decode(undefined as any) throws TypeError", () => {
      expect(() => decode(undefined as unknown as string)).toThrowError(TypeError);
    });
  });
});
