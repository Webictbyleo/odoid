"""
OdoID — Deterministic mixed-radix ID encoding.

Maps a non-negative integer to a 6, 7, or 8-character alphanumeric string
with a serial-number aesthetic. All ambiguous characters (I, L, O) are excluded.

Basic usage::

    from odoid import encode, decode, OdoIDGenerator

    encode(1234567, 6)   # "0D7NM7"
    decode("0D7NM7")     # 1234567

    g = OdoIDGenerator(namespace="orders", length=7)
    result = g.next()    # OdoIDResult(id="...", n=..., length=7, namespace="orders")
"""

from ._charsets import ALL, ALPHA, MAX, NUM, SUPPORTED_LENGTHS, get_charset
from ._decode import decode
from ._encode import assert_length, encode
from ._errors import InvalidCharacterError, OverflowError, UnsupportedLengthError
from ._generator import OdoIDGenerator, OdoIDResult

__all__ = [
    "encode",
    "decode",
    "assert_length",
    "OdoIDGenerator",
    "OdoIDResult",
    "OverflowError",
    "UnsupportedLengthError",
    "InvalidCharacterError",
    "MAX",
    "NUM",
    "ALPHA",
    "ALL",
    "SUPPORTED_LENGTHS",
    "get_charset",
]
