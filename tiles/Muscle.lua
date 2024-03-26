local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local timer = require'modules.timer'

local M = {}
M.__index = M

local function new(_, pos, kind)
    assert(pos ~= nil)
    assert(kind == 'up' or kind == 'down')

    local self = {
        pos = pos,
        kind = kind,
        k = 2,
        timer = timer.Timer(SETTINGS.MUSCLE_TIMING),
        transition = 'none',
    }

    return setmetatable(self, M)
end
setmetatable(M, {__call = new})


function M:draw(pos)
    pos = pos or self.pos

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)

    local points = {}
    for i = 0, 1, 0.1 do
        points[#points + 1] = i
        points[#points + 1] = (math.sin(2 * i * math.pi) + 1) / self.k
    end

    local width_before = love.graphics.getLineWidth()
    love.graphics.setLineWidth(0.01)
    love.graphics.setColor(colors.BLACK)
    love.graphics.line(unpack(points))
    love.graphics.setLineWidth(width_before)

    love.graphics.pop()
end

function M:update(dt)
    self.timer:update(dt)

    self.transition = 'none'
    self.timer:clock(function()
        if self.k == 2 then
            self.k = 4
            self.transition = 'contract'
        else
            self.k = 2
            self.transition = 'relax'
        end
    end)
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

return M
