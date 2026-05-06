package io.github.webictbyleo.odoid;

import java.time.Instant;

/**
 * Configuration for {@link OdoIDGenerator}.
 */
public final class GeneratorConfig {

    private final String namespace;
    private final int length;
    private final long epoch;

    private GeneratorConfig(Builder b) {
        this.namespace = b.namespace;
        this.length    = b.length;
        this.epoch     = b.epoch;
    }

    public String getNamespace() { return namespace; }
    public int    getLength()    { return length; }
    public long   getEpoch()     { return epoch; }

    /** Returns a builder with sensible defaults. */
    public static Builder builder() { return new Builder(); }

    public static final class Builder {
        private String namespace = "default";
        private int    length    = 6;
        private long   epoch     = 0L;

        public Builder namespace(String namespace) { this.namespace = namespace; return this; }
        public Builder length(int length)          { this.length    = length;    return this; }
        public Builder epoch(long epoch)           { this.epoch     = epoch;     return this; }
        public GeneratorConfig build()             { return new GeneratorConfig(this); }
    }
}
