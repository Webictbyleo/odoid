--- OdoID character set definitions.
--- These exact strings MUST be reproduced verbatim in every compliant implementation.

local M = {}

--- Numeric characters — radix 10.
M.NUM   = "0123456789"

--- Alpha characters (ambiguous chars I, L, O excluded) — radix 22.
M.ALPHA = "ABCDEFGHJKMNPQRSTVWXYZ"

--- Full hybrid set — NUM concatenated with ALPHA — radix 32.
M.ALL   = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

--- Maximum exclusive value for each supported length.
--- Formula: 32 × 22 × 10 × 32^(L-3) = 220 × 32^(L-2)
M.MAX = {
  [6] = 230686720,
  [7] = 7381975040,
  [8] = 236223201280,
}

--- Returns the character set string for 0-based position index i.
---
--- Index  Charset  Radix
---   0    ALL      32
---   1    ALPHA    22
---   2    NUM      10
---   3+   ALL      32
function M.get_charset(i)
  if i == 1 then return M.ALPHA
  elseif i == 2 then return M.NUM
  else return M.ALL
  end
end

return M
