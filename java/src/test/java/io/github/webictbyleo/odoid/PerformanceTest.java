package io.github.webictbyleo.odoid;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Performance tests — SPEC.md § 9.
 * Each encode / decode call must average ≤ 0.1000 ms.
 */
class PerformanceTest {

    private static final double LIMIT_MS  = 0.1;
    private static final int    WARMUP    = 2_000;
    private static final int    ITERATIONS = 10_000;

    private void assertAvgMs(String label, Runnable fn) {
        for (int i = 0; i < WARMUP; i++) fn.run();

        long start = System.nanoTime();
        for (int i = 0; i < ITERATIONS; i++) fn.run();
        double avgMs = (System.nanoTime() - start) / 1_000_000.0 / ITERATIONS;

        assertTrue(avgMs <= LIMIT_MS,
            String.format("%s: average %.4f ms exceeded spec limit of %.4f ms", label, avgMs, LIMIT_MS));
    }

    @Test
    void encode_length6_averageBelowLimit() {
        long[] n = {0};
        assertAvgMs("encode/6", () -> {
            n[0] = (n[0] + 1) % Charsets.MAX.get(6);
            OdoId.encode(n[0], 6);
        });
    }

    @Test
    void encode_length7_averageBelowLimit() {
        long[] n = {0};
        assertAvgMs("encode/7", () -> {
            n[0] = (n[0] + 1) % Charsets.MAX.get(7);
            OdoId.encode(n[0], 7);
        });
    }

    @Test
    void encode_length8_averageBelowLimit() {
        long[] n = {0};
        assertAvgMs("encode/8", () -> {
            n[0] = (n[0] + 1) % Charsets.MAX.get(8);
            OdoId.encode(n[0], 8);
        });
    }

    @Test
    void decode_length6_averageBelowLimit() {
        String[] ids = {"0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"};
        int[] i = {0};
        assertAvgMs("decode/6", () -> OdoId.decode(ids[i[0]++ % ids.length]));
    }

    @Test
    void decode_length7_averageBelowLimit() {
        String[] ids = {"0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000"};
        int[] i = {0};
        assertAvgMs("decode/7", () -> OdoId.decode(ids[i[0]++ % ids.length]));
    }

    @Test
    void decode_length8_averageBelowLimit() {
        String[] ids = {"0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"};
        int[] i = {0};
        assertAvgMs("decode/8", () -> OdoId.decode(ids[i[0]++ % ids.length]));
    }
}
