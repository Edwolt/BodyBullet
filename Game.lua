local Key = SETTINGS.Key
local Vec = require'modules.Vec'

local Character = require'objects.Character'

local M = {
    _loaded = false,
    load = function(M)
        if M._loaded then return end
        M._loaded = true
        dbg.log.load'Game'

        dbg.log.loaded'Game'
    end,
}
M.__index = M

local function new(_)
    local self = {}

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})

function M:draw()
    love.graphics.push()

    local character = Character(Vec(0, 0))
    character:draw()

    love.graphics.pop()
end

function M:keydown()
    Key:quit(function()
        dbg.print'quit'
        love.event.quit(0)
    end)
end

function M:update(dt)
end

return M
