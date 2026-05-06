"""
OdoID character set definitions.
These exact strings MUST be reproduced verbatim in every compliant implementation.
"""

#: Numeric characters — radix 10
NUM: str = "0123456789"

#: Alpha characters (ambiguous chars I, L, O excluded) — radix 22
ALPHA: str = "ABCDEFGHJKMNPQRSTVWXYZ"

#: Full hybrid set — NUM concatenated with ALPHA — radix 32
ALL: str = NUM + ALPHA  # "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

#: Supported OdoID lengths
SUPPORTED_LENGTHS: frozenset = frozenset({6, 7, 8})

#: Maximum exclusive value for each supported length.
#: Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
MAX: dict[int, int] = {
    6: 230_686_720,
    7: 7_381_975_040,
    8: 236_223_201_280,
}


def get_charset(i: int) -> str:
    """
    Return the character set for 0-based position index ``i``.

    ========  =======  =====
    Index     Charset  Radix
    ========  =======  =====
    0         ALL      32
    1         ALPHA    22
    2         NUM      10
    3+        ALL      32
    ========  =======  =====
    """
    if i == 1:
        return ALPHA
    if i == 2:
        return NUM
    return ALL
