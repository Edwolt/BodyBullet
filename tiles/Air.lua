local Vec = require'modules.Vec'
local Collider = require'modules.Collider'

local M = {}
M.__index = M

local function new(_, pos)
    local self = {
        pos = pos,
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})

function M:draw(pos)
end

function M:update(dt)
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

return M
