local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'

local M = {}
M.__index = M

local function new(_)
    local self = {}
    return setmetatable(self, M)
end
setmetatable(M, {__call = new})


function M:draw(pos)
    assert(pos ~= nil)

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)

    love.graphics.setColor(colors.BLACK)
    love.graphics.rectangle('fill', 0.49, 0.49, 0.01, 0.01)
    love.graphics.rectangle('fill', 0.45, 0, 0.1, 0.4)
    love.graphics.rectangle('fill', 0.45, 0.6, 0.1, 0.4)
    love.graphics.rectangle('fill', 0, 0.45, 0.4, 0.1)
    love.graphics.rectangle('fill', 0.6, 0.45, 0.4, 0.1)

    love.graphics.pop()
end

function M:collider(pos)
    assert(pos ~= nil)

    local vec_tiles = Vec(SETTINGS.TILES, SETTINGS.TILES)

    local p = pos - (vec_tiles / 2)
    return Collider(p, vec_tiles)
end

function M:update(dt)
    self.pos = self.pos + 10 * dt * self.vel
end

function M:move(vel)
    self.vel = vel
end

return M
