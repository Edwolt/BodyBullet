local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local Bullets = require'modules.Bullets'

local M = {}
M.__index = M

local function new(_, pos, vel)
    local self = {
        pos = pos,
        vel = vel or SETTINGS.ENEMY_VELOCITY,
        dir = Vec(0, 0),
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})


function M:draw(pos)
    pos = pos or self.pos

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)
    love.graphics.rotate(math.acos(Vec(0, 1):dot(self.dir)))

    love.graphics.setColor(colors.BLACK)
    love.graphics.polygon('fill', 0, 0, 0, 1, 1, 0.5)

    love.graphics.pop()
end

function M:update(dt)
    self.pos = self.pos + dt * self.vel * self.dir
end

function M:collider()
    return Collider(Vec(1, 1))
end

function M:look_at(target_pos)
    self.dir = (target_pos - self.pos):versor()
end

function M:shoot()
    return Bullet(self.pos, self.dir)
end

return M
