package io.github.webictbyleo.odoid;

/**
 * Thrown when a character absent from the positional charset is encountered
 * during decoding.
 */
public final class InvalidCharacterException extends IllegalArgumentException {

    private final char ch;
    private final int position;

    public InvalidCharacterException(char ch, int position) {
        super(String.format("Invalid OdoID character '%c' at position %d.", ch, position));
        this.ch = ch;
        this.position = position;
    }

    /** The offending character. */
    public char getChar() { return ch; }

    /** The 1-based position of the offending character. */
    public int getPosition() { return position; }
}
