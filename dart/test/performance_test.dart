import 'package:odoid/odoid.dart';
import 'package:test/test.dart';

/// Performance tests — SPEC.md § 9.
/// Each encode / decode call must average <= 0.1000 ms.
void main() {
  const limitMs = 0.1;
  const warmup = 2000;
  const iterations = 10000;

  void assertAvgMs(String label, void Function() fn) {
    for (var i = 0; i < warmup; i++) {
      fn();
    }
    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      fn();
    }
    sw.stop();
    final avgMs = sw.elapsedMicroseconds / 1000 / iterations;
    expect(
      avgMs,
      lessThanOrEqualTo(limitMs),
      reason:
          '$label: average ${avgMs.toStringAsFixed(4)} ms exceeded spec limit of $limitMs ms',
    );
  }

  group('Performance — SPEC.md § 9', () {
    test('encode length 6 averages below $limitMs ms', () {
      var n = 0;
      assertAvgMs('encode/6', () {
        n = (n + 1) % kMax[6]!;
        OdoId.encode(n, 6);
      });
    });

    test('encode length 7 averages below $limitMs ms', () {
      var n = 0;
      assertAvgMs('encode/7', () {
        n = (n + 1) % kMax[7]!;
        OdoId.encode(n, 7);
      });
    });

    test('encode length 8 averages below $limitMs ms', () {
      var n = 0;
      assertAvgMs('encode/8', () {
        n = (n + 1) % kMax[8]!;
        OdoId.encode(n, 8);
      });
    });

    test('decode length 6 averages below $limitMs ms', () {
      final ids = ['0A0000', '0D7NM7', 'ZZ9ZZZ', '1B3C4D', 'AB0000'];
      var i = 0;
      assertAvgMs('decode/6', () => OdoId.decode(ids[i++ % ids.length]));
    });

    test('decode length 7 averages below $limitMs ms', () {
      final ids = ['0A00000', '0A15NM7', 'ZZ9ZZZZ', '1B3C4D5', 'AB00000'];
      var i = 0;
      assertAvgMs('decode/7', () => OdoId.decode(ids[i++ % ids.length]));
    });

    test('decode length 8 averages below $limitMs ms', () {
      final ids = ['0A000000', 'ZZ9ZZZZZ', '1B3C4D5E', 'AB000000'];
      var i = 0;
      assertAvgMs('decode/8', () => OdoId.decode(ids[i++ % ids.length]));
    });
  });
}
