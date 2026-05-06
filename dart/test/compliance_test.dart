import 'package:odoid/odoid.dart';
import 'package:test/test.dart';

void main() {
  group('Compliance — SPEC.md § 8', () {
    // § 8.1 Encode vectors
    group('encode', () {
      final vectors = [
        (0, 6, '0A0000'),
        (1234567, 6, '0D7NM7'),
        (1234567, 7, '0A15NM7'),
        (236223201279, 8, 'ZZ9ZZZZZ'),
        (230686719, 6, 'ZZ9ZZZ'),
      ];
      for (final (n, length, expected) in vectors) {
        test('encode($n, $length) == "$expected"', () {
          expect(OdoId.encode(n, length), equals(expected));
        });
      }
    });

    // § 8.2 Decode vectors
    group('decode', () {
      final vectors = [
        ('0A0000', 0),
        ('0D7NM7', 1234567),
        ('0A15NM7', 1234567),
        ('ZZ9ZZZZZ', 236223201279),
        ('ZZ9ZZZ', 230686719),
      ];
      for (final (id, expected) in vectors) {
        test('decode("$id") == $expected', () {
          expect(OdoId.decode(id), equals(expected));
        });
      }
    });

    // § 8.3 Error cases
    test('encode throws OdoOverflowException when n == MAX[6]', () {
      expect(() => OdoId.encode(kMax[6]!, 6),
          throwsA(isA<OdoOverflowException>()));
    });

    test('encode throws UnsupportedLengthException for length 5', () {
      expect(() => OdoId.encode(0, 5),
          throwsA(isA<UnsupportedLengthException>()));
    });

    test('decode throws InvalidCharacterException for "O" at position 6', () {
      expect(
        () => OdoId.decode('0A000O'),
        throwsA(
          isA<InvalidCharacterException>()
              .having((e) => e.char, 'char', 'O')
              .having((e) => e.position, 'position', 6),
        ),
      );
    });

    test('decode throws InvalidCharacterException for "I" at position 6', () {
      expect(() => OdoId.decode('0A000I'),
          throwsA(isA<InvalidCharacterException>()));
    });

    test('decode throws InvalidCharacterException for lowercase "l" (maps to L)',
        () {
      expect(() => OdoId.decode('0A000l'),
          throwsA(isA<InvalidCharacterException>()));
    });

    test('decode throws ArgumentError for empty string', () {
      expect(() => OdoId.decode(''), throwsA(isA<ArgumentError>()));
    });
  });
}
