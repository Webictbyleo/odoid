package io.github.webictbyleo.odoid;

/**
 * Provides encoding and decoding of OdoID strings.
 *
 * <pre>{@code
 * OdoId.encode(0, 6)            // "0A0000"
 * OdoId.encode(1234567, 6)      // "0D7NM7"
 * OdoId.encode(1234567, 7)      // "0A15NM7"
 * OdoId.encode(236223201279L, 8) // "ZZ9ZZZZZ"
 *
 * OdoId.decode("0D7NM7")        // 1234567L
 * }</pre>
 */
public final class OdoId {

    private OdoId() {}

    /**
     * Validates that {@code length} is a supported OdoID length (6, 7, or 8).
     *
     * @throws UnsupportedLengthException if {@code length} is not 6, 7, or 8.
     */
    public static void assertLength(int length) {
        if (length != 6 && length != 7 && length != 8) {
            throw new UnsupportedLengthException(length);
        }
    }

    /**
     * Encodes a non-negative integer {@code n} into an OdoID string of the
     * given {@code length}.
     *
     * @param n      the integer to encode; must satisfy {@code 0 <= n < MAX[length]}.
     * @param length target string length: 6, 7, or 8.
     * @return the encoded OdoID string (uppercase).
     * @throws UnsupportedLengthException if {@code length} is not 6, 7, or 8.
     * @throws OdoOverflowException       if {@code n >= MAX[length]}.
     */
    public static String encode(long n, int length) {
        assertLength(length);
        if (n < 0 || n >= Charsets.MAX.get(length)) {
            throw new OdoOverflowException(n, length);
        }

        char[] buf = new char[length];
        for (int i = length - 1; i >= 0; i--) {
            String charset = Charsets.getCharset(i);
            int base = charset.length();
            buf[i] = charset.charAt((int) (n % base));
            n /= base;
        }
        return new String(buf);
    }

    /**
     * Decodes an OdoID string back to its originating integer.
     *
     * <p>The input is uppercased before lookup, so lowercase letters that are
     * valid in the charset (e.g. {@code "0a0000"}) are accepted. The excluded
     * characters {@code I}, {@code L}, and {@code O} remain invalid.
     *
     * @param id the OdoID string to decode (6, 7, or 8 characters).
     * @return the decoded non-negative integer.
     * @throws IllegalArgumentException   if {@code id} is null or empty.
     * @throws UnsupportedLengthException if {@code id.length()} is not 6, 7, or 8.
     * @throws InvalidCharacterException  if any character is absent from its positional charset.
     */
    public static long decode(String id) {
        if (id == null || id.isEmpty()) {
            throw new IllegalArgumentException("OdoID must be a non-empty string.");
        }

        String upper = id.toUpperCase();
        assertLength(upper.length());

        long n = 0;
        for (int i = 0; i < upper.length(); i++) {
            String charset = Charsets.getCharset(i);
            int base = charset.length();
            int v = charset.indexOf(upper.charAt(i));
            if (v < 0) {
                throw new InvalidCharacterException(upper.charAt(i), i + 1);
            }
            n = n * base + v;
        }
        return n;
    }
}
