package odoid_test

import (
	"testing"

	"github.com/Webictbyleo/odoid/go/odoid"
)

func TestDecodeRoundTrips(t *testing.T) {
	samples := []uint64{0, 1, 255, 65535, 1234567}
	for _, length := range []int{6, 7, 8} {
		for _, n := range samples {
			if n >= odoid.Max[length] {
				continue
			}
			id, err := odoid.Encode(n, length)
			if err != nil {
				t.Fatalf("Encode(%d, %d): %v", n, length, err)
			}
			got, err := odoid.Decode(id)
			if err != nil {
				t.Errorf("Decode(%q): unexpected error: %v", id, err)
				continue
			}
			if got != n {
				t.Errorf("Decode(Encode(%d, %d)) = %d; want %d", n, length, got, n)
			}
		}
	}
}

func TestDecodeLowercaseAccepted(t *testing.T) {
	n, err := odoid.Decode("0a0000")
	if err != nil {
		t.Fatalf("Decode(\"0a0000\"): unexpected error: %v", err)
	}
	if n != 0 {
		t.Errorf("Decode(\"0a0000\") = %d; want 0", n)
	}
}

func TestDecodeMixedCaseMatchesUpper(t *testing.T) {
	lower, err := odoid.Decode("0d7nm7")
	if err != nil {
		t.Fatalf("Decode(\"0d7nm7\"): %v", err)
	}
	upper, err := odoid.Decode("0D7NM7")
	if err != nil {
		t.Fatalf("Decode(\"0D7NM7\"): %v", err)
	}
	if lower != upper {
		t.Errorf("Decode(\"0d7nm7\") = %d; Decode(\"0D7NM7\") = %d; should be equal", lower, upper)
	}
}

func TestDecodeExcludedCharsRejected(t *testing.T) {
	for _, ch := range []byte{'I', 'L', 'O'} {
		id := "0A0" + string(ch) + "00"
		_, err := odoid.Decode(id)
		if err == nil {
			t.Errorf("Decode(%q): expected InvalidCharacterError, got nil", id)
			continue
		}
		if _, ok := err.(*odoid.InvalidCharacterError); !ok {
			t.Errorf("Decode(%q): expected *InvalidCharacterError, got %T", id, err)
		}
	}
}

func TestDecodeErrorReportsPosition(t *testing.T) {
	_, err := odoid.Decode("0A000O")
	if err == nil {
		t.Fatal("expected InvalidCharacterError, got nil")
	}
	icErr, ok := err.(*odoid.InvalidCharacterError)
	if !ok {
		t.Fatalf("expected *InvalidCharacterError, got %T", err)
	}
	if icErr.Position != 6 {
		t.Errorf("Position = %d; want 6", icErr.Position)
	}
	if icErr.Char != 'O' {
		t.Errorf("Char = %q; want 'O'", icErr.Char)
	}
}

func TestDecodeSpecialCharRejected(t *testing.T) {
	_, err := odoid.Decode("0A00-0")
	if err == nil {
		t.Error("expected error for '-' character, got nil")
	}
}

func TestDecodeUnsupportedLength(t *testing.T) {
	for _, id := range []string{"0A000", "0A000000000"} {
		_, err := odoid.Decode(id)
		if err == nil {
			t.Errorf("Decode(%q): expected UnsupportedLengthError, got nil", id)
			continue
		}
		if _, ok := err.(*odoid.UnsupportedLengthError); !ok {
			t.Errorf("Decode(%q): expected *UnsupportedLengthError, got %T", id, err)
		}
	}
}

func TestDecodeEmptyStringErrors(t *testing.T) {
	_, err := odoid.Decode("")
	if err == nil {
		t.Error("Decode(\"\"): expected error, got nil")
	}
}
