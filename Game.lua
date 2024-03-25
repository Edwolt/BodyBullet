local Input = SETTINGS.Input
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'

local Character = require'objects.Character'
local Enemy = require'objects.Enemy'
local Bullet = require'objects.Bullet'
local Wall = require'objects.Wall'
local Aim = require'objects.Aim'

local M = {}
M.__index = M

local function new(_)
    local self = {
        aim = Aim(),
        character = Character(Vec(0, 0)),
        walls = {
            Wall(Vec(0, 1)),
            Wall(Vec(1, 1)),
        },
        enemies = {Enemy(Vec(5, 5))},
        bullets = {
            character = {},
            enemies = {},
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

    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    for _, wall in ipairs(self.walls) do
        wall:draw()
    end

    for _, bullet in ipairs(self.bullets.character) do
        bullet:draw()
    end
    for _, bullet in ipairs(self.bullets.enemies) do
        bullet:draw()
    end

    self.aim:draw(self.character.pos + Vec.mousePosition())

    if self.state.debug then
        self:drawDebug()
    end

    love.graphics.pop()
end

function M:drawDebug()
    self.character:collider():draw(colors.BLUE)

    for _, enemy in ipairs(self.enemies) do
        enemy:collider():draw(colors.RED)
    end

    for _, wall in ipairs(self.walls) do
        wall:collider():draw(colors.GREEN)
    end

    for _, bullet in ipairs(self.bullets.character) do
        bullet:collider():draw(colors.RED)
    end
    for _, bullet in ipairs(self.bullets.enemies) do
        bullet:collider():draw(colors.RED)
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

    Input:shoot(function(pos)
        self.bullets.character[#self.bullets.character + 1] =
            self.character:shoot(pos)
    end)
end

function M:update(dt)
    self.character:update(dt)

    for _, enemy in ipairs(self.enemies) do
        enemy:look_at(self.character.pos + Vec(0.5, 0.5))
        enemy:update(dt)
        local bullet = enemy:tryshoot(dt, SETTINGS.EVILNESS)
        if bullet ~= nil then
            self.bullets.enemies[#self.bullets.enemies + 1] = bullet
        end
    end

    for _, wall in ipairs(self.walls) do
        wall:update(dt)
    end

    for _, bullet in ipairs(self.bullets.character) do
        bullet:update(dt)
    end
    for _, bullet in ipairs(self.bullets.enemies) do
        bullet:update(dt)
    end

    -- Collision
    local col_character = {self.character:collider()}
    local col_walls = {}
    for i, wall in ipairs(self.walls) do
        col_walls[i] = wall:collider()
    end

    Collider.checkCollisionsNtoM(
        col_character, col_walls,
        function(i, j)
            local character = self.character
            local wall = self.walls[j]

            local pos_wall = wall.pos
            local pos_character = character.pos
            local delta = pos_character - pos_wall

            while character:collider():collision(wall:collider()) do
                character.pos = character.pos + 0.05 * delta
            end

            dbg.print('Character collided with wall ' .. j)
        end
    )

    local col_enemies = {}
    for i, enemy in ipairs(self.enemies) do
        col_enemies[#col_enemies + 1] = enemy:collider()
    end
    Collider.checkCollisionsNtoM(
        col_enemies, col_walls,
        function(i, j)
            local enemy = self.enemies[i]
            local wall = self.walls[j]

            local pos_wall = wall.pos
            local pos_enemy = enemy.pos
            local delta = pos_enemy - pos_wall

            while enemy:collider():collision(wall:collider()) do
                enemy.pos = enemy.pos + 0.05 * delta
            end

            dbg.print(('Enemy %d collided with wall %d'):format(i, j))
        end
    )
end

return M
