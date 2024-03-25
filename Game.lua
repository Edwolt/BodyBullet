local Input = SETTINGS.Input
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'

local Character = require'objects.Character'
local Block = require'objects.Block'
local Aim = require'objects.Aim'

local M = {}
M.__index = M

local function new(_)
    local self = {
        aim = Aim(),
        character = Character(Vec(0, 0)),
        blocks = {
            Block(Vec(0, 1)),
            Block(Vec(1, 1)),
        },
        state = {
            debug = false,
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

    self.aim:draw(Vec.mousePosition())

    if self.state.debug then
        self:drawDebug()
    end

    love.graphics.pop()
end

function M:drawDebug()
    self.character:collider():draw(colors.BLUE)
    for _, block in ipairs(self.blocks) do
        block:collider():draw(colors.RED)
    end
end

function M:keydown()
    Input:quit(function()
        dbg.print'quit'
        love.event.quit(0)
    end)

    Input:debug(function()
        dbg.print'toggle debug'
        self.state.debug = not self.state.debug
    end)

    local dir = Vec(0, 0)
    Input:right(function() dir.x = dir.x + 1 end)
    Input:left(function() dir.x = dir.x - 1 end)
    Input:down(function() dir.y = dir.y + 1 end)
    Input:up(function() dir.y = dir.y - 1 end)
    self.character:move(dir:versor())

    Input:click(function(pos)
        inspect{pos, 'pos'}
    end)
end

function M:update(dt)
    self.character:update(dt)
    for _, block in ipairs(self.blocks) do
        block:update(dt)
    end

    -- Collision
    local col_character = {self.character:collider()}
    local col_blocks = {}
    for i, block in ipairs(self.blocks) do
        col_blocks[i] = block:collider()
    end

    Collider.checkCollisionsNtoM(
        col_character, col_blocks,
        function(_, j)
            local pos_block = self.blocks[j].pos
            local pos_character = self.character.pos
            local delta = pos_character - pos_block

            while self.character:collider():collision(self.blocks[j]:collider()) do
                self.character.pos = self.character.pos + 0.05 * delta
            end

            print('Collision with block ' .. j)
        end
    )
end

return M
