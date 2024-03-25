local colors = require'modules.color'

local M = {
    _loaded = false,
    load = function(M)
        if M._loaded then return end
        M._loaded = true

        dbg.log.load'Block'
        dbg.log.loaded'Block'
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
    love.graphics.rectangle('fill', 0, 0, 1, 1)

    love.graphics.pop()
end

return M
