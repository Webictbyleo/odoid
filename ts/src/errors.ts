/** Thrown when an integer is outside the valid range for the chosen OdoID length. */
export class OverflowError extends RangeError {
  constructor(message: string) {
    super(message);
    this.name = "OverflowError";
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

/** Thrown when a length other than 6, 7, or 8 is requested. */
export class UnsupportedLengthError extends RangeError {
  constructor(length: number) {
    super(`Unsupported OdoID length: ${length}. Must be 6, 7, or 8.`);
    this.name = "UnsupportedLengthError";
    Object.setPrototypeOf(this, new.target.prototype);
  }
}

/** Thrown when a character not present in the positional charset is encountered during decode. */
export class InvalidCharacterError extends RangeError {
  readonly position: number;
  readonly char: string;

  constructor(char: string, position: number) {
    super(`Invalid OdoID character '${char}' at position ${position}.`);
    this.name = "InvalidCharacterError";
    this.position = position;
    this.char = char;
    Object.setPrototypeOf(this, new.target.prototype);
  }
}
