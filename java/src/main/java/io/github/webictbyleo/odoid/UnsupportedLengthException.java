package io.github.webictbyleo.odoid;

/**
 * Thrown when a length other than 6, 7, or 8 is requested.
 */
public final class UnsupportedLengthException extends IllegalArgumentException {

    private final int length;

    public UnsupportedLengthException(int length) {
        super(String.format("Unsupported OdoID length: %d. Must be 6, 7, or 8.", length));
        this.length = length;
    }

    /** The unsupported length that was provided. */
    public int getLength() { return length; }
}
