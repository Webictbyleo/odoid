/// Core OdoID encode / decode implementation.
library;

import 'charsets.dart';
import 'errors.dart';

/// Provides encoding and decoding of OdoID strings.
///
/// ```dart
/// OdoId.encode(0, 6);            // "0A0000"
/// OdoId.encode(1234567, 6);      // "0D7NM7"
/// OdoId.encode(1234567, 7);      // "0A15NM7"
/// OdoId.encode(236223201279, 8); // "ZZ9ZZZZZ"
/// OdoId.decode("0D7NM7");        // 1234567
/// ```
final class OdoId {
  OdoId._();

  /// Validates that [length] is a supported OdoID length (6, 7, or 8).
  ///
  /// Throws [UnsupportedLengthException] otherwise.
  static void assertLength(int length) {
    if (length != 6 && length != 7 && length != 8) {
      throw UnsupportedLengthException(length);
    }
  }

  /// Encodes a non-negative integer [n] into an OdoID string of [length] chars.
  ///
  /// [length] must be 6 (default), 7, or 8.
  /// [n] must satisfy `0 <= n < kMax[length]`.
  ///
  /// Throws [UnsupportedLengthException] if [length] is not 6, 7, or 8.
  /// Throws [OdoOverflowException] if [n] is negative or >= kMax[length].
  static String encode(int n, [int length = 6]) {
    assertLength(length);
    if (n < 0 || n >= kMax[length]!) {
      throw OdoOverflowException(n, length);
    }

    final buf = List<String>.filled(length, '');
    for (var i = length - 1; i >= 0; i--) {
      final cs = charsetAt(i);
      buf[i] = cs[n % cs.length];
      n ~/= cs.length;
    }
    return buf.join();
  }

  /// Decodes an OdoID string back to its originating integer.
  ///
  /// Input is uppercased before lookup — lowercase letters that exist in the
  /// charset (e.g. `"0d7nm7"`) are accepted. The excluded characters I, L, O
  /// remain invalid even after uppercasing.
  ///
  /// Throws [ArgumentError] if [id] is empty.
  /// Throws [UnsupportedLengthException] if `id.length` is not 6, 7, or 8.
  /// Throws [InvalidCharacterException] for any character not in its positional charset.
  static int decode(String id) {
    if (id.isEmpty) {
      throw ArgumentError('OdoID must be a non-empty string.');
    }

    final upper = id.toUpperCase();
    assertLength(upper.length);

    var n = 0;
    for (var i = 0; i < upper.length; i++) {
      final cs = charsetAt(i);
      final v = cs.indexOf(upper[i]);
      if (v < 0) {
        throw InvalidCharacterException(upper[i], i + 1);
      }
      n = n * cs.length + v;
    }
    return n;
  }
}
