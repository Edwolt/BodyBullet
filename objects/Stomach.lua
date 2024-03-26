local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'

local M = {}
M.__index = M

local function new(_)
    local self = {}
    return setmetatable(self, M)
end
setmetatable(M, {__call = new})

function M:draw(pos)
    pos = pos or self.pos

    love.graphics.setColor(colors.GRAY)
    love.graphics.rectangle('fill', 3, -48, 8, 9)
    love.graphics.rectangle('fill', -10, -40, 23, 15)
    love.graphics.rectangle('fill', -20, -35, 10, 5)

    love.graphics.setColor(colors.BLACK)
    local width_before = love.graphics.getLineWidth()
    love.graphics.setLineWidth(0.3)
    love.graphics.line{
        -20, -35,
        -10, -35,
        -10, -40,
        3, -40,
        3, -48,
    }
    love.graphics.line{
        11, -48,
        11, -40,
        13, -40,
        13, -25,
        -10, -25,
        -10, -30,
        -20, -30,
    }
    love.graphics.setLineWidth(width_before)
end

function M:update(dt)
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

return M
