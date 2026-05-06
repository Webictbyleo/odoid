// Package odoid implements the OdoID deterministic mixed-radix encoding scheme.
//
// OdoID maps a 64-bit unsigned integer to a 6, 7, or 8-character alphanumeric
// string with a serial-number aesthetic. Ambiguous characters I, L, and O are
// excluded from all positions to prevent transcription errors.
//
// Basic usage:
//
//	id, err := odoid.Encode(1234567, 6)  // "0D7NM7"
//	n, err  := odoid.Decode("0D7NM7")    // 1234567
//
//	g, err := odoid.NewOdoIDGenerator(odoid.GeneratorConfig{
//	    Namespace: "orders",
//	    Length:    7,
//	})
//	result, err := g.Next()
package odoid
