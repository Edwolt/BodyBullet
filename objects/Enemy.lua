local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'

local M = {}
M.__index = M

local function new(_, pos)
    local self = {
        pos = pos,
        vel = Vec(0, 0),
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})


function M:draw(pos)
    pos = pos or self.pos

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)
    love.graphics.translate(0.5, 0.5)

    love.graphics.setColor(colors.BLACK)
    love.graphics.circle('fill', 0, 0, 0.5)

    love.graphics.setColor(colors.WHITE)
    love.graphics.ellipse('fill', -0.15, -0.25, 0.15, 0.20)
    love.graphics.ellipse('fill', 0.15, -0.25, 0.15, 0.20)

    love.graphics.setColor(colors.BLACK)
    love.graphics.circle('fill', -0.15, -0.23, 0.10)
    love.graphics.circle('fill', 0.15, -0.23, 0.10)

    love.graphics.pop()
end

function M:update(dt)
    self.pos = self.pos + dt * SETTINGS.CHARACTER_VELOCITY * self.vel
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

function M:move(vel)
    self.vel = vel
end

return M
