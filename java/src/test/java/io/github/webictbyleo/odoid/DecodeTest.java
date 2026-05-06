package io.github.webictbyleo.odoid;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.junit.jupiter.params.provider.ValueSource;

import static org.junit.jupiter.api.Assertions.*;

class DecodeTest {

    @ParameterizedTest
    @CsvSource({
        "0, 6", "1, 6", "255, 6", "65535, 6", "1234567, 6",
        "0, 7", "1234567, 7",
        "0, 8", "1234567, 8",
    })
    void roundTrip(long n, int length) {
        assertEquals(n, OdoId.decode(OdoId.encode(n, length)));
    }

    @Test
    void acceptsLowercase() {
        assertEquals(0L, OdoId.decode("0a0000"));
    }

    @Test
    void lowercaseMatchesUppercase() {
        assertEquals(OdoId.decode("0D7NM7"), OdoId.decode("0d7nm7"));
    }

    @ParameterizedTest
    @ValueSource(chars = {'I', 'L', 'O'})
    void excludedCharsThrowInvalidCharacterException(char ch) {
        assertThrows(InvalidCharacterException.class,
            () -> OdoId.decode("0A0" + ch + "00"));
    }

    @Test
    void invalidChar_reportsCorrectPosition() {
        var ex = assertThrows(InvalidCharacterException.class,
            () -> OdoId.decode("0A000O"));
        assertEquals(6, ex.getPosition());
        assertEquals('O', ex.getChar());
    }

    @Test
    void invalidCharExceptionIsIllegalArgumentException() {
        assertThrows(IllegalArgumentException.class,
            () -> OdoId.decode("0A000O"));
    }

    @Test
    void specialCharThrowsInvalidCharacterException() {
        assertThrows(InvalidCharacterException.class,
            () -> OdoId.decode("0A00-0"));
    }

    @ParameterizedTest
    @ValueSource(strings = {"0A000", "0A000000000"})
    void unsupportedLength_throwsUnsupportedLengthException(String id) {
        assertThrows(UnsupportedLengthException.class, () -> OdoId.decode(id));
    }

    @Test
    void emptyString_throwsIllegalArgumentException() {
        assertThrows(IllegalArgumentException.class, () -> OdoId.decode(""));
    }

    @Test
    void nullString_throwsIllegalArgumentException() {
        assertThrows(IllegalArgumentException.class, () -> OdoId.decode(null));
    }
}
