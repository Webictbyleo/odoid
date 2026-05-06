import 'package:odoid/odoid.dart';
import 'package:test/test.dart';

void main() {
  group('Encode', () {
    test('default length is 6', () {
      expect(OdoId.encode(0), equals('0A0000'));
      expect(OdoId.encode(0).length, equals(6));
    });

    for (final length in [6, 7, 8]) {
      test('output length matches requested ($length)', () {
        expect(OdoId.encode(0, length).length, equals(length));
      });

      test('encode(0, $length) is valid', () {
        expect(() => OdoId.encode(0, length), returnsNormally);
      });

      test('encode(MAX[$length]-1, $length) is valid', () {
        expect(() => OdoId.encode(kMax[length]! - 1, length), returnsNormally);
      });

      test('encode(MAX[$length], $length) throws OdoOverflowException', () {
        expect(() => OdoId.encode(kMax[length]!, length),
            throwsA(isA<OdoOverflowException>()));
      });
    }

    final samples = [0, 1, 100, 999999, 1234567];
    for (final n in samples) {
      test('output is uppercase for n=$n', () {
        final id = OdoId.encode(n, 6);
        expect(id, equals(id.toUpperCase()));
      });

      test('position 1 is always ALPHA char for n=$n', () {
        final ch = OdoId.encode(n, 6)[1];
        expect(kAlpha.contains(ch), isTrue,
            reason: 'pos 1 = "$ch" not in ALPHA');
      });

      test('position 2 is always a digit for n=$n', () {
        final ch = OdoId.encode(n, 6)[2];
        expect(RegExp(r'\d').hasMatch(ch), isTrue,
            reason: 'pos 2 = "$ch" not a digit');
      });
    }

    for (final n in [0, 1, 1000, 1234567, 100000000]) {
      test('excluded chars never appear for n=$n (length 8)', () {
        final id = OdoId.encode(n, 8);
        expect(id.contains('I'), isFalse, reason: '$id contains I');
        expect(id.contains('L'), isFalse, reason: '$id contains L');
        expect(id.contains('O'), isFalse, reason: '$id contains O');
      });
    }

    for (final length in [0, 1, 5, 9, 100]) {
      test('unsupported length $length throws UnsupportedLengthException', () {
        expect(() => OdoId.encode(0, length),
            throwsA(isA<UnsupportedLengthException>()));
      });
    }

    test('OdoOverflowException message contains violating value', () {
      try {
        OdoId.encode(kMax[6]!, 6);
        fail('expected OdoOverflowException');
      } on OdoOverflowException catch (e) {
        expect(e.toString(), contains(kMax[6]!.toString()));
      }
    });
  });
}
