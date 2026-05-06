//! Performance tests — SPEC.md § 9.
//! Each encode / decode call must average ≤ 0.1000 ms over a representative load.
//!
//! Run with: cargo test --release -- perf

use std::time::Instant;
use odoid::{decode, encode, MAX};

const LIMIT_MS: f64 = 0.1;
const WARMUP: usize = 2_000;
const ITERATIONS: usize = 10_000;

fn assert_avg_ms(label: &str, mut f: impl FnMut()) {
    for _ in 0..WARMUP {
        f();
    }
    let t = Instant::now();
    for _ in 0..ITERATIONS {
        f();
    }
    let avg_ms = t.elapsed().as_secs_f64() * 1000.0 / ITERATIONS as f64;
    assert!(
        avg_ms <= LIMIT_MS,
        "{label}: average {avg_ms:.4} ms exceeded spec limit of {LIMIT_MS} ms"
    );
}

#[test]
fn perf_encode_length6() {
    let mut n = 0u64;
    assert_avg_ms("encode/6", || {
        n = (n + 1) % MAX[6];
        let _ = encode(n, 6);
    });
}

#[test]
fn perf_encode_length7() {
    let mut n = 0u64;
    assert_avg_ms("encode/7", || {
        n = (n + 1) % MAX[7];
        let _ = encode(n, 7);
    });
}

#[test]
fn perf_encode_length8() {
    let mut n = 0u64;
    assert_avg_ms("encode/8", || {
        n = (n + 1) % MAX[8];
        let _ = encode(n, 8);
    });
}

#[test]
fn perf_decode_length6() {
    let ids = ["0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"];
    let mut i = 0usize;
    assert_avg_ms("decode/6", || {
        let _ = decode(ids[i % ids.len()]);
        i += 1;
    });
}

#[test]
fn perf_decode_length7() {
    let ids = ["0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000"];
    let mut i = 0usize;
    assert_avg_ms("decode/7", || {
        let _ = decode(ids[i % ids.len()]);
        i += 1;
    });
}

#[test]
fn perf_decode_length8() {
    let ids = ["0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"];
    let mut i = 0usize;
    assert_avg_ms("decode/8", || {
        let _ = decode(ids[i % ids.len()]);
        i += 1;
    });
}
