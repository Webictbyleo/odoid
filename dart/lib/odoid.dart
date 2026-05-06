/// OdoID — Deterministic mixed-radix ID encoding.
///
/// Maps a non-negative integer to a 6, 7, or 8-character alphanumeric string
/// with a serial-number aesthetic. Ambiguous characters I, L, and O are
/// excluded from all positions.
///
/// ```dart
/// import 'package:odoid/odoid.dart';
///
/// OdoId.encode(0, 6);            // "0A0000"
/// OdoId.encode(1234567, 6);      // "0D7NM7"
/// OdoId.encode(1234567, 7);      // "0A15NM7"
/// OdoId.encode(236223201279, 8); // "ZZ9ZZZZZ"
///
/// OdoId.decode("0D7NM7");        // 1234567
/// ```
library odoid;

export 'src/charsets.dart';
export 'src/errors.dart';
export 'src/odoid.dart';
export 'src/generator.dart';
