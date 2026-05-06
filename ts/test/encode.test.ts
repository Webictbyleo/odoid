import { describe, test, expect } from "vitest";
import { encode, OverflowError, UnsupportedLengthError, MAX } from "../src/index.js";

describe("encode()", () => {
  describe("accepts number and bigint input", () => {
    test("encode(0, 6) and encode(0n, 6) produce identical output", () => {
      expect(encode(0, 6)).toBe(encode(0n, 6));
    });

    test("encode(1234567, 6) and encode(1234567n, 6) produce identical output", () => {
      expect(encode(1234567, 6)).toBe(encode(1234567n, 6));
    });
  });

  describe("defaults to length 6", () => {
    test("encode(0) defaults to length 6", () => {
      expect(encode(0)).toHaveLength(6);
    });

    test("encode(0) === '0A0000'", () => {
      expect(encode(0)).toBe("0A0000");
    });
  });

  describe("output properties", () => {
    test("output is always uppercase", () => {
      for (const n of [0, 1, 100, 999999, 1234567]) {
        const id = encode(n, 6);
        expect(id).toBe(id.toUpperCase());
      }
    });

    test("output length matches requested length", () => {
      expect(encode(0n, 6)).toHaveLength(6);
      expect(encode(0n, 7)).toHaveLength(7);
      expect(encode(0n, 8)).toHaveLength(8);
    });

    test("position 1 (0-indexed) is always an ALPHA character", () => {
      const ALPHA = "ABCDEFGHJKMNPQRSTVWXYZ";
      for (const n of [0n, 1n, 100n, 1234567n]) {
        const id = encode(n, 6);
        expect(ALPHA).toContain(id[1]);
      }
    });

    test("position 2 (0-indexed) is always a digit", () => {
      for (const n of [0n, 1n, 100n, 1234567n]) {
        const id = encode(n, 6);
        expect(id[2]).toMatch(/^\d$/);
      }
    });

    test("excluded characters I, L, O never appear in output", () => {
      const samples = [0n, 1n, 1000n, 1234567n, 100000000n, MAX[8] - 1n];
      for (const n of samples) {
        const id = encode(n, 8);
        expect(id).not.toMatch(/[ILO]/);
      }
    });
  });

  describe("boundary values", () => {
    test("encode(0n, 6) is valid", () => {
      expect(() => encode(0n, 6)).not.toThrow();
    });

    test("encode(MAX[6]-1, 6) is valid", () => {
      expect(() => encode(MAX[6] - 1n, 6)).not.toThrow();
    });

    test("encode(0n, 7) is valid", () => {
      expect(() => encode(0n, 7)).not.toThrow();
    });

    test("encode(MAX[7]-1, 7) is valid", () => {
      expect(() => encode(MAX[7] - 1n, 7)).not.toThrow();
    });

    test("encode(0n, 8) is valid", () => {
      expect(() => encode(0n, 8)).not.toThrow();
    });

    test("encode(MAX[8]-1, 8) is valid", () => {
      expect(() => encode(MAX[8] - 1n, 8)).not.toThrow();
    });
  });

  describe("overflow errors", () => {
    test("encode(MAX[6], 6) throws OverflowError", () => {
      expect(() => encode(MAX[6], 6)).toThrowError(OverflowError);
    });

    test("encode(MAX[7], 7) throws OverflowError", () => {
      expect(() => encode(MAX[7], 7)).toThrowError(OverflowError);
    });

    test("encode(MAX[8], 8) throws OverflowError", () => {
      expect(() => encode(MAX[8], 8)).toThrowError(OverflowError);
    });

    test("encode(-1n, 6) throws OverflowError", () => {
      expect(() => encode(-1n, 6)).toThrowError(OverflowError);
    });

    test("OverflowError is instance of RangeError", () => {
      try {
        encode(MAX[6], 6);
      } catch (e) {
        expect(e).toBeInstanceOf(RangeError);
      }
    });

    test("OverflowError message contains the violating value", () => {
      try {
        encode(MAX[6], 6);
      } catch (e) {
        expect((e as Error).message).toContain(String(MAX[6]));
      }
    });
  });

  describe("unsupported length errors", () => {
    const badLengths = [0, 1, 5, 9, 100];
    for (const l of badLengths) {
      test(`encode(0, ${l}) throws UnsupportedLengthError`, () => {
        // @ts-expect-error intentionally passing unsupported length
        expect(() => encode(0, l)).toThrowError(UnsupportedLengthError);
      });
    }
  });
});
