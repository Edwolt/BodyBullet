local M = {}

--- Get a hexadecimal number and return its color as a table
local function hex(val)
    return {love.math.colorFromBytes(
        bit.rshift(bit.band(val, 0xff0000), 16),
        bit.rshift(bit.band(val, 0x00ff00), 8),
        bit.band(val, 0x0000ff)
    )}
end

M.fromHex = hex
M.WHITE = hex(0xaaaaaa)
M.BLACK = hex(0x000000)
M.RED = hex(0xff0000)
M.GREEN = hex(0x00ff00)
M.BLUE = hex(0x0000ff)

return M
