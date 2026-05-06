package odoid_test

import (
	"testing"
	"time"

	"github.com/Webictbyleo/odoid/go/odoid"
)

func TestGeneratorDefaults(t *testing.T) {
	g, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{})
	if err != nil {
		t.Fatalf("NewOdoIDGenerator: %v", err)
	}
	if g.Namespace != "default" {
		t.Errorf("Namespace = %q; want %q", g.Namespace, "default")
	}
	if g.Length != 6 {
		t.Errorf("Length = %d; want 6", g.Length)
	}
}

func TestGeneratorCustomConfig(t *testing.T) {
	g, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Namespace: "acme", Length: 8})
	if err != nil {
		t.Fatalf("NewOdoIDGenerator: %v", err)
	}
	if g.Namespace != "acme" {
		t.Errorf("Namespace = %q; want %q", g.Namespace, "acme")
	}
	if g.Length != 8 {
		t.Errorf("Length = %d; want 8", g.Length)
	}
}

func TestGeneratorCapacityMatchesMax(t *testing.T) {
	for _, length := range []int{6, 7, 8} {
		g, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: length})
		if err != nil {
			t.Fatalf("NewOdoIDGenerator(length=%d): %v", length, err)
		}
		if g.Capacity != odoid.Max[length] {
			t.Errorf("Capacity = %d; want %d", g.Capacity, odoid.Max[length])
		}
	}
}

func TestGeneratorUnsupportedLength(t *testing.T) {
	_, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: 5})
	if err == nil {
		t.Fatal("expected UnsupportedLengthError, got nil")
	}
	if _, ok := err.(*odoid.UnsupportedLengthError); !ok {
		t.Errorf("expected *UnsupportedLengthError, got %T", err)
	}
}

func TestGeneratorNextShape(t *testing.T) {
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Namespace: "test", Length: 6})
	result, err := g.Next()
	if err != nil {
		t.Fatalf("Next(): %v", err)
	}
	if result.ID == "" {
		t.Error("ID is empty")
	}
	if result.Length != 6 {
		t.Errorf("Length = %d; want 6", result.Length)
	}
	if result.Namespace != "test" {
		t.Errorf("Namespace = %q; want %q", result.Namespace, "test")
	}
}

func TestGeneratorIDLength(t *testing.T) {
	for _, length := range []int{6, 7, 8} {
		g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: length})
		result, err := g.Next()
		if err != nil {
			t.Fatalf("Next() length=%d: %v", length, err)
		}
		if len(result.ID) != length {
			t.Errorf("len(ID) = %d; want %d", len(result.ID), length)
		}
	}
}

func TestGeneratorExcludedCharsNeverInOutput(t *testing.T) {
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: 8})
	for i := 0; i < 50; i++ {
		result, err := g.Next()
		if err != nil {
			t.Fatalf("Next(): %v", err)
		}
		for _, ch := range []byte{'I', 'L', 'O'} {
			for _, c := range []byte(result.ID) {
				if c == ch {
					t.Errorf("ID %q contains excluded char %q", result.ID, ch)
				}
			}
		}
	}
}

func TestGeneratorNInValidRange(t *testing.T) {
	for _, length := range []int{6, 7, 8} {
		g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: length})
		for i := 0; i < 50; i++ {
			result, err := g.Next()
			if err != nil {
				t.Fatalf("Next() length=%d: %v", length, err)
			}
			if result.N >= odoid.Max[length] {
				t.Errorf("N = %d; must be < Max[%d] = %d", result.N, length, odoid.Max[length])
			}
		}
	}
}

func TestGeneratorNMatchesDecodeID(t *testing.T) {
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Namespace: "verify", Length: 6})
	for i := 0; i < 20; i++ {
		result, err := g.Next()
		if err != nil {
			t.Fatalf("Next(): %v", err)
		}
		decoded, err := odoid.Decode(result.ID)
		if err != nil {
			t.Fatalf("Decode(%q): %v", result.ID, err)
		}
		if decoded != result.N {
			t.Errorf("Decode(%q) = %d; want %d", result.ID, decoded, result.N)
		}
	}
}

func TestGeneratorMonotonicSequencing(t *testing.T) {
	// Future epoch keeps tick at 0 — all calls are within the same tick.
	futureEpoch := time.Now().UnixMilli() + 60_000
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{
		Namespace: "seq-test",
		Epoch:     futureEpoch,
	})

	seen := make(map[string]bool)
	for i := 0; i < 20; i++ {
		result, err := g.Next()
		if err != nil {
			t.Fatalf("Next(): %v", err)
		}
		if seen[result.ID] {
			t.Errorf("duplicate ID %q at iteration %d", result.ID, i)
		}
		seen[result.ID] = true
	}
}

func TestGeneratorNamespaceIsolation(t *testing.T) {
	futureEpoch := time.Now().UnixMilli() + 60_000
	g1, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Namespace: "ns-a", Length: 8, Epoch: futureEpoch})
	g2, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Namespace: "ns-b", Length: 8, Epoch: futureEpoch})

	r1, _ := g1.Next()
	r2, _ := g2.Next()

	if r1.ID == r2.ID {
		t.Errorf("different namespaces produced identical ID %q", r1.ID)
	}
}

func TestGeneratorProxyEncode(t *testing.T) {
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: 7})
	id, err := g.Encode(0)
	if err != nil {
		t.Fatalf("Encode(0): %v", err)
	}
	if len(id) != 7 {
		t.Errorf("len(id) = %d; want 7", len(id))
	}
}

func TestGeneratorProxyDecode(t *testing.T) {
	g, _ := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{Length: 6})
	result, _ := g.Next()
	n, err := g.Decode(result.ID)
	if err != nil {
		t.Fatalf("Decode(%q): %v", result.ID, err)
	}
	if n != result.N {
		t.Errorf("Decode(%q) = %d; want %d", result.ID, n, result.N)
	}
}
