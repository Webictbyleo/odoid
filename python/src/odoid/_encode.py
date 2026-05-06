"""OdoID encoding — integer to string."""

from ._charsets import MAX, SUPPORTED_LENGTHS, get_charset
from ._errors import OverflowError, UnsupportedLengthError


def assert_length(length: int) -> None:
    """Raise :exc:`UnsupportedLengthError` if *length* is not 6, 7, or 8."""
    if length not in SUPPORTED_LENGTHS:
        raise UnsupportedLengthError(length)


def encode(n: int, length: int = 6) -> str:
    """
    Encode a non-negative integer *n* into an OdoID string of the given *length*.

    :param n:      The integer to encode. Must satisfy ``0 <= n < MAX[length]``.
    :param length: Target string length: 6 (default), 7, or 8.
    :returns:      The encoded OdoID string (uppercase).

    :raises UnsupportedLengthError: if *length* is not 6, 7, or 8.
    :raises OverflowError:          if *n* < 0 or *n* >= ``MAX[length]``.
    """
    assert_length(length)

    n = int(n)

    if n < 0 or n >= MAX[length]:
        raise OverflowError(
            f"n={n} is out of range for length {length}. "
            f"Valid range: 0 <= n < {MAX[length]}."
        )

    out = [""] * length

    for i in range(length - 1, -1, -1):
        charset = get_charset(i)
        base = len(charset)
        out[i] = charset[n % base]
        n //= base

    return "".join(out)
