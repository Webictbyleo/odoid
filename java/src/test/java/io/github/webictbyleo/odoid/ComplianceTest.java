package io.github.webictbyleo.odoid;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Compliance test vectors as defined in SPEC.md § 8.
 * Every compliant implementation MUST pass these tests unchanged.
 */
class ComplianceTest {

    // ── § 8.1 Encode ──────────────────────────────────────────────────────────

    @ParameterizedTest
    @CsvSource({
        "0,            6, 0A0000",
        "1234567,      6, 0D7NM7",
        "1234567,      7, 0A15NM7",
        "236223201279, 8, ZZ9ZZZZZ",
        "230686719,    6, ZZ9ZZZ",
    })
    void encode_specVectors(long n, int length, String expected) {
        assertEquals(expected, OdoId.encode(n, length));
    }

    // ── § 8.2 Decode round-trips ──────────────────────────────────────────────

    @ParameterizedTest
    @CsvSource({
        "0A0000,   0",
        "0D7NM7,   1234567",
        "0A15NM7,  1234567",
        "ZZ9ZZZZZ, 236223201279",
        "ZZ9ZZZ,   230686719",
    })
    void decode_specVectors(String id, long expected) {
        assertEquals(expected, OdoId.decode(id));
    }

    // ── § 8.3 Error cases ─────────────────────────────────────────────────────

    @Test
    void encode_throwsOverflow_whenNEqualsMax6() {
        assertThrows(OdoOverflowException.class,
            () -> OdoId.encode(Charsets.MAX.get(6), 6));
    }

    @Test
    void encode_throwsUnsupportedLength_whenLength5() {
        assertThrows(UnsupportedLengthException.class,
            () -> OdoId.encode(0, 5));
    }

    @Test
    void decode_throwsInvalidCharacter_containsO_atPosition6() {
        var ex = assertThrows(InvalidCharacterException.class,
            () -> OdoId.decode("0A000O"));
        assertEquals(6, ex.getPosition());
        assertEquals('O', ex.getChar());
    }

    @Test
    void decode_throwsInvalidCharacter_containsI_atPosition6() {
        var ex = assertThrows(InvalidCharacterException.class,
            () -> OdoId.decode("0A000I"));
        assertEquals(6, ex.getPosition());
    }

    @Test
    void decode_throwsInvalidCharacter_lowercaseLBecomesExcluded() {
        assertThrows(InvalidCharacterException.class,
            () -> OdoId.decode("0A000l"));
    }

    @Test
    void decode_throwsIllegalArgument_whenEmpty() {
        assertThrows(IllegalArgumentException.class,
            () -> OdoId.decode(""));
    }
}
