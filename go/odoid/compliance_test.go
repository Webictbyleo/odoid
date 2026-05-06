// Compliance test vectors as defined in SPEC.md § 8.
// Every compliant implementation MUST pass these tests unchanged.
package odoid_test

import (
	"testing"

	"github.com/Webictbyleo/odoid/go/odoid"
)

func TestComplianceEncode(t *testing.T) {
	tests := []struct {
		n      uint64
		length int
		want   string
	}{
		{0, 6, "0A0000"},
		{1234567, 6, "0D7NM7"},
		{1234567, 7, "0A15NM7"},
		{236223201279, 8, "ZZ9ZZZZZ"},
		{230686719, 6, "ZZ9ZZZ"}, // max valid for L=6
	}

	for _, tt := range tests {
		got, err := odoid.Encode(tt.n, tt.length)
		if err != nil {
			t.Errorf("Encode(%d, %d): unexpected error: %v", tt.n, tt.length, err)
			continue
		}
		if got != tt.want {
			t.Errorf("Encode(%d, %d) = %q; want %q", tt.n, tt.length, got, tt.want)
		}
	}
}

func TestComplianceDecode(t *testing.T) {
	tests := []struct {
		id   string
		want uint64
	}{
		{"0A0000", 0},
		{"0D7NM7", 1234567},
		{"0A15NM7", 1234567},
		{"ZZ9ZZZZZ", 236223201279},
		{"ZZ9ZZZ", 230686719},
	}

	for _, tt := range tests {
		got, err := odoid.Decode(tt.id)
		if err != nil {
			t.Errorf("Decode(%q): unexpected error: %v", tt.id, err)
			continue
		}
		if got != tt.want {
			t.Errorf("Decode(%q) = %d; want %d", tt.id, got, tt.want)
		}
	}
}

func TestComplianceErrors(t *testing.T) {
	t.Run("encode MAX[6] overflows", func(t *testing.T) {
		_, err := odoid.Encode(odoid.Max[6], 6)
		if err == nil {
			t.Fatal("expected OverflowError, got nil")
		}
		if _, ok := err.(*odoid.OverflowError); !ok {
			t.Errorf("expected *OverflowError, got %T: %v", err, err)
		}
	})

	t.Run("encode length 5 unsupported", func(t *testing.T) {
		_, err := odoid.Encode(0, 5)
		if err == nil {
			t.Fatal("expected UnsupportedLengthError, got nil")
		}
		if _, ok := err.(*odoid.UnsupportedLengthError); !ok {
			t.Errorf("expected *UnsupportedLengthError, got %T: %v", err, err)
		}
	})

	t.Run("decode 'O' at position 6", func(t *testing.T) {
		_, err := odoid.Decode("0A000O")
		if err == nil {
			t.Fatal("expected InvalidCharacterError, got nil")
		}
		icErr, ok := err.(*odoid.InvalidCharacterError)
		if !ok {
			t.Fatalf("expected *InvalidCharacterError, got %T: %v", err, err)
		}
		if icErr.Position != 6 {
			t.Errorf("Position = %d; want 6", icErr.Position)
		}
		if icErr.Char != 'O' {
			t.Errorf("Char = %q; want 'O'", icErr.Char)
		}
	})

	t.Run("decode 'I' at position 6", func(t *testing.T) {
		_, err := odoid.Decode("0A000I")
		if err == nil {
			t.Fatal("expected InvalidCharacterError, got nil")
		}
		if icErr, ok := err.(*odoid.InvalidCharacterError); ok {
			if icErr.Position != 6 {
				t.Errorf("Position = %d; want 6", icErr.Position)
			}
		}
	})

	t.Run("decode lowercase 'l' becomes 'L' which is excluded", func(t *testing.T) {
		_, err := odoid.Decode("0A000l")
		if err == nil {
			t.Fatal("expected InvalidCharacterError, got nil")
		}
		if _, ok := err.(*odoid.InvalidCharacterError); !ok {
			t.Errorf("expected *InvalidCharacterError, got %T: %v", err, err)
		}
	})

	t.Run("decode empty string errors", func(t *testing.T) {
		_, err := odoid.Decode("")
		if err == nil {
			t.Fatal("expected error, got nil")
		}
	})
}
