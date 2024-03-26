local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'


local M = {}
M.__index = M

local function new(_, pos)
    local self = {pos = pos}
    return setmetatable(self, M)
end
setmetatable(M, {__call = new})


function M:draw(pos)
    pos = pos or self.pos
    print'drawin Checkpoint'

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)

    love.graphics.setColor(colors.BLACK)
    love.graphics.circle('fill', 0, 0, 2)

    love.graphics.setColor(colors.WHITE)
    love.graphics.circle('fill', 0, 0, 1.5)

    love.graphics.setColor(colors.BLACK)
    love.graphics.circle('fill', 0, 0, 1)

    love.graphics.setColor(colors.WHITE)
    love.graphics.circle('fill', 0, 0, 0.5)

    love.graphics.pop()
end

function M:update(dt) end

function M:collider() return Collider.NULL_COLLIDER end

return M
