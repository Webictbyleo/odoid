package odoid

// assertLength returns an UnsupportedLengthError if length is not 6, 7, or 8.
func assertLength(length int) error {
	if !supportedLengths[length] {
		return &UnsupportedLengthError{Length: length}
	}
	return nil
}

// Encode encodes the non-negative integer n into an OdoID string of the given length.
//
// length must be 6 (recommended default), 7, or 8.
// n must satisfy 0 <= n < Max[length].
//
// Returns *UnsupportedLengthError if length is not valid.
// Returns *OverflowError if n >= Max[length].
func Encode(n uint64, length int) (string, error) {
	if err := assertLength(length); err != nil {
		return "", err
	}

	if n >= Max[length] {
		return "", &OverflowError{N: n, Length: length, Max: Max[length]}
	}

	out := make([]byte, length)

	for i := length - 1; i >= 0; i-- {
		charset := getCharset(i)
		base := uint64(len(charset))
		out[i] = charset[n%base]
		n /= base
	}

	return string(out), nil
}
