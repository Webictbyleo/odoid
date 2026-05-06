package io.github.webictbyleo.odoid;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class GeneratorTest {

    @Test
    void defaultConfig_hasCorrectDefaults() {
        var g = new OdoIDGenerator();
        assertEquals("default", g.getNamespace());
        assertEquals(6, g.getLength());
    }

    @Test
    void customConfig_namespaceAndLength() {
        var g = new OdoIDGenerator(GeneratorConfig.builder()
            .namespace("acme").length(8).build());
        assertEquals("acme", g.getNamespace());
        assertEquals(8, g.getLength());
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void capacity_matchesMax(int length) {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(length).build());
        assertEquals(Charsets.MAX.get(length), g.getCapacity());
    }

    @Test
    void unsupportedLength_throwsUnsupportedLengthException() {
        assertThrows(UnsupportedLengthException.class,
            () -> new OdoIDGenerator(GeneratorConfig.builder().length(5).build()));
    }

    @Test
    void next_resultHasCorrectShape() {
        var g = new OdoIDGenerator(GeneratorConfig.builder()
            .namespace("test").length(6).build());
        var r = g.next();
        assertNotNull(r.getId());
        assertFalse(r.getId().isEmpty());
        assertEquals(6, r.getLength());
        assertEquals("test", r.getNamespace());
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void next_idHasCorrectLength(int length) {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(length).build());
        assertEquals(length, g.next().getId().length());
    }

    @Test
    void next_idIsUppercaseAlphanumeric() {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(8).build());
        for (int i = 0; i < 50; i++) {
            String id = g.next().getId();
            assertEquals(id.toUpperCase(), id, "ID not uppercase: " + id);
            assertTrue(id.chars().allMatch(Character::isLetterOrDigit),
                "ID contains non-alphanumeric: " + id);
        }
    }

    @Test
    void next_excludedCharsNeverInOutput() {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(8).build());
        for (int i = 0; i < 50; i++) {
            String id = g.next().getId();
            assertFalse(id.contains("I"), id + " contains I");
            assertFalse(id.contains("L"), id + " contains L");
            assertFalse(id.contains("O"), id + " contains O");
        }
    }

    @ParameterizedTest
    @ValueSource(ints = {6, 7, 8})
    void next_nIsInValidRange(int length) {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(length).build());
        long max = Charsets.MAX.get(length);
        for (int i = 0; i < 50; i++) {
            long n = g.next().getN();
            assertTrue(n >= 0 && n < max, "n=" + n + " out of range for length " + length);
        }
    }

    @Test
    void next_nMatchesDecodeOfId() {
        var g = new OdoIDGenerator(GeneratorConfig.builder()
            .namespace("verify").length(6).build());
        for (int i = 0; i < 20; i++) {
            var r = g.next();
            assertEquals(r.getN(), OdoId.decode(r.getId()));
        }
    }

    @Test
    void monotonicSequencing_sameTickProducesDistinctIds() {
        long futureEpoch = Instant.now().toEpochMilli() + 60_000;
        var g = new OdoIDGenerator(GeneratorConfig.builder()
            .namespace("seq-test").epoch(futureEpoch).build());

        Set<String> ids = new HashSet<>();
        for (int i = 0; i < 20; i++) ids.add(g.next().getId());
        assertEquals(20, ids.size(), "Expected 20 distinct IDs");
    }

    @Test
    void namespaceIsolation_differentNamespacesProduceDifferentIds() {
        long futureEpoch = Instant.now().toEpochMilli() + 60_000;
        var g1 = new OdoIDGenerator(GeneratorConfig.builder()
            .namespace("ns-a").length(8).epoch(futureEpoch).build());
        var g2 = new OdoIDGenerator(GeneratorConfig.builder()
            .namespace("ns-b").length(8).epoch(futureEpoch).build());
        assertNotEquals(g1.next().getId(), g2.next().getId());
    }

    @Test
    void proxyEncode_usesGeneratorLength() {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(7).build());
        assertEquals(7, g.encode(0L).length());
    }

    @Test
    void proxyDecode_returnsCorrectN() {
        var g = new OdoIDGenerator(GeneratorConfig.builder().length(6).build());
        var r = g.next();
        assertEquals(r.getN(), g.decode(r.getId()));
    }
}
