local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'

local M = {
    SIZE = Vec(0.1, 0.1),
}
M.__index = M

local function new(M, shooter_pos, direction, vel)
    -- local direction = (target_pos - shooter_pos):versor()
    direction = direction:versor()
    -- angle = math.asin(direction.y)

    if vel ~= nil then
        vel = direction * vel
    else
        vel = direction * SETTINGS.BULLET_VELOCITY
    end


    local self = {
        pos = shooter_pos,
        vel = vel,
        angle = angle,
        health = 1, -- The health of the bullet is how much damage it causes
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})

function M:draw(pos)
    if not self:isAlive() then return end

    pos = pos or self.pos

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)
    love.graphics.translate(0.5, 0.5)

    love.graphics.setColor(colors.BLACK)
    love.graphics.circle('fill', 0, 0, 0.1)

    love.graphics.pop()
end

function M:update(dt)
    self.pos = self.pos + dt * self.vel
end

function M:damage()
    self.health = self.health - 1
end

function M:isAlive()
    return self.health > 0
end

function M:collider()
    return Collider(self.pos + Vec(0.5, 0.5) - self.SIZE / 2, self.SIZE)
end

return M
