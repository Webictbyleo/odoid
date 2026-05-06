use odoid::{decode, GeneratorConfig, OdoIDGenerator, MAX};

#[test]
fn default_config() {
    let g = OdoIDGenerator::new(GeneratorConfig::default()).unwrap();
    assert_eq!(g.namespace, "default");
    assert_eq!(g.length, 6);
}

#[test]
fn custom_config() {
    let g = OdoIDGenerator::new(GeneratorConfig {
        namespace: "acme".into(),
        length: 8,
        ..Default::default()
    })
    .unwrap();
    assert_eq!(g.namespace, "acme");
    assert_eq!(g.length, 8);
    assert_eq!(g.capacity, MAX[8]);
}

#[test]
fn unsupported_length_errors() {
    assert!(OdoIDGenerator::new(GeneratorConfig { length: 5, ..Default::default() }).is_err());
}

#[test]
fn next_result_has_correct_shape() {
    let mut g = OdoIDGenerator::new(GeneratorConfig {
        namespace: "test".into(),
        length: 6,
        ..Default::default()
    })
    .unwrap();
    let r = g.next().unwrap();
    assert!(!r.id.is_empty());
    assert_eq!(r.length, 6);
    assert_eq!(r.namespace, "test");
}

#[test]
fn id_has_correct_length() {
    for &length in &[6, 7, 8] {
        let mut g = OdoIDGenerator::new(GeneratorConfig { length, ..Default::default() }).unwrap();
        assert_eq!(g.next().unwrap().id.len(), length);
    }
}

#[test]
fn excluded_chars_never_in_output() {
    let mut g = OdoIDGenerator::new(GeneratorConfig { length: 8, ..Default::default() }).unwrap();
    for _ in 0..50 {
        let id = g.next().unwrap().id;
        assert!(!id.contains('I'));
        assert!(!id.contains('L'));
        assert!(!id.contains('O'));
    }
}

#[test]
fn n_in_valid_range() {
    for &length in &[6, 7, 8] {
        let mut g = OdoIDGenerator::new(GeneratorConfig { length, ..Default::default() }).unwrap();
        for _ in 0..50 {
            let n = g.next().unwrap().n;
            assert!(n < MAX[length], "n={n} not < MAX[{length}]={}", MAX[length]);
        }
    }
}

#[test]
fn n_matches_decode_of_id() {
    let mut g = OdoIDGenerator::new(GeneratorConfig {
        namespace: "verify".into(),
        length: 6,
        ..Default::default()
    })
    .unwrap();
    for _ in 0..20 {
        let r = g.next().unwrap();
        assert_eq!(decode(&r.id).unwrap(), r.n);
    }
}

#[test]
fn monotonic_sequencing_same_tick_distinct_ids() {
    use std::time::{SystemTime, UNIX_EPOCH};
    let future_epoch = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_millis() as u64
        + 60_000;

    let mut g = OdoIDGenerator::new(GeneratorConfig {
        namespace: "seq-test".into(),
        epoch: Some(future_epoch),
        ..Default::default()
    })
    .unwrap();

    let ids: std::collections::HashSet<String> =
        (0..20).map(|_| g.next().unwrap().id).collect();
    assert_eq!(ids.len(), 20, "expected 20 distinct IDs, got {}", ids.len());
}

#[test]
fn namespace_isolation() {
    use std::time::{SystemTime, UNIX_EPOCH};
    let future_epoch = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_millis() as u64
        + 60_000;

    let mut g1 = OdoIDGenerator::new(GeneratorConfig {
        namespace: "ns-a".into(),
        length: 8,
        epoch: Some(future_epoch),
    })
    .unwrap();
    let mut g2 = OdoIDGenerator::new(GeneratorConfig {
        namespace: "ns-b".into(),
        length: 8,
        epoch: Some(future_epoch),
    })
    .unwrap();

    assert_ne!(g1.next().unwrap().id, g2.next().unwrap().id);
}

#[test]
fn proxy_encode_uses_generator_length() {
    let g = OdoIDGenerator::new(GeneratorConfig { length: 7, ..Default::default() }).unwrap();
    assert_eq!(g.encode(0).unwrap().len(), 7);
}

#[test]
fn proxy_decode_returns_correct_n() {
    let mut g = OdoIDGenerator::new(GeneratorConfig { length: 6, ..Default::default() }).unwrap();
    let r = g.next().unwrap();
    assert_eq!(g.decode(&r.id).unwrap(), r.n);
}
