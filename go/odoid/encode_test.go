package odoid_test

import (
	"strings"
	"testing"

	"github.com/Webictbyleo/odoid/go/odoid"
)

func TestEncodeOutputLength(t *testing.T) {
	for _, length := range []int{6, 7, 8} {
		got, err := odoid.Encode(0, length)
		if err != nil {
			t.Fatalf("Encode(0, %d): %v", length, err)
		}
		if len(got) != length {
			t.Errorf("Encode(0, %d) length = %d; want %d", length, len(got), length)
		}
	}
}

func TestEncodeOutputIsUppercase(t *testing.T) {
	samples := []uint64{0, 1, 100, 999999, 1234567}
	for _, n := range samples {
		got, err := odoid.Encode(n, 6)
		if err != nil {
			t.Fatalf("Encode(%d, 6): %v", n, err)
		}
		if got != strings.ToUpper(got) {
			t.Errorf("Encode(%d, 6) = %q is not uppercase", n, got)
		}
	}
}

func TestEncodePosition1IsAlpha(t *testing.T) {
	for _, n := range []uint64{0, 1, 100, 1234567} {
		got, err := odoid.Encode(n, 6)
		if err != nil {
			t.Fatalf("Encode(%d, 6): %v", n, err)
		}
		if !strings.ContainsRune(odoid.ALPHA, rune(got[1])) {
			t.Errorf("Encode(%d, 6)[1] = %q; not in ALPHA charset", n, got[1])
		}
	}
}

func TestEncodePosition2IsDigit(t *testing.T) {
	for _, n := range []uint64{0, 1, 100, 1234567} {
		got, err := odoid.Encode(n, 6)
		if err != nil {
			t.Fatalf("Encode(%d, 6): %v", n, err)
		}
		ch := got[2]
		if ch < '0' || ch > '9' {
			t.Errorf("Encode(%d, 6)[2] = %q; not a digit", n, ch)
		}
	}
}

func TestEncodeExcludedCharsNeverAppear(t *testing.T) {
	samples := []uint64{0, 1, 1000, 1234567, 100_000_000, odoid.Max[8] - 1}
	for _, n := range samples {
		got, err := odoid.Encode(n, 8)
		if err != nil {
			t.Fatalf("Encode(%d, 8): %v", n, err)
		}
		for _, ch := range []byte{'I', 'L', 'O'} {
			if strings.IndexByte(got, ch) >= 0 {
				t.Errorf("Encode(%d, 8) = %q contains excluded char %q", n, got, ch)
			}
		}
	}
}

func TestEncodeBoundaryValues(t *testing.T) {
	for _, length := range []int{6, 7, 8} {
		if _, err := odoid.Encode(0, length); err != nil {
			t.Errorf("Encode(0, %d): unexpected error: %v", length, err)
		}
		if _, err := odoid.Encode(odoid.Max[length]-1, length); err != nil {
			t.Errorf("Encode(Max[%d]-1, %d): unexpected error: %v", length, length, err)
		}
	}
}

func TestEncodeOverflowAtMax(t *testing.T) {
	for _, length := range []int{6, 7, 8} {
		_, err := odoid.Encode(odoid.Max[length], length)
		if err == nil {
			t.Errorf("Encode(Max[%d], %d): expected OverflowError, got nil", length, length)
			continue
		}
		if _, ok := err.(*odoid.OverflowError); !ok {
			t.Errorf("Encode(Max[%d], %d): expected *OverflowError, got %T", length, length, err)
		}
	}
}

func TestEncodeUnsupportedLengths(t *testing.T) {
	for _, length := range []int{0, 1, 5, 9, 100} {
		_, err := odoid.Encode(0, length)
		if err == nil {
			t.Errorf("Encode(0, %d): expected UnsupportedLengthError, got nil", length)
			continue
		}
		if _, ok := err.(*odoid.UnsupportedLengthError); !ok {
			t.Errorf("Encode(0, %d): expected *UnsupportedLengthError, got %T", length, err)
		}
	}
}
