local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local timer = require'modules.timer'

local M = {
    SIZE = Vec(0.1, 0.1),
}
M.__index = M

local function new(M, shooter_pos, direction, vel)
    direction = direction:versor()

    if vel ~= nil then
        vel = direction * vel
    else
        vel = direction * SETTINGS.BULLET_VELOCITY
    end


    local self = {
        pos = shooter_pos,
        vel = vel,
        health = 1, -- The health of the bullet is how much damage it causes
        timer = timer.Timer(SETTINGS.BULLET_TIME_LIMIT),
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

    self.timer:update(dt)
    self.timer:clock(function()
        self:kill()
    end)
end

function M:damage(val)
    val = val or 1
    self.health = self.health - val
end

function M:isAlive()
    return self.health > 0
end

function M:kill()
    self.health = 0
end

function M:collider()
    if self:isAlive() then
        return Collider(self.pos + Vec(0.5, 0.5) - self.SIZE / 2, self.SIZE)
    else
        return Collider.NULL_COLLIDER
    end
end

return M
