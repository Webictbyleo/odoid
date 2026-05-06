--- OdoID error constructors.

local M = {}

--- Returned when n >= MAX[length].
function M.overflow(n, length, max)
  return {
    type    = "OverflowError",
    n       = n,
    length  = length,
    max     = max,
    message = string.format(
      "n=%d is out of range for length %d. Valid range: 0 <= n < %d",
      n, length, max
    ),
  }
end

--- Returned when length is not 6, 7, or 8.
function M.unsupported_length(length)
  return {
    type    = "UnsupportedLengthError",
    length  = length,
    message = string.format(
      "unsupported OdoID length: %d. Must be 6, 7, or 8", length
    ),
  }
end

--- Returned when a character is absent from its positional charset.
function M.invalid_character(ch, position)
  return {
    type     = "InvalidCharacterError",
    ch       = ch,
    position = position,
    message  = string.format(
      "invalid OdoID character %q at position %d", ch, position
    ),
  }
end

return M
