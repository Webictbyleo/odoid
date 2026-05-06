package odoid

import (
	"fmt"
	"time"
)

// GeneratorConfig holds the configuration for an OdoIDGenerator.
type GeneratorConfig struct {
	// Namespace is the logical partition for this generator. Defaults to "default".
	Namespace string

	// Length is the OdoID string length. Must be 6, 7, or 8. Defaults to 6.
	Length int

	// Epoch is the millisecond timestamp used as the time origin.
	// Zero means use time.Now() at construction time.
	Epoch int64
}

// OdoIDResult is the value returned by OdoIDGenerator.Next.
type OdoIDResult struct {
	ID        string
	N         uint64
	Length    int
	Namespace string
}

// OdoIDGenerator is a distributed monotonic generator that produces OdoID
// strings driven by a namespace-scoped, time-seeded pseudo-random integer.
//
// The generator guarantees that rapid successive calls within the same
// millisecond tick produce distinct values via a monotonically incrementing
// sequence counter. Output is always in [0, Capacity) so Encode never
// returns OverflowError internally.
type OdoIDGenerator struct {
	Namespace string
	Length    int
	Capacity  uint64

	epoch    int64
	sequence uint64
	lastTick int64
}

// NewOdoIDGenerator creates a new OdoIDGenerator from cfg.
// Returns *UnsupportedLengthError if cfg.Length is not 6, 7, or 8.
func NewOdoIDGenerator(cfg GeneratorConfig) (*OdoIDGenerator, error) {
	if cfg.Namespace == "" {
		cfg.Namespace = "default"
	}
	if cfg.Length == 0 {
		cfg.Length = 6
	}
	if err := assertLength(cfg.Length); err != nil {
		return nil, err
	}

	epoch := cfg.Epoch

	return &OdoIDGenerator{
		Namespace: cfg.Namespace,
		Length:    cfg.Length,
		Capacity:  Max[cfg.Length],
		epoch:     epoch,
	}, nil
}

// fnv1a32 computes a FNV-1a 32-bit hash of value.
// Constants are normative: offset basis = 2166136261, prime = 16777619.
func fnv1a32(value string) uint64 {
	h := uint32(2166136261)
	for i := 0; i < len(value); i++ {
		h ^= uint32(value[i])
		h *= 16777619
	}
	return uint64(h)
}

// NextN returns the next raw integer n in [0, Capacity).
// Exported for testing and low-level use.
func (g *OdoIDGenerator) NextN() uint64 {
	tick := time.Now().UnixMilli() - g.epoch

	if tick == g.lastTick {
		g.sequence++
	} else {
		g.sequence = 0
		g.lastTick = tick
	}

	// FNV-1a hash of "namespace|tick", then XOR-shift PRNG
	seed := fnv1a32(fmt.Sprintf("%s|%d", g.Namespace, tick))
	seed ^= seed << 13
	seed ^= seed >> 7
	seed ^= seed << 17

	return (seed + g.sequence) % g.Capacity
}

// Next generates and returns the next OdoID.
func (g *OdoIDGenerator) Next() (OdoIDResult, error) {
	n := g.NextN()
	id, err := Encode(n, g.Length)
	if err != nil {
		return OdoIDResult{}, err
	}
	return OdoIDResult{ID: id, N: n, Length: g.Length, Namespace: g.Namespace}, nil
}

// Encode encodes n using this generator's configured length.
func (g *OdoIDGenerator) Encode(n uint64) (string, error) {
	return Encode(n, g.Length)
}

// Decode decodes an OdoID string to its originating integer.
func (g *OdoIDGenerator) Decode(id string) (uint64, error) {
	return Decode(id)
}
