package io.github.webictbyleo.odoid;

import java.util.Map;

/**
 * OdoID character set definitions.
 *
 * <p>These exact strings MUST be reproduced verbatim in every compliant implementation.
 */
public final class Charsets {

    private Charsets() {}

    /** Numeric characters — radix 10. */
    public static final String NUM = "0123456789";

    /** Alpha characters (ambiguous chars I, L, O excluded) — radix 22. */
    public static final String ALPHA = "ABCDEFGHJKMNPQRSTVWXYZ";

    /** Full hybrid set — NUM concatenated with ALPHA — radix 32. */
    public static final String ALL = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

    /**
     * Maximum exclusive value for each supported length.
     * Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
     */
    public static final Map<Integer, Long> MAX = Map.of(
        6, 230_686_720L,
        7, 7_381_975_040L,
        8, 236_223_201_280L
    );

    /**
     * Returns the character set string for the given 0-based position index.
     *
     * <pre>
     * Index  Charset  Radix
     *   0    ALL      32
     *   1    ALPHA    22
     *   2    NUM      10
     *   3+   ALL      32
     * </pre>
     */
    static String getCharset(int position) {
        return switch (position) {
            case 1  -> ALPHA;
            case 2  -> NUM;
            default -> ALL;
        };
    }
}
