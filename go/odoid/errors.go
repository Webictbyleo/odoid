package odoid

import "fmt"

// OverflowError is returned when n >= Max[length] for the chosen OdoID length.
type OverflowError struct {
	N      uint64
	Length int
	Max    uint64
}

func (e *OverflowError) Error() string {
	return fmt.Sprintf(
		"n=%d is out of range for length %d. Valid range: 0 <= n < %d",
		e.N, e.Length, e.Max,
	)
}

// UnsupportedLengthError is returned when a length other than 6, 7, or 8 is requested.
type UnsupportedLengthError struct {
	Length int
}

func (e *UnsupportedLengthError) Error() string {
	return fmt.Sprintf("unsupported OdoID length: %d. Must be 6, 7, or 8", e.Length)
}

// InvalidCharacterError is returned when a character absent from the positional
// charset is encountered during decoding.
type InvalidCharacterError struct {
	Char     byte
	Position int // 1-based
}

func (e *InvalidCharacterError) Error() string {
	return fmt.Sprintf("invalid OdoID character %q at position %d", e.Char, e.Position)
}
