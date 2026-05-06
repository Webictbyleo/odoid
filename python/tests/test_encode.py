import pytest
from odoid import ALPHA, MAX, OverflowError, UnsupportedLengthError, encode


class TestEncodeInputTypes:
    def test_accepts_int(self):
        assert encode(0, 6) == "0A0000"

    def test_accepts_float_truncated(self):
        # int(1234567.9) == 1234567
        assert encode(int(1234567.9), 6) == encode(1234567, 6)

    def test_default_length_is_6(self):
        assert len(encode(0)) == 6
        assert encode(0) == "0A0000"


class TestEncodeOutputProperties:
    def test_output_is_uppercase(self):
        for n in [0, 1, 100, 999999, 1234567]:
            assert encode(n, 6) == encode(n, 6).upper()

    def test_output_length_matches_requested(self):
        assert len(encode(0, 6)) == 6
        assert len(encode(0, 7)) == 7
        assert len(encode(0, 8)) == 8

    def test_position_1_is_always_alpha(self):
        for n in [0, 1, 100, 1234567]:
            assert encode(n, 6)[1] in ALPHA

    def test_position_2_is_always_digit(self):
        for n in [0, 1, 100, 1234567]:
            assert encode(n, 6)[2].isdigit()

    def test_excluded_chars_never_appear(self):
        samples = [0, 1, 1000, 1234567, 100_000_000, MAX[8] - 1]
        for n in samples:
            id_str = encode(n, 8)
            assert "I" not in id_str
            assert "L" not in id_str
            assert "O" not in id_str


class TestEncodeBoundaryValues:
    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_encode_zero_valid(self, length):
        assert encode(0, length) is not None

    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_encode_max_minus_1_valid(self, length):
        assert encode(MAX[length] - 1, length) is not None


class TestEncodeOverflow:
    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_overflow_at_max(self, length):
        with pytest.raises(OverflowError):
            encode(MAX[length], length)

    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_overflow_negative(self, length):
        with pytest.raises(OverflowError):
            encode(-1, length)

    def test_overflow_error_message_contains_value(self):
        with pytest.raises(OverflowError, match=str(MAX[6])):
            encode(MAX[6], 6)

    def test_overflow_is_value_error(self):
        with pytest.raises(ValueError):
            encode(MAX[6], 6)


class TestEncodeUnsupportedLength:
    @pytest.mark.parametrize("length", [0, 1, 5, 9, 100])
    def test_unsupported_lengths(self, length):
        with pytest.raises(UnsupportedLengthError):
            encode(0, length)

    def test_unsupported_is_value_error(self):
        with pytest.raises(ValueError):
            encode(0, 5)
