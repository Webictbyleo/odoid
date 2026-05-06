package io.github.webictbyleo.odoid;

/**
 * Thrown when {@code n >= MAX[length]} for the chosen OdoID length.
 */
public final class OdoOverflowException extends IllegalArgumentException {

    private final long n;
    private final int length;

    public OdoOverflowException(long n, int length) {
        super(String.format(
            "n=%d is out of range for length %d. Valid range: 0 <= n < %d",
            n, length, Charsets.MAX.get(length)
        ));
        this.n = n;
        this.length = length;
    }

    /** The value that was out of range. */
    public long getN() { return n; }

    /** The requested OdoID length. */
    public int getLength() { return length; }
}
