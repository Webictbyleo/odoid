"""Custom exceptions for the OdoID library."""


class OverflowError(ValueError):
    """Raised when an integer is outside the valid range for the chosen OdoID length."""


class UnsupportedLengthError(ValueError):
    """Raised when a length other than 6, 7, or 8 is requested."""

    def __init__(self, length: int) -> None:
        super().__init__(
            f"Unsupported OdoID length: {length}. Must be 6, 7, or 8."
        )
        self.length = length


class InvalidCharacterError(ValueError):
    """Raised when a character absent from the positional charset is encountered during decode."""

    def __init__(self, char: str, position: int) -> None:
        super().__init__(
            f"Invalid OdoID character {char!r} at position {position}."
        )
        self.char = char
        self.position = position
