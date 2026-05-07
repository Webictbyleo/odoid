"""OdoIDGenerator — distributed monotonic generator."""

import time
import os
from dataclasses import dataclass, field
from typing import Optional

from ._charsets import MAX, SUPPORTED_LENGTHS
from ._decode import decode
from ._encode import assert_length, encode
from ._errors import UnsupportedLengthError


def _fnv1a32(value: str) -> int:
    """
    Compute a FNV-1a 32-bit hash of *value*.

    Constants are normative:
    - Offset basis: 2166136261
    - FNV prime:    16777619
    """
    h = 2166136261
    for ch in value:
        h ^= ord(ch)
        h = (h * 16777619) & 0xFFFFFFFF
    return h


def _now_ms() -> int:
    """Return the current time in milliseconds (integer)."""
    return time.time_ns() // 1_000_000


@dataclass
class OdoIDResult:
    """Value returned by :meth:`OdoIDGenerator.next`."""
    id: str
    n: int
    length: int
    namespace: str


class OdoIDGenerator:
    """
    A distributed monotonic generator that produces OdoID strings driven by a
    namespace-scoped, time-seeded pseudo-random integer.

    The generator guarantees that rapid successive calls within the same
    millisecond tick produce distinct values via a monotonically incrementing
    sequence counter. Output is always in ``[0, capacity)`` so
    :func:`encode` never raises :exc:`OverflowError` internally.
    """

    def __init__(
        self,
        *,
        namespace: str = "default",
        length: int = 6,
        epoch: Optional[int] = None,
    ) -> None:
        """
        :param namespace: Logical partition for this generator. Defaults to ``"default"``.
        :param length:    OdoID string length. Must be 6, 7, or 8. Defaults to ``6``.
        :param epoch:     Millisecond timestamp used as the time origin.
                          Defaults to ``now`` at construction time.
        :raises UnsupportedLengthError: if *length* is not 6, 7, or 8.
        """
        assert_length(length)
        self.namespace = namespace
        self.length = length
        self.capacity = MAX[length]
        self.epoch = epoch if epoch is not None else 0
        self._sequence = 0
        self._last_tick = 0
        self._salt = int.from_bytes(os.urandom(4), "big")

    def _now(self) -> int:
        return _now_ms() - self.epoch

    def next_n(self) -> int:
        """Return the next raw integer ``n`` in ``[0, capacity)``.

        Exported for testing and low-level use.
        """
        tick = self._now()

        if tick == self._last_tick:
            self._sequence += 1
        else:
            self._sequence = 0
            self._last_tick = tick

        # FNV-1a hash of "namespace|salt|tick", then XOR-shift PRNG
        seed = _fnv1a32(f"{self.namespace}|{self._salt}|{tick}")

        seed ^= seed << 13
        seed ^= seed >> 7
        seed ^= seed << 17

        n = (seed + self._sequence) % self.capacity
        if n < 0:
            n = -n

        return n

    def next(self) -> OdoIDResult:
        """Generate and return the next OdoID."""
        n = self.next_n()
        id_str = encode(n, self.length)
        return OdoIDResult(id=id_str, n=n, length=self.length, namespace=self.namespace)

    def encode(self, n: int) -> str:
        """Encode *n* using this generator's configured length."""
        return encode(n, self.length)

    def decode(self, id_str: str) -> int:
        """Decode an OdoID string to its originating integer."""
        return decode(id_str)
