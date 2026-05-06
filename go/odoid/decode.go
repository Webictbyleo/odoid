package odoid

import (
	"fmt"
	"strings"
)

// Decode decodes an OdoID string back to its originating integer.
//
// The input is uppercased before lookup, so lowercase letters that are valid
// in the charset (e.g. "0a0000") are accepted. The excluded characters I, L,
// and O remain invalid even after uppercasing.
//
// Returns an error if id is empty, has unsupported length, or contains
// characters absent from the positional charset.
func Decode(id string) (uint64, error) {
	if id == "" {
		return 0, fmt.Errorf("OdoID must be a non-empty string")
	}

	upper := strings.ToUpper(id)
	length := len(upper)

	if err := assertLength(length); err != nil {
		return 0, err
	}

	var n uint64

	for i := 0; i < length; i++ {
		charset := getCharset(i)
		base := uint64(len(charset))
		v := strings.IndexByte(charset, upper[i])

		if v < 0 {
			return 0, &InvalidCharacterError{Char: upper[i], Position: i + 1}
		}

		n = n*base + uint64(v)
	}

	return n, nil
}
