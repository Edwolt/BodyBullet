local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local timer = require'modules.timer'

local Bullet = require'objects.Bullet'

local M = {}
M.__index = M

local function new(_, pos)
    assert(pos ~= nil)

    local self = {
        pos = pos,
        vel = Vec(0, 0),
        health = 10,
        impulse = {
            vel = Vec(0, 0),
            timer = timer.Span(0),
        },
        dashing = {
            origin = Vec(0, 0),
            destiny = Vec(0, 0),
            timer = timer.Span(0),
        },
    }

    return setmetatable(self, M)
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
    self.impulse.timer:update(dt)
    self.dashing.timer:update(dt)

    if self.dashing.happening then
        local happened = false
        self.dashing.timer:clock(
            function(alpha)
                happened = true
                local origin = self.dashing.origin
                local destiny = self.dashing.destiny
                self.pos = (1 - alpha) * origin + (alpha) * destiny
            end,
            self.dashing.timer:percentage()
        )
        if not happened then
            self.dashing.happening = false
        end
    else
        self.pos = self.pos + dt * SETTINGS.CHARACTER_VELOCITY * self.vel

        self.impulse.timer:clock(function()
            self.pos = self.pos + dt * self.impulse.vel
        end)
    end
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

function M:move(vel)
    self.vel = vel
end

function M:dash(pos)
    local delta = pos - self.pos
    delta = SETTINGS.DASH_DISTANCE_LIMIT * delta:versor()

    local destiny = self.pos + delta

    self.dashing = {
        happening = true,
        origin = self.pos,
        destiny = destiny,
        timer = timer.Span(SETTINGS.DASH_DURATION),
    }
end

function M:shoot(target_pos)
    return Bullet(self.pos, target_pos - self.pos)
end

function M:isAlive()
    return self.health > 0
end

function M:damage(val)
    val = val or 1
    self.health = self.health - val
end

function M:createImpulse(vel, duration)
    self.impulse.vel = vel
    self.impulse.timer = timer.Span(duration)
end

return M
