local colors = require'modules.colors'
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local timer = require'modules.timer'

local M = {}
M.__index = M

local function new(_, pos, kind)
    assert(kind == 'up' or kind == 'down')

    local self = {
        pos = pos,
        t = 0,
        kind = kind,
        timer = timer.Timer(SETTINGS.MUSCLE_TIMING),
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})


function M:draw(pos)
    pos = pos or self.pos

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)

    local points = {}
    for i = 0, 1, 0.1 do
        points[#points + 1] = i
        print(self:k())
        points[#points + 1] = (math.sin(2 * i * math.pi) + 1) / self:k()
    end

    local width_before = love.graphics.getLineWidth()
    love.graphics.setLineWidth(0.01)
    love.graphics.setColor(colors.BLACK)
    love.graphics.line(unpack(points))
    love.graphics.setLineWidth(width_before)

    love.graphics.pop()
end

function M:k()
    return 4 + 2 * math.sin(self.t)
end

function M:update(dt)
    self.t = self.t + dt
end

function M:collider()
    return Collider(self.pos, Vec(1, 1))
end

return M
