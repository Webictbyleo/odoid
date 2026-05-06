import { MAX, OdoLength, getCharset } from "./charsets.js";
import { OverflowError, UnsupportedLengthError } from "./errors.js";

/**
 * Asserts that `length` is a supported OdoID length (6, 7, or 8).
 * Throws {@link UnsupportedLengthError} otherwise.
 */
export function assertLength(length: number): asserts length is OdoLength {
  if (length !== 6 && length !== 7 && length !== 8) {
    throw new UnsupportedLengthError(length);
  }
}

/**
 * Encodes a non-negative integer `n` into an OdoID string of the given `length`.
 *
 * @param n      - The integer to encode. Accepts `number` or `bigint`.
 * @param length - Target string length: 6 (default), 7, or 8.
 * @returns      The encoded OdoID string (uppercase).
 *
 * @throws {UnsupportedLengthError} if `length` is not 6, 7, or 8.
 * @throws {OverflowError}          if `n < 0` or `n >= MAX[length]`.
 */
export function encode(n: bigint | number, length: OdoLength = 6): string {
  assertLength(length);

  const x0 = BigInt(n);

  if (x0 < 0n || x0 >= MAX[length]) {
    throw new OverflowError(
      `n=${x0} is out of range for length ${length}. Valid range: 0 ≤ n < ${MAX[length]}.`
    );
  }

  const out = new Array<string>(length);
  let x = x0;

  for (let i = length - 1; i >= 0; i--) {
    const set = getCharset(i);
    const base = BigInt(set.length);
    out[i] = set[Number(x % base)];
    x = x / base;
  }

  return out.join("");
}
