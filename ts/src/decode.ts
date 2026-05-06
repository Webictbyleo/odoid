import { getCharset } from "./charsets.js";
import { InvalidCharacterError, UnsupportedLengthError } from "./errors.js";

/**
 * Decodes an OdoID string back to its originating integer.
 *
 * The input is uppercased before lookup, so lowercase letters that are valid
 * in the charset (e.g. `"0a0000"`) are accepted. The excluded characters
 * `I`, `L`, and `O` remain invalid even after uppercasing.
 *
 * @param id - The OdoID string to decode (6, 7, or 8 characters).
 * @returns  The decoded non-negative integer as `bigint`.
 *
 * @throws {TypeError}             if `id` is not a non-empty string.
 * @throws {UnsupportedLengthError} if `id.length` is not 6, 7, or 8.
 * @throws {InvalidCharacterError} if any character is absent from its positional charset.
 */
export function decode(id: string): bigint {
  if (!id || typeof id !== "string") {
    throw new TypeError("OdoID must be a non-empty string.");
  }

  const upper = id.toUpperCase();
  const L = upper.length;

  if (L !== 6 && L !== 7 && L !== 8) {
    throw new UnsupportedLengthError(L);
  }

  let n = 0n;

  for (let i = 0; i < L; i++) {
    const set = getCharset(i);
    const base = BigInt(set.length);
    const v = set.indexOf(upper[i]);

    if (v < 0) {
      throw new InvalidCharacterError(upper[i], i + 1);
    }

    n = n * base + BigInt(v);
  }

  return n;
}
