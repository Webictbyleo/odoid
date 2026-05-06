import { MAX, OdoLength } from "./charsets.js";
import { UnsupportedLengthError } from "./errors.js";
import { assertLength, encode } from "./encode.js";
import { decode } from "./decode.js";

/** Constructor options for {@link OdoIDGenerator}. */
export interface OdoIDGeneratorOptions {
  /** Logical namespace for this generator. Defaults to `"default"`. */
  namespace?: string;
  /** OdoID string length. Must be 6, 7, or 8. Defaults to `6`. */
  length?: OdoLength;
  /**
   * Millisecond epoch used as the time origin.
   * Defaults to `Date.now()` at construction time.
   */
  epoch?: number;
}

/** Value returned by {@link OdoIDGenerator.next}. */
export interface OdoIDResult {
  id: string;
  n: bigint;
  length: OdoLength;
  namespace: string;
}

/**
 * Computes a FNV-1a 32-bit hash of `value`.
 * Constants are normative: offset basis = 2166136261, prime = 16777619.
 */
function fnv1a32(value: string): number {
  let h = 2166136261 >>> 0;
  for (let i = 0; i < value.length; i++) {
    h ^= value.charCodeAt(i);
    h = Math.imul(h, 16777619) >>> 0;
  }
  return h >>> 0;
}

/**
 * A distributed monotonic generator that produces OdoID strings driven by a
 * namespace-scoped, time-seeded pseudo-random integer.
 *
 * The generator guarantees that rapid successive calls within the same
 * millisecond tick produce distinct values via a monotonically incrementing
 * sequence counter. Output is always in `[0, capacity)` so `encode()` never
 * throws `OverflowError` internally.
 */
export class OdoIDGenerator {
  readonly namespace: string;
  readonly length: OdoLength;
  readonly capacity: bigint;

  private readonly epoch: bigint;
  private sequence: bigint = 0n;
  private lastTick: bigint = 0n;

  constructor({
    namespace = "default",
    length = 6,
    epoch = Date.now(),
  }: OdoIDGeneratorOptions = {}) {
    assertLength(length);
    this.namespace = namespace;
    this.length = length;
    this.capacity = MAX[length];
    this.epoch = BigInt(epoch);
  }

  private now(): bigint {
    return BigInt(Date.now()) - this.epoch;
  }

  /**
   * Returns the next raw integer `n` in `[0, capacity)`.
   * Exported for testing and low-level use.
   */
  nextN(): bigint {
    const tick = this.now();

    if (tick === this.lastTick) {
      this.sequence += 1n;
    } else {
      this.sequence = 0n;
      this.lastTick = tick;
    }

    // FNV-1a hash of "namespace|tick", then XOR-shift PRNG
    let seed = BigInt(fnv1a32(`${this.namespace}|${tick}`));
    seed ^= seed << 13n;
    seed ^= seed >> 7n;
    seed ^= seed << 17n;

    // seed may be negative after BigInt shifts; normalize via abs + modulo
    let n = (seed + this.sequence) % this.capacity;
    if (n < 0n) n = -n;

    return n;
  }

  /** Generates the next OdoID. */
  next(): OdoIDResult {
    const n = this.nextN();
    const id = encode(n, this.length);
    return { id, n, length: this.length, namespace: this.namespace };
  }

  /** Encodes `n` using this generator's configured length. */
  encode(n: bigint | number): string {
    return encode(n, this.length);
  }

  /** Decodes an OdoID string to its originating integer. */
  decode(id: string): bigint {
    return decode(id);
  }
}
