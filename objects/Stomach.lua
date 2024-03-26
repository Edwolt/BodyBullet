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

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)

    love.graphics.getColor(colors.RED)
    love.graphics.rectangle('fill', 0, 0, 10, 10)

    love.graphics.pop()
end

function M:update(dt)
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

return M
