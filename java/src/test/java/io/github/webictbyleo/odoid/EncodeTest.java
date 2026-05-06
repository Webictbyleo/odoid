package io.github.webictbyleo.odoid;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.*;

class EncodeTest {

    @Test
    void outputLength6_isDefault() {
        assertEquals(6, OdoId.encode(0, 6).length());
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void outputLengthMatchesRequested(int length) {
        assertEquals(length, OdoId.encode(0, length).length());
    }

    @ParameterizedTest
    @ValueSource(longs = {0, 1, 100, 999999, 1234567})
    void outputIsAlwaysUppercase(long n) {
        String id = OdoId.encode(n, 6);
        assertEquals(id.toUpperCase(), id);
    }

    @ParameterizedTest
    @ValueSource(longs = {0, 1, 100, 1234567})
    void position1IsAlwaysAlphaChar(long n) {
        String id = OdoId.encode(n, 6);
        char ch = id.charAt(1);
        assertTrue(Charsets.ALPHA.indexOf(ch) >= 0,
            "pos 1 = '" + ch + "' not in ALPHA");
    }

    @ParameterizedTest
    @ValueSource(longs = {0, 1, 100, 1234567})
    void position2IsAlwaysDigit(long n) {
        char ch = OdoId.encode(n, 6).charAt(2);
        assertTrue(Character.isDigit(ch), "pos 2 = '" + ch + "' not a digit");
    }

    @ParameterizedTest
    @ValueSource(longs = {0, 1, 1000, 1234567, 100_000_000})
    void excludedCharsNeverAppear(long n) {
        String id = OdoId.encode(n, 8);
        assertFalse(id.contains("I"), id + " contains I");
        assertFalse(id.contains("L"), id + " contains L");
        assertFalse(id.contains("O"), id + " contains O");
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void encodeZeroIsValid(int length) {
        assertDoesNotThrow(() -> OdoId.encode(0, length));
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void encodeMaxMinus1IsValid(int length) {
        assertDoesNotThrow(() -> OdoId.encode(Charsets.MAX.get(length) - 1, length));
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void encodeMax_throwsOdoOverflowException(int length) {
        assertThrows(OdoOverflowException.class,
            () -> OdoId.encode(Charsets.MAX.get(length), length));
    }

    @Test
    void overflowExceptionMessageContainsViolatingValue() {
        var ex = assertThrows(OdoOverflowException.class,
            () -> OdoId.encode(Charsets.MAX.get(6), 6));
        assertTrue(ex.getMessage().contains(String.valueOf(Charsets.MAX.get(6))));
    }

    @Test
    void overflowExceptionIsIllegalArgumentException() {
        assertThrows(IllegalArgumentException.class,
            () -> OdoId.encode(Charsets.MAX.get(6), 6));
    }

    @ParameterizedTest
    @ValueSource(ints = {0, 1, 5, 9, 100})
    void unsupportedLength_throwsUnsupportedLengthException(int length) {
        assertThrows(UnsupportedLengthException.class,
            () -> OdoId.encode(0, length));
    }

    @Test
    void unsupportedLengthExceptionIsIllegalArgumentException() {
        assertThrows(IllegalArgumentException.class,
            () -> OdoId.encode(0, 5));
    }
}
