local colors = require'modules.color'

local M = {
    _loaded = false,
    load = function(M)
        if M._loaded then return end
        M._loaded = true

        dbg.log.load'Character'
        dbg.log.loaded'Character'
    end,
}
M.__index = M

local function new(_, pos)
    local self = {
        pos = pos,
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})


function M:draw(pos)
    pos = pos or self.pos

    dbg.inspect{self, 'self'}

    love.graphics.push()
    love.graphics.translate(pos.x, pos.y)

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

return M
