"""
Compliance test vectors as defined in SPEC.md § 8.
Every compliant implementation MUST pass these tests unchanged.
"""

import pytest
from odoid import MAX, InvalidCharacterError, OverflowError, UnsupportedLengthError, decode, encode


class TestEncode:
    """§ 8.1 Encode compliance vectors."""

    def test_encode_0_length6(self):
        assert encode(0, 6) == "0A0000"

    def test_encode_1234567_length6(self):
        assert encode(1234567, 6) == "0D7NM7"

    def test_encode_1234567_length7(self):
        assert encode(1234567, 7) == "0A15NM7"

    def test_encode_236223201279_length8(self):
        assert encode(236223201279, 8) == "ZZ9ZZZZZ"

    def test_encode_max_minus1_length6(self):
        """Maximum valid value for length 6."""
        assert encode(230_686_719, 6) == "ZZ9ZZZ"


class TestDecode:
    """§ 8.2 Decode round-trip compliance vectors."""

    @pytest.mark.parametrize("id_str,expected", [
        ("0A0000", 0),
        ("0D7NM7", 1234567),
        ("0A15NM7", 1234567),
        ("ZZ9ZZZZZ", 236223201279),
        ("ZZ9ZZZ", 230_686_719),
    ])
    def test_round_trip(self, id_str, expected):
        assert decode(id_str) == expected


class TestErrorCases:
    """§ 8.3 Error case compliance."""

    def test_encode_overflow_equals_max(self):
        """encode(MAX[6], 6) — equals MAX[6] — must raise OverflowError."""
        with pytest.raises(OverflowError):
            encode(MAX[6], 6)

    def test_encode_overflow_negative(self):
        with pytest.raises(OverflowError):
            encode(-1, 6)

    def test_encode_unsupported_length(self):
        with pytest.raises(UnsupportedLengthError):
            encode(0, 5)

    def test_decode_contains_O(self):
        """decode('0A000O') — contains 'O' — must raise InvalidCharacterError at position 6."""
        with pytest.raises(InvalidCharacterError) as exc_info:
            decode("0A000O")
        assert exc_info.value.position == 6
        assert exc_info.value.char == "O"

    def test_decode_contains_I(self):
        with pytest.raises(InvalidCharacterError) as exc_info:
            decode("0A000I")
        assert exc_info.value.position == 6

    def test_decode_contains_lowercase_l(self):
        """Lowercase 'l' uppercases to 'L' which is excluded — must raise InvalidCharacterError."""
        with pytest.raises(InvalidCharacterError):
            decode("0A000l")

    def test_decode_empty_string(self):
        with pytest.raises(TypeError):
            decode("")
