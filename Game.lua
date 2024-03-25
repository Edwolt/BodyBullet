local Input = SETTINGS.Input
local Vec = require'modules.Vec'

local Character = require'objects.Character'
local Block = require'objects.Block'

local M = {
    _loaded = false,
    load = function(M)
        if M._loaded then return end
        M._loaded = true
        dbg.log.load'Game'

        Character:load()
        Block:load()

        dbg.log.loaded'Game'
    end,
}
M.__index = M

local function new(_)
    local self = {
        character = Character(Vec(0, 0)),
        blocks = {
            Block(Vec(0, 1)),
            Block(Vec(1, 1)),
        },
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})

function M:draw()
    love.graphics.push()
    -- Centering camera
    love.graphics.translate(-self.character.pos.x, -self.character.pos.y)
    love.graphics.translate(-0.5, -0.5)

    self.character:draw()
    for _, block in ipairs(self.blocks) do
        block:draw()
    end

    love.graphics.pop()
end

function M:keydown()
    Input:quit(function()
        dbg.print'quit'
        love.event.quit(0)
    end)

    local dir = Vec(0, 0)
    Input:right(function() dir.x = dir.x + 1 end)
    Input:left(function() dir.x = dir.x - 1 end)
    Input:down(function() dir.y = dir.y + 1 end)
    Input:up(function() dir.y = dir.y - 1 end)
    self.character:move(dir:versor())
end

function M:update(dt)
    self.character:update(dt)
    for _, block in ipairs(self.blocks) do
        block:update(dt)
    end
end

return M
