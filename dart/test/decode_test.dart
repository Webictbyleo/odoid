import 'package:odoid/odoid.dart';
import 'package:test/test.dart';

void main() {
  group('Decode', () {
    final roundTrips = [
      (0, 6), (1, 6), (255, 6), (65535, 6), (1234567, 6),
      (0, 7), (1234567, 7),
      (0, 8), (1234567, 8),
    ];
    for (final (n, length) in roundTrips) {
      test('round-trip encode/decode ($n, $length)', () {
        expect(OdoId.decode(OdoId.encode(n, length)), equals(n));
      });
    }

    test('accepts lowercase input', () {
      expect(OdoId.decode('0a0000'), equals(0));
    });

    test('lowercase and uppercase produce same result', () {
      expect(OdoId.decode('0d7nm7'), equals(OdoId.decode('0D7NM7')));
    });

    for (final ch in ['I', 'L', 'O']) {
      test('excluded char "$ch" throws InvalidCharacterException', () {
        expect(() => OdoId.decode('0A0${ch}00'),
            throwsA(isA<InvalidCharacterException>()));
      });
    }

    test('InvalidCharacterException reports correct position and char', () {
      try {
        OdoId.decode('0A000O');
        fail('expected InvalidCharacterException');
      } on InvalidCharacterException catch (e) {
        expect(e.char, equals('O'));
        expect(e.position, equals(6));
      }
    });

    test('special character "-" throws InvalidCharacterException', () {
      expect(() => OdoId.decode('0A00-0'),
          throwsA(isA<InvalidCharacterException>()));
    });

    for (final id in ['0A000', '0A000000000']) {
      test('unsupported length id "$id" throws UnsupportedLengthException', () {
        expect(() => OdoId.decode(id),
            throwsA(isA<UnsupportedLengthException>()));
      });
    }

    test('empty string throws ArgumentError', () {
      expect(() => OdoId.decode(''), throwsA(isA<ArgumentError>()));
    });
  });
}
