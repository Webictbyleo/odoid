import pytest
from odoid import MAX, InvalidCharacterError, UnsupportedLengthError, decode, encode


class TestDecodeRoundTrips:
    @pytest.mark.parametrize("length", [6, 7, 8])
    @pytest.mark.parametrize("n", [0, 1, 255, 65535, 1234567])
    def test_round_trip(self, n, length):
        if n < MAX[length]:
            assert decode(encode(n, length)) == n


class TestDecodeCaseInsensitivity:
    def test_lowercase_accepted(self):
        assert decode("0a0000") == 0

    def test_mixed_case_matches_upper(self):
        assert decode("0d7nm7") == decode("0D7NM7")


class TestDecodeReturnType:
    def test_returns_int(self):
        result = decode("0A0000")
        assert isinstance(result, int)


class TestDecodeInvalidCharacters:
    @pytest.mark.parametrize("ch", ["I", "L", "O"])
    def test_excluded_chars_rejected(self, ch):
        id_str = f"0A0{ch}00"
        with pytest.raises(InvalidCharacterError):
            decode(id_str)

    def test_error_reports_correct_position(self):
        try:
            decode("0A000O")
        except InvalidCharacterError as e:
            assert e.position == 6

    def test_error_reports_offending_char(self):
        try:
            decode("0A000O")
        except InvalidCharacterError as e:
            assert e.char == "O"

    def test_invalid_char_is_value_error(self):
        with pytest.raises(ValueError):
            decode("0A000O")

    def test_special_char_rejected(self):
        with pytest.raises(InvalidCharacterError):
            decode("0A00-0")

    def test_space_rejected(self):
        with pytest.raises(InvalidCharacterError):
            decode("0A00 0")


class TestDecodeUnsupportedLength:
    @pytest.mark.parametrize("id_str", ["0A000", "0A000000000"])
    def test_wrong_length(self, id_str):
        with pytest.raises(UnsupportedLengthError):
            decode(id_str)


class TestDecodeTypeErrors:
    def test_empty_string(self):
        with pytest.raises(TypeError):
            decode("")

    def test_none(self):
        with pytest.raises(TypeError):
            decode(None)  # type: ignore[arg-type]

    def test_integer(self):
        with pytest.raises(TypeError):
            decode(123)  # type: ignore[arg-type]
