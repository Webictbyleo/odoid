package io.github.webictbyleo.odoid;

import java.time.Instant;

/**
 * A distributed monotonic generator that produces OdoID strings driven by a
 * namespace-scoped, time-seeded pseudo-random integer.
 *
 * <p>The generator guarantees that rapid successive calls within the same
 * millisecond tick produce distinct values via a monotonically incrementing
 * sequence counter. Output is always in {@code [0, capacity)} so
 * {@link OdoId#encode} never throws {@link OdoOverflowException} internally.
 */
public final class OdoIDGenerator {

    private final String namespace;
    private final int    length;
    private final long   capacity;
    private final long   epoch;

    private long sequence = 0;
    private long lastTick = Long.MIN_VALUE;

    /**
     * Creates a new {@link OdoIDGenerator} from {@code config}.
     *
     * @throws UnsupportedLengthException if {@link GeneratorConfig#getLength()} is not 6, 7, or 8.
     */
    public OdoIDGenerator(GeneratorConfig config) {
        OdoId.assertLength(config.getLength());
        this.namespace = config.getNamespace();
        this.length    = config.getLength();
        this.capacity  = Charsets.MAX.get(length);
        this.epoch     = config.getEpoch();
    }

    /** Creates a generator with default config (namespace="default", length=6). */
    public OdoIDGenerator() {
        this(GeneratorConfig.builder().build());
    }

    public String getNamespace() { return namespace; }
    public int    getLength()    { return length; }
    public long   getCapacity()  { return capacity; }

    private long nowMs() {
        return Instant.now().toEpochMilli() - epoch;
    }

    /**
     * FNV-1a 32-bit hash.
     * Constants are normative: offset basis = 2166136261, prime = 16777619.
     */
    private static long fnv1a32(String value) {
        long h = 2166136261L;
        for (char c : value.toCharArray()) {
            h ^= (byte) c;
            h = (h * 16777619L) & 0xFFFFFFFFL;
        }
        return h;
    }

    /**
     * Returns the next raw integer {@code n} in {@code [0, capacity)}.
     * Exposed for testing and low-level use.
     */
    public synchronized long nextN() {
        long tick = nowMs();
        if (tick == lastTick) {
            sequence++;
        } else {
            sequence = 0;
            lastTick = tick;
        }

        long seed = fnv1a32(namespace + "|" + tick);
        seed ^= (seed << 13) & 0xFFFFFFFFL;
        seed ^= (seed >> 7);
        seed ^= (seed << 17) & 0xFFFFFFFFL;

        return (seed + sequence) % capacity;
    }

    /** Generates and returns the next OdoID. */
    public OdoIDResult next() {
        long n     = nextN();
        String id  = OdoId.encode(n, length);
        return new OdoIDResult(id, n, length, namespace);
    }

    /** Encodes {@code n} using this generator's configured length. */
    public String encode(long n) { return OdoId.encode(n, length); }

    /** Decodes an OdoID string to its originating integer. */
    public long decode(String id) { return OdoId.decode(id); }
}
