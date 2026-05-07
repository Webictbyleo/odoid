/// OdoID error types.
library;

/// Thrown when [n] >= MAX[length] for the chosen OdoID length.
final class OdoOverflowException implements Exception {
  /// The raw integer value that exceeded capacity.
  final int n;

  /// The OdoID length (6, 7, or 8) associated with the overflow.
  final int length;

  /// Creates a new [OdoOverflowException] instance.
  OdoOverflowException(this.n, this.length);

  @override
  String toString() {
    final max = {6: 230686720, 7: 7381975040, 8: 236223201280}[length];
    return 'OdoOverflowException: n=$n is out of range for length $length. '
        'Valid range: 0 <= n < $max';
  }
}

/// Thrown when a length other than 6, 7, or 8 is requested.
final class UnsupportedLengthException implements Exception {
  /// The unsupported length that was requested.
  final int length;

  /// Creates a new [UnsupportedLengthException] instance with the given [length].
  UnsupportedLengthException(this.length);

  @override
  String toString() =>
      'UnsupportedLengthException: Unsupported OdoID length: $length. '
      'Must be 6, 7, or 8.';
}

/// Thrown when a character absent from the positional charset is encountered
/// during decoding.
final class InvalidCharacterException implements Exception {
  /// The invalid character encountered.
  final String char;

  /// The 1-indexed position in the input string where [char] was found.
  final int position;

  /// Creates a new [InvalidCharacterException] instance.
  InvalidCharacterException(this.char, this.position);

  @override
  String toString() =>
      "InvalidCharacterException: Invalid OdoID character '$char' "
      'at position $position.';
}
