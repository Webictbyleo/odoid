use odoid::{decode, encode, OdoError, ALPHA, MAX};

#[test]
fn output_length_matches_requested() {
    for &length in &[6, 7, 8] {
        assert_eq!(encode(0, length).unwrap().len(), length);
    }
}

#[test]
fn output_is_always_uppercase() {
    for &n in &[0u64, 1, 100, 999999, 1234567] {
        let id = encode(n, 6).unwrap();
        assert_eq!(id, id.to_uppercase());
    }
}

#[test]
fn position_1_is_always_alpha() {
    for &n in &[0u64, 1, 100, 1234567] {
        let id = encode(n, 6).unwrap();
        let ch = id.chars().nth(1).unwrap();
        assert!(ALPHA.contains(ch), "pos 1 = '{ch}' not in ALPHA");
    }
}

#[test]
fn position_2_is_always_digit() {
    for &n in &[0u64, 1, 100, 1234567] {
        let id = encode(n, 6).unwrap();
        let ch = id.chars().nth(2).unwrap();
        assert!(ch.is_ascii_digit(), "pos 2 = '{ch}' not a digit");
    }
}

#[test]
fn excluded_chars_never_appear() {
    for &n in &[0u64, 1, 1000, 1234567, 100_000_000, MAX[8] - 1] {
        let id = encode(n, 8).unwrap();
        assert!(!id.contains('I'), "{id} contains I");
        assert!(!id.contains('L'), "{id} contains L");
        assert!(!id.contains('O'), "{id} contains O");
    }
}

#[test]
fn boundary_zero_valid() {
    for &length in &[6, 7, 8] {
        assert!(encode(0, length).is_ok());
    }
}

#[test]
fn boundary_max_minus1_valid() {
    for &length in &[6, 7, 8] {
        assert!(encode(MAX[length] - 1, length).is_ok());
    }
}

#[test]
fn overflow_at_max() {
    for &length in &[6, 7, 8] {
        assert!(matches!(encode(MAX[length], length), Err(OdoError::Overflow(_))));
    }
}

#[test]
fn overflow_error_message_contains_value() {
    let err = encode(MAX[6], 6).unwrap_err();
    assert!(err.to_string().contains(&MAX[6].to_string()));
}

#[test]
fn unsupported_lengths() {
    for &length in &[0, 1, 5, 9, 100] {
        assert!(
            matches!(encode(0, length), Err(OdoError::UnsupportedLength(_))),
            "length {length} should be unsupported"
        );
    }
}

#[test]
fn round_trips() {
    let cases: &[(u64, usize)] = &[
        (0, 6), (1, 6), (255, 6), (65535, 6), (1234567, 6),
        (0, 7), (1234567, 7),
        (0, 8), (1234567, 8),
    ];
    for &(n, length) in cases {
        let id = encode(n, length).unwrap();
        assert_eq!(decode(&id).unwrap(), n, "round-trip failed for ({n}, {length})");
    }
}

#[test]
fn decode_lowercase_accepted() {
    assert_eq!(decode("0a0000").unwrap(), 0);
}

#[test]
fn decode_mixed_case_matches_upper() {
    assert_eq!(decode("0d7nm7").unwrap(), decode("0D7NM7").unwrap());
}

#[test]
fn decode_excluded_chars_rejected() {
    for ch in ['I', 'L', 'O'] {
        let id = format!("0A0{ch}00");
        assert!(
            matches!(decode(&id), Err(OdoError::InvalidCharacter(_))),
            "expected InvalidCharacter for '{ch}'"
        );
    }
}

#[test]
fn decode_reports_correct_position() {
    let err = decode("0A000O").unwrap_err();
    match err {
        OdoError::InvalidCharacter(e) => assert_eq!(e.position, 6),
        _ => panic!("wrong error type"),
    }
}

#[test]
fn decode_special_char_rejected() {
    assert!(matches!(decode("0A00-0"), Err(OdoError::InvalidCharacter(_))));
}

#[test]
fn decode_unsupported_length() {
    assert!(matches!(decode("0A000"),      Err(OdoError::UnsupportedLength(_))));
    assert!(matches!(decode("0A000000000"), Err(OdoError::UnsupportedLength(_))));
}
