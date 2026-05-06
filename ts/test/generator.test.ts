import { describe, test, expect } from "vitest";
import { OdoIDGenerator, UnsupportedLengthError, decode, MAX } from "../src/index.js";

describe("OdoIDGenerator", () => {
  describe("construction", () => {
    test("creates with default options", () => {
      const g = new OdoIDGenerator();
      expect(g.namespace).toBe("default");
      expect(g.length).toBe(6);
    });

    test("creates with custom namespace and length", () => {
      const g = new OdoIDGenerator({ namespace: "acme", length: 8 });
      expect(g.namespace).toBe("acme");
      expect(g.length).toBe(8);
    });

    test("capacity matches MAX for the configured length", () => {
      expect(new OdoIDGenerator({ length: 6 }).capacity).toBe(MAX[6]);
      expect(new OdoIDGenerator({ length: 7 }).capacity).toBe(MAX[7]);
      expect(new OdoIDGenerator({ length: 8 }).capacity).toBe(MAX[8]);
    });

    test("unsupported length throws UnsupportedLengthError", () => {
      // @ts-expect-error intentionally unsupported length
      expect(() => new OdoIDGenerator({ length: 5 })).toThrowError(UnsupportedLengthError);
    });
  });

  describe("next()", () => {
    test("result has correct shape", () => {
      const g = new OdoIDGenerator({ namespace: "test", length: 6 });
      const result = g.next();
      expect(result).toHaveProperty("id");
      expect(result).toHaveProperty("n");
      expect(result).toHaveProperty("length");
      expect(result).toHaveProperty("namespace");
    });

    test("id has the correct length", () => {
      for (const length of [6, 7, 8] as const) {
        const g = new OdoIDGenerator({ length });
        expect(g.next().id).toHaveLength(length);
      }
    });

    test("id is uppercase alphanumeric with no excluded chars", () => {
      const g = new OdoIDGenerator({ length: 8 });
      for (let i = 0; i < 50; i++) {
        expect(g.next().id).toMatch(/^[0-9A-Z]{8}$/);
        expect(g.next().id).not.toMatch(/[ILO]/);
      }
    });

    test("n is always in [0, capacity)", () => {
      const g = new OdoIDGenerator({ length: 7 });
      for (let i = 0; i < 50; i++) {
        const { n } = g.next();
        expect(n).toBeGreaterThanOrEqual(0n);
        expect(n).toBeLessThan(MAX[7]);
      }
    });

    test("n matches decode(id)", () => {
      const g = new OdoIDGenerator({ namespace: "verify", length: 6 });
      for (let i = 0; i < 20; i++) {
        const { id, n } = g.next();
        expect(decode(id)).toBe(n);
      }
    });

    test("namespace and length fields match generator config", () => {
      const g = new OdoIDGenerator({ namespace: "ns1", length: 7 });
      const result = g.next();
      expect(result.namespace).toBe("ns1");
      expect(result.length).toBe(7);
    });
  });

  describe("encode() and decode() proxy methods", () => {
    test("generator.encode() uses the generator's length", () => {
      const g = new OdoIDGenerator({ length: 7 });
      expect(g.encode(0n)).toHaveLength(7);
    });

    test("generator.decode() returns the original n", () => {
      const g = new OdoIDGenerator({ length: 6 });
      const { id, n } = g.next();
      expect(g.decode(id)).toBe(n);
    });
  });

  describe("monotonic sequencing within a tick", () => {
    test("same-tick calls increment sequence and produce distinct IDs", () => {
      const epoch = Date.now() + 60_000; // future epoch — tick stays 0
      const g = new OdoIDGenerator({ namespace: "seq-test", epoch });

      const ids = new Set<string>();
      for (let i = 0; i < 20; i++) {
        ids.add(g.next().id);
      }

      // All IDs produced at the same tick (0) should be distinct
      expect(ids.size).toBe(20);
    });
  });

  describe("namespace isolation", () => {
    test("generators with different namespaces produce different IDs for the same tick", () => {
      const epoch = Date.now() + 60_000;
      const g1 = new OdoIDGenerator({ namespace: "ns-a", length: 8, epoch });
      const g2 = new OdoIDGenerator({ namespace: "ns-b", length: 8, epoch });

      const id1 = g1.next().id;
      const id2 = g2.next().id;

      expect(id1).not.toBe(id2);
    });
  });
});
