//! Compliance test vectors as defined in SPEC.md § 8.
//! Every compliant implementation MUST pass these tests unchanged.

use odoid::{decode, encode, InvalidCharacterError, OdoError, MAX};

// ── § 8.1 Encode ──────────────────────────────────────────────────────────────

#[test]
fn encode_0_length6() {
    assert_eq!(encode(0, 6).unwrap(), "0A0000");
}

#[test]
fn encode_1234567_length6() {
    assert_eq!(encode(1234567, 6).unwrap(), "0D7NM7");
}

#[test]
fn encode_1234567_length7() {
    assert_eq!(encode(1234567, 7).unwrap(), "0A15NM7");
}

#[test]
fn encode_236223201279_length8() {
    assert_eq!(encode(236223201279, 8).unwrap(), "ZZ9ZZZZZ");
}

#[test]
fn encode_max_minus1_length6() {
    assert_eq!(encode(230_686_719, 6).unwrap(), "ZZ9ZZZ");
}

// ── § 8.2 Decode round-trips ──────────────────────────────────────────────────

#[test]
fn decode_0a0000() {
    assert_eq!(decode("0A0000").unwrap(), 0);
}

#[test]
fn decode_0d7nm7() {
    assert_eq!(decode("0D7NM7").unwrap(), 1234567);
}

#[test]
fn decode_0a15nm7() {
    assert_eq!(decode("0A15NM7").unwrap(), 1234567);
}

#[test]
fn decode_zz9zzzzz() {
    assert_eq!(decode("ZZ9ZZZZZ").unwrap(), 236223201279);
}

#[test]
fn decode_zz9zzz() {
    assert_eq!(decode("ZZ9ZZZ").unwrap(), 230_686_719);
}

// ── § 8.3 Error cases ─────────────────────────────────────────────────────────

#[test]
fn encode_max6_overflows() {
    let err = encode(MAX[6], 6).unwrap_err();
    assert!(matches!(err, OdoError::Overflow(_)));
}

#[test]
fn encode_length5_unsupported() {
    let err = encode(0, 5).unwrap_err();
    assert!(matches!(err, OdoError::UnsupportedLength(_)));
}

#[test]
fn decode_contains_o_at_position6() {
    let err = decode("0A000O").unwrap_err();
    match err {
        OdoError::InvalidCharacter(InvalidCharacterError { ch, position }) => {
            assert_eq!(ch, 'O');
            assert_eq!(position, 6);
        }
        _ => panic!("expected InvalidCharacterError, got {err:?}"),
    }
}

#[test]
fn decode_contains_i_at_position6() {
    let err = decode("0A000I").unwrap_err();
    match err {
        OdoError::InvalidCharacter(InvalidCharacterError { position, .. }) => {
            assert_eq!(position, 6);
        }
        _ => panic!("expected InvalidCharacterError, got {err:?}"),
    }
}

#[test]
fn decode_lowercase_l_becomes_excluded_l() {
    let err = decode("0A000l").unwrap_err();
    assert!(matches!(err, OdoError::InvalidCharacter(_)));
}

#[test]
fn decode_empty_string_errors() {
    let err = decode("").unwrap_err();
    assert!(matches!(err, OdoError::EmptyInput));
}
