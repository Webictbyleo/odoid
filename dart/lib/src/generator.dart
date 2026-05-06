/// OdoIDGenerator — distributed monotonic ID generator.
library;

import 'charsets.dart';
import 'errors.dart';
import 'odoid.dart';

/// Result returned by [OdoIDGenerator.next].
final class OdoIDResult {
  /// The encoded OdoID string.
  final String id;

  /// The raw integer used to produce [id].
  final int n;

  /// The OdoID length (6, 7, or 8).
  final int length;

  /// The namespace this generator belongs to.
  final String namespace;

  const OdoIDResult({
    required this.id,
    required this.n,
    required this.length,
    required this.namespace,
  });

  @override
  String toString() =>
      'OdoIDResult(id: $id, n: $n, length: $length, namespace: $namespace)';
}

/// A distributed monotonic generator that produces OdoID strings driven by a
/// namespace-scoped, time-seeded pseudo-random integer.
///
/// Guarantees that rapid successive calls within the same millisecond tick
/// produce distinct values via a monotonically incrementing sequence counter.
///
/// ```dart
/// final g = OdoIDGenerator(namespace: 'orders', length: 7);
/// final r = g.next();
/// print(r.id);        // e.g. "3H5NV2K"
/// print(r.n);         // raw integer
/// ```
final class OdoIDGenerator {
  /// Logical partition key for this generator.
  final String namespace;

  /// OdoID output length (6, 7, or 8).
  final int length;

  /// Maximum exclusive value — equal to kMax[length].
  final int capacity;

  final int _epoch;

  int _sequence = 0;
  int _lastTick = -1;

  /// Creates a new [OdoIDGenerator].
  ///
  /// [namespace] defaults to `"default"`, [length] defaults to `6`.
  /// [epoch] is the millisecond origin subtracted from wall-clock time;
  /// defaults to 0 (use raw Unix ms).
  ///
  /// Throws [UnsupportedLengthException] if [length] is not 6, 7, or 8.
  OdoIDGenerator({
    this.namespace = 'default',
    this.length = 6,
    // epoch defaults to 0 to ensure absolute time-based seeding (distributed uniqueness).
    int epoch = 0,
  })  : _epoch = epoch,
        capacity = kMax[length] ?? _assertLength(length) {
    OdoId.assertLength(length);
  }

  int _nowMs() =>
      DateTime.now().millisecondsSinceEpoch - _epoch;

  /// FNV-1a 32-bit hash.
  /// Offset basis = 2166136261, prime = 16777619. Constants are normative.
  static int _fnv1a32(String value) {
    var h = 2166136261;
    for (var i = 0; i < value.length; i++) {
      h ^= value.codeUnitAt(i);
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h;
  }

  /// Returns the next raw integer [n] in `[0, capacity)`.
  int nextN() {
    final tick = _nowMs();

    if (tick == _lastTick) {
      _sequence++;
    } else {
      _sequence = 0;
      _lastTick = tick;
    }

    var seed = _fnv1a32('$namespace|$tick');
    seed ^= (seed << 13) & 0xFFFFFFFF;
    seed ^= (seed >> 7);
    seed ^= (seed << 17) & 0xFFFFFFFF;

    return (seed + _sequence) % capacity;
  }

  /// Generates and returns the next [OdoIDResult].
  OdoIDResult next() {
    final n = nextN();
    return OdoIDResult(
      id: OdoId.encode(n, length),
      n: n,
      length: length,
      namespace: namespace,
    );
  }

  /// Encodes [n] using this generator's configured length.
  String encode(int n) => OdoId.encode(n, length);

  /// Decodes an OdoID string to its originating integer.
  int decode(String id) => OdoId.decode(id);
}

// Helper to satisfy the capacity initialiser — never actually called because
// OdoId.assertLength throws first.
Never _assertLength(int length) =>
    throw UnsupportedLengthException(length);
