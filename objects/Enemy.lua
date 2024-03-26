local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local timer = require'modules.timer'

local Bullet = require'objects.Bullet'

local M = {}
M.__index = M

local function new(_, pos, vel)
    assert(pos ~= nil)

    local self = {
        pos = pos,
        vel = vel or SETTINGS.ENEMY_VELOCITY,
        dir = Vec(0, 0),
        health = 5,
        insideArea = true,
        impulse = {
            vel = Vec(0, 0),
            timer = timer.Span(0),
        },
    }

    return setmetatable(self, M)
end
setmetatable(M, {__call = new})


function M:draw(pos)
    if not self:isAlive() then return end

    pos = pos or self.pos

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)
    love.graphics.translate(0.5, 0.5)
    --love.graphics.rotate(math.acos(Vec(1, 0):dot(self.dir)))
    local rotate = love.math.newTransform()
    local cos, sin = self.dir:unpack()
    rotate:setMatrix(
        cos, -sin, 0, 0,
        sin, cos, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1
    )
    love.graphics.applyTransform(rotate)
    love.graphics.translate(-0.5, -0.5)

    love.graphics.setColor(colors.BLACK)
    love.graphics.polygon('fill', 0, 0, 0, 1, 1, 0.5)

    love.graphics.pop()
end

function M:update(dt)
    if not self:isAlive() then return end

    if self.insideArea then
        self.pos = self.pos + dt * self.vel * self.dir
    else
        self.pos = self.pos - dt * self.vel * self.dir
    end

    self.impulse.timer:update(dt)
    self.impulse.timer:clock(function()
        self.pos = self.pos + dt * self.impulse.vel
    end)
end

function M:collider()
    if self:isAlive() then
        return Collider(self.pos, Vec(1, 1))
    else
        return Collider.NULL_COLLIDER
    end
end

function M:look_at(target_pos)
    self.dir = (target_pos - self.pos):versor()
end

function M:shoot()
    assert(self:isAlive())
    return Bullet(self.pos, self.dir)
end

function M:tryshoot(dt, evilness)
    if not self:isAlive() then return end
    local value = love.math.random() -- Who wouldn't love math
    if value < dt * evilness then
        return self:shoot()
    end
end

function M:damage(val)
    val = val or 1
    self.health = self.health - val
end

function M:isAlive()
    return self.health > 0
end

function M:createImpulse(vel, duration)
    self.impulse.vel = vel
    self.impulse.timer = timer.Span(duration)
end

return M
