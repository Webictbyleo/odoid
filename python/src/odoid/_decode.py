"""OdoID decoding — string to integer."""

from ._charsets import SUPPORTED_LENGTHS, get_charset
from ._errors import InvalidCharacterError, UnsupportedLengthError


def decode(id_str: str) -> int:
    """
    Decode an OdoID string back to its originating integer.

    The input is uppercased before lookup, so lowercase letters that are valid
    in the charset (e.g. ``"0a0000"``) are accepted. The excluded characters
    ``I``, ``L``, and ``O`` remain invalid even after uppercasing.

    :param id_str: The OdoID string to decode (6, 7, or 8 characters).
    :returns:      The decoded non-negative integer.

    :raises TypeError:              if *id_str* is not a non-empty string.
    :raises UnsupportedLengthError: if ``len(id_str)`` is not 6, 7, or 8.
    :raises InvalidCharacterError:  if any character is absent from its positional charset.
    """
    if not id_str or not isinstance(id_str, str):
        raise TypeError("OdoID must be a non-empty string.")

    upper = id_str.upper()
    length = len(upper)

    if length not in SUPPORTED_LENGTHS:
        raise UnsupportedLengthError(length)

    n = 0

    for i, ch in enumerate(upper):
        charset = get_charset(i)
        v = charset.find(ch)

        if v < 0:
            raise InvalidCharacterError(ch, i + 1)

        n = n * len(charset) + v

    return n
