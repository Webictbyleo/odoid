/**
 * OdoID character set definitions.
 * These exact strings MUST be reproduced verbatim in every compliant implementation.
 */

/** Numeric characters — radix 10 */
export const NUM = "0123456789";

/** Alpha characters (ambiguous chars I, L, O excluded) — radix 22 */
export const ALPHA = "ABCDEFGHJKMNPQRSTVWXYZ";

/** Full hybrid set — NUM concatenated with ALPHA — radix 32 */
export const ALL = NUM + ALPHA; // "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

/** Supported OdoID lengths */
export const SUPPORTED_LENGTHS = [6, 7, 8] as const;
export type OdoLength = (typeof SUPPORTED_LENGTHS)[number];

/**
 * Maximum exclusive value for each supported length.
 * Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
 */
export const MAX: Record<OdoLength, bigint> = {
  6: 230_686_720n,
  7: 7_381_975_040n,
  8: 236_223_201_280n,
};

/**
 * Returns the character set for a given 0-based position index.
 *
 * | Index | Charset | Radix |
 * |-------|---------|-------|
 * | 0     | ALL     | 32    |
 * | 1     | ALPHA   | 22    |
 * | 2     | NUM     | 10    |
 * | 3+    | ALL     | 32    |
 */
export function getCharset(i: number): string {
  if (i === 1) return ALPHA;
  if (i === 2) return NUM;
  return ALL;
}
