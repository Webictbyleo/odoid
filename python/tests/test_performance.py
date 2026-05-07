"""
Performance tests — SPEC.md § 9.
Each encode() / decode() call must average ≤ 0.1000 ms over a representative load.
"""

import time

import pytest
from odoid import decode, encode, OdoIDGenerator

LIMIT_MS = 0.1
WARMUP = 2_000
ITERATIONS = 10_000


def measure_avg(fn, label: str) -> None:
    """
    Warm up *fn* then measure average call time over ITERATIONS calls.
    Asserts the average is within LIMIT_MS.
    """
    for _ in range(WARMUP):
        fn()

    t0 = time.perf_counter()
    for _ in range(ITERATIONS):
        fn()
    elapsed_ms = (time.perf_counter() - t0) * 1000
    avg_ms = elapsed_ms / ITERATIONS
    print(f"RESULT|python|{label}|{avg_ms:.6f}")

    assert avg_ms <= LIMIT_MS, (
        f"{label}: average call time {avg_ms:.4f} ms exceeded "
        f"spec limit of {LIMIT_MS} ms"
    )


class TestPerformance:
    def test_encode_length6(self):
        state = {"n": 0}

        def fn():
            state["n"] = (state["n"] + 1) % 230_686_720
            return encode(state["n"], 6)

        measure_avg(fn, "encode/6")

    def test_encode_length7(self):
        state = {"n": 0}

        def fn():
            state["n"] = (state["n"] + 1) % 7_381_975_040
            return encode(state["n"], 7)

        measure_avg(fn, "encode/7")

    def test_encode_length8(self):
        state = {"n": 0}

        def fn():
            state["n"] = (state["n"] + 1) % 236_223_201_280
            return encode(state["n"], 8)

        measure_avg(fn, "encode/8")

    def test_decode_length6(self):
        ids = ["0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"]
        state = {"i": 0}

        def fn():
            result = decode(ids[state["i"] % len(ids)])
            state["i"] += 1
            return result

        measure_avg(fn, "decode/6")

    def test_decode_length7(self):
        ids = ["0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000"]
        state = {"i": 0}

        def fn():
            result = decode(ids[state["i"] % len(ids)])
            state["i"] += 1
            return result

        measure_avg(fn, "decode/7")

    def test_decode_length8(self):
        ids = ["0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"]
        state = {"i": 0}

        def fn():
            result = decode(ids[state["i"] % len(ids)])
            state["i"] += 1
            return result

        measure_avg(fn, "decode/8")

    def test_generator_next(self):
        gen = OdoIDGenerator(length=6)
        measure_avg(gen.next, "generate/6")
