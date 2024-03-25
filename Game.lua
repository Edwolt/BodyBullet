local Key = SETTINGS.Key
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

    self.character:draw()
    for _, block in ipairs(self.blocks) do
        block:draw()
    end

    love.graphics.pop()
end

function M:keydown()
    Key:quit(function()
        dbg.print'quit'
        love.event.quit(0)
    end)

    local dir = Vec(0, 0)
    Key:right(function() dir.x = dir.x + 1 end)
    Key:left(function() dir.x = dir.x - 1 end)
    Key:down(function() dir.y = dir.y + 1 end)
    Key:up(function() dir.y = dir.y - 1 end)
    self.character:move(dir:versor())
end

function M:update(dt)
    self.character:update(dt)
    for _, block in ipairs(self.blocks) do
        block:update(dt)
    end
end

return M
