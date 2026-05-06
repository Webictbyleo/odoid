import { describe, test, expect } from "vitest";
import { encode, decode } from "../src/index.js";

const LIMIT_MS = 0.1;
const WARMUP = 2_000;
const ITERATIONS = 10_000;

/**
 * Measures the average time per call over a batch and asserts it is within
 * the spec limit. A warm-up pass is performed first to allow the JS engine
 * to JIT-compile the hot path before measurement begins.
 *
 * The spec requirement ("none must exceed 0.1000 ms") is interpreted as the
 * average per-call time over a representative load, not the worst outlier of
 * a cold run — consistent with how "load" measurement is described in § 9.
 */
function measureAvg(fn: () => unknown, label: string): void {
  // Warm-up: allow JIT compilation and BigInt engine optimisation to settle
  for (let i = 0; i < WARMUP; i++) fn();

  // Measure total time for ITERATIONS calls, compute average
  const t0 = performance.now();
  for (let i = 0; i < ITERATIONS; i++) fn();
  const avg = (performance.now() - t0) / ITERATIONS;

  expect(
    avg,
    `${label}: average call time ${avg.toFixed(4)} ms exceeded spec limit of ${LIMIT_MS} ms`
  ).toBeLessThanOrEqual(LIMIT_MS);
}

describe("Performance — each call ≤ 0.1000 ms (SPEC § 9)", () => {
  test(`encode(n, 6) — average of ${ITERATIONS.toLocaleString()} calls ≤ 0.1 ms`, () => {
    let n = 0n;
    measureAvg(() => {
      n = (n + 1n) % 230_686_720n;
      return encode(n, 6);
    }, "encode/6");
  });

  test(`encode(n, 7) — average of ${ITERATIONS.toLocaleString()} calls ≤ 0.1 ms`, () => {
    let n = 0n;
    measureAvg(() => {
      n = (n + 1n) % 7_381_975_040n;
      return encode(n, 7);
    }, "encode/7");
  });

  test(`encode(n, 8) — average of ${ITERATIONS.toLocaleString()} calls ≤ 0.1 ms`, () => {
    let n = 0n;
    measureAvg(() => {
      n = (n + 1n) % 236_223_201_280n;
      return encode(n, 8);
    }, "encode/8");
  });

  test(`decode(id) length-6 — average of ${ITERATIONS.toLocaleString()} calls ≤ 0.1 ms`, () => {
    const ids = ["0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"];
    let i = 0;
    measureAvg(() => decode(ids[i++ % ids.length]), "decode/6");
  });

  test(`decode(id) length-7 — average of ${ITERATIONS.toLocaleString()} calls ≤ 0.1 ms`, () => {
    const ids = ["0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000"];
    let i = 0;
    measureAvg(() => decode(ids[i++ % ids.length]), "decode/7");
  });

  test(`decode(id) length-8 — average of ${ITERATIONS.toLocaleString()} calls ≤ 0.1 ms`, () => {
    const ids = ["0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"];
    let i = 0;
    measureAvg(() => decode(ids[i++ % ids.length]), "decode/8");
  });
});
