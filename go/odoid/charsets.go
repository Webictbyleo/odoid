package odoid

// Character set definitions.
// These exact strings MUST be reproduced verbatim in every compliant implementation.
const (
	// NUM is the numeric character set — radix 10.
	NUM = "0123456789"

	// ALPHA is the alpha character set (ambiguous chars I, L, O excluded) — radix 22.
	ALPHA = "ABCDEFGHJKMNPQRSTVWXYZ"

	// ALL is the full hybrid set — NUM concatenated with ALPHA — radix 32.
	ALL = NUM + ALPHA // "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
)

// Max is the maximum exclusive value for each supported length.
// Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
var Max = map[int]uint64{
	6: 230_686_720,
	7: 7_381_975_040,
	8: 236_223_201_280,
}

var supportedLengths = map[int]bool{6: true, 7: true, 8: true}

// getCharset returns the character set for 0-based position index i.
//
//	Index  Charset  Radix
//	0      ALL      32
//	1      ALPHA    22
//	2      NUM      10
//	3+     ALL      32
func getCharset(i int) string {
	switch i {
	case 1:
		return ALPHA
	case 2:
		return NUM
	default:
		return ALL
	}
}
