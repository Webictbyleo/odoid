// Performance tests — SPEC.md § 9.
// Each encode() / decode() call must average ≤ 0.1000 ms over a representative load.
//
// Run benchmarks with: go test -bench=. -benchtime=5s ./odoid/
package odoid_test

import (
	"fmt"
	"testing"
	"time"

	"github.com/Webictbyleo/odoid/go/odoid"
)

const (
	perfLimitMs = 0.1
	perfWarmup  = 2_000
	perfIter    = 10_000
)

func assertAvgMs(t *testing.T, label string, fn func()) {
	t.Helper()
	for i := 0; i < perfWarmup; i++ {
		fn()
	}
	start := time.Now()
	for i := 0; i < perfIter; i++ {
		fn()
	}
	avgMs := float64(time.Since(start).Nanoseconds()) / float64(perfIter) / 1e6
	fmt.Printf("RESULT|go|%s|%.6f\n", label, avgMs)
	if avgMs > perfLimitMs {
		t.Errorf("%s: average %.4f ms exceeded spec limit of %.4f ms", label, avgMs, perfLimitMs)
	}
}

func TestPerformanceEncodeLength6(t *testing.T) {
	n := uint64(0)
	assertAvgMs(t, "encode/6", func() {
		n = (n + 1) % odoid.Max[6]
		odoid.Encode(n, 6) //nolint:errcheck
	})
}

func TestPerformanceEncodeLength7(t *testing.T) {
	n := uint64(0)
	assertAvgMs(t, "encode/7", func() {
		n = (n + 1) % odoid.Max[7]
		odoid.Encode(n, 7) //nolint:errcheck
	})
}

func TestPerformanceEncodeLength8(t *testing.T) {
	n := uint64(0)
	assertAvgMs(t, "encode/8", func() {
		n = (n + 1) % odoid.Max[8]
		odoid.Encode(n, 8) //nolint:errcheck
	})
}

func TestPerformanceDecodeLength6(t *testing.T) {
	ids := []string{"0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"}
	i := 0
	assertAvgMs(t, "decode/6", func() {
		odoid.Decode(ids[i%len(ids)]) //nolint:errcheck
		i++
	})
}

func TestPerformanceDecodeLength7(t *testing.T) {
	ids := []string{"0A00000", "0A15NM7", "ZZ9ZZZZ", "1B3C4D5", "AB00000"}
	i := 0
	assertAvgMs(t, "decode/7", func() {
		odoid.Decode(ids[i%len(ids)]) //nolint:errcheck
		i++
	})
}

func TestPerformanceDecodeLength8(t *testing.T) {
	ids := []string{"0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"}
	i := 0
	assertAvgMs(t, "decode/8", func() {
		odoid.Decode(ids[i%len(ids)]) //nolint:errcheck
		i++
	})
}

func TestPerformanceGeneratorNext(t *testing.T) {
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: 6})
	assertAvgMs(t, "generate/6", func() {
		g.Next() //nolint:errcheck
	})
}

// ── Benchmarks (go test -bench=. -benchtime=5s ./odoid/) ──────────────────

func BenchmarkEncode6(b *testing.B) {
	n := uint64(0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		n = (n + 1) % odoid.Max[6]
		odoid.Encode(n, 6) //nolint:errcheck
	}
}

func BenchmarkEncode7(b *testing.B) {
	n := uint64(0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		n = (n + 1) % odoid.Max[7]
		odoid.Encode(n, 7) //nolint:errcheck
	}
}

func BenchmarkEncode8(b *testing.B) {
	n := uint64(0)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		n = (n + 1) % odoid.Max[8]
		odoid.Encode(n, 8) //nolint:errcheck
	}
}

func BenchmarkDecode6(b *testing.B) {
	ids := []string{"0A0000", "0D7NM7", "ZZ9ZZZ", "1B3C4D", "AB0000"}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		odoid.Decode(ids[i%len(ids)]) //nolint:errcheck
	}
}

func BenchmarkDecode8(b *testing.B) {
	ids := []string{"0A000000", "ZZ9ZZZZZ", "1B3C4D5E", "AB000000"}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		odoid.Decode(ids[i%len(ids)]) //nolint:errcheck
	}
}
