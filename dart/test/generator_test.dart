import 'package:odoid/odoid.dart';
import 'package:test/test.dart';

void main() {
  group('OdoIDGenerator', () {
    test('default namespace is "default" and length is 6', () {
      final g = OdoIDGenerator();
      expect(g.namespace, equals('default'));
      expect(g.length, equals(6));
    });

    test('custom namespace and length are stored', () {
      final g = OdoIDGenerator(namespace: 'acme', length: 8);
      expect(g.namespace, equals('acme'));
      expect(g.length, equals(8));
    });

    for (final length in [6, 7, 8]) {
      test('capacity matches kMax[$length]', () {
        expect(OdoIDGenerator(length: length).capacity, equals(kMax[length]));
      });

      test('next() result id has correct length ($length)', () {
        expect(OdoIDGenerator(length: length).next().id.length, equals(length));
      });

      test('nextN() is in [0, capacity) for length $length', () {
        final g = OdoIDGenerator(length: length);
        for (var i = 0; i < 50; i++) {
          final n = g.nextN();
          expect(n, greaterThanOrEqualTo(0));
          expect(n, lessThan(g.capacity));
        }
      });
    }

    test('unsupported length throws UnsupportedLengthException', () {
      expect(() => OdoIDGenerator(length: 5),
          throwsA(isA<UnsupportedLengthException>()));
    });

    test('next() result has correct shape', () {
      final g = OdoIDGenerator(namespace: 'test', length: 6);
      final r = g.next();
      expect(r.id, isNotEmpty);
      expect(r.n, greaterThanOrEqualTo(0));
      expect(r.length, equals(6));
      expect(r.namespace, equals('test'));
    });

    test('next() id is uppercase alphanumeric', () {
      final g = OdoIDGenerator(length: 8);
      for (var i = 0; i < 50; i++) {
        final id = g.next().id;
        expect(id, equals(id.toUpperCase()),
            reason: 'ID not uppercase: $id');
        expect(RegExp(r'^[A-Z0-9]+$').hasMatch(id), isTrue,
            reason: 'ID contains non-alphanumeric: $id');
      }
    });

    test('excluded chars never appear in output', () {
      final g = OdoIDGenerator(length: 8);
      for (var i = 0; i < 50; i++) {
        final id = g.next().id;
        expect(id.contains('I'), isFalse, reason: '$id contains I');
        expect(id.contains('L'), isFalse, reason: '$id contains L');
        expect(id.contains('O'), isFalse, reason: '$id contains O');
      }
    });

    test('next().n matches decode(next().id)', () {
      final g = OdoIDGenerator(namespace: 'verify', length: 6);
      for (var i = 0; i < 20; i++) {
        final r = g.next();
        expect(OdoId.decode(r.id), equals(r.n));
      }
    });

    test('monotonic sequencing: same-tick produces distinct IDs', () {
      // epoch far in the future keeps tick == 0 for all calls
      final futureEpoch =
          DateTime.now().millisecondsSinceEpoch + 60000;
      final g = OdoIDGenerator(namespace: 'seq-test', epoch: futureEpoch);
      final seen = <String>{};
      for (var i = 0; i < 20; i++) {
        final id = g.next().id;
        expect(seen.contains(id), isFalse, reason: 'Duplicate ID: $id');
        seen.add(id);
      }
    });

    test('namespace isolation: different namespaces produce different IDs', () {
      final futureEpoch =
          DateTime.now().millisecondsSinceEpoch + 60000;
      final g1 = OdoIDGenerator(namespace: 'ns-a', length: 8, epoch: futureEpoch);
      final g2 = OdoIDGenerator(namespace: 'ns-b', length: 8, epoch: futureEpoch);
      expect(g1.next().id, isNot(equals(g2.next().id)));
    });

    test('proxy encode uses generator length', () {
      final g = OdoIDGenerator(length: 7);
      expect(g.encode(0).length, equals(7));
    });

    test('proxy decode returns correct n', () {
      final g = OdoIDGenerator(length: 6);
      final r = g.next();
      expect(g.decode(r.id), equals(r.n));
    });
  });
}
