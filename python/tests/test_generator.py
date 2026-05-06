import pytest
from odoid import MAX, UnsupportedLengthError, decode
from odoid import OdoIDGenerator


class TestConstruction:
    def test_default_options(self):
        g = OdoIDGenerator()
        assert g.namespace == "default"
        assert g.length == 6

    def test_custom_namespace_and_length(self):
        g = OdoIDGenerator(namespace="acme", length=8)
        assert g.namespace == "acme"
        assert g.length == 8

    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_capacity_matches_max(self, length):
        assert OdoIDGenerator(length=length).capacity == MAX[length]

    def test_unsupported_length_raises(self):
        with pytest.raises(UnsupportedLengthError):
            OdoIDGenerator(length=5)


class TestNext:
    def test_result_has_correct_shape(self):
        g = OdoIDGenerator(namespace="test", length=6)
        result = g.next()
        assert hasattr(result, "id")
        assert hasattr(result, "n")
        assert hasattr(result, "length")
        assert hasattr(result, "namespace")

    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_id_has_correct_length(self, length):
        g = OdoIDGenerator(length=length)
        assert len(g.next().id) == length

    def test_id_is_uppercase_alphanumeric(self):
        g = OdoIDGenerator(length=8)
        for _ in range(50):
            id_str = g.next().id
            assert id_str.isalnum()
            assert id_str == id_str.upper()

    def test_excluded_chars_never_in_output(self):
        g = OdoIDGenerator(length=8)
        for _ in range(50):
            id_str = g.next().id
            assert "I" not in id_str
            assert "L" not in id_str
            assert "O" not in id_str

    @pytest.mark.parametrize("length", [6, 7, 8])
    def test_n_in_valid_range(self, length):
        g = OdoIDGenerator(length=length)
        for _ in range(50):
            n = g.next().n
            assert 0 <= n < MAX[length]

    def test_n_matches_decode_id(self):
        g = OdoIDGenerator(namespace="verify", length=6)
        for _ in range(20):
            result = g.next()
            assert decode(result.id) == result.n

    def test_namespace_and_length_in_result(self):
        g = OdoIDGenerator(namespace="ns1", length=7)
        result = g.next()
        assert result.namespace == "ns1"
        assert result.length == 7


class TestProxyMethods:
    def test_encode_uses_generator_length(self):
        g = OdoIDGenerator(length=7)
        assert len(g.encode(0)) == 7

    def test_decode_returns_correct_n(self):
        g = OdoIDGenerator(length=6)
        result = g.next()
        assert g.decode(result.id) == result.n


class TestMonotonicSequencing:
    def test_same_tick_produces_distinct_ids(self):
        # Use a future epoch so tick stays at 0
        import time
        future_epoch = int(time.time() * 1000) + 60_000
        g = OdoIDGenerator(namespace="seq-test", epoch=future_epoch)

        ids = {g.next().id for _ in range(20)}
        assert len(ids) == 20


class TestNamespaceIsolation:
    def test_different_namespaces_produce_different_ids(self):
        import time
        future_epoch = int(time.time() * 1000) + 60_000
        g1 = OdoIDGenerator(namespace="ns-a", length=8, epoch=future_epoch)
        g2 = OdoIDGenerator(namespace="ns-b", length=8, epoch=future_epoch)

        assert g1.next().id != g2.next().id
