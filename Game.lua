local Input = SETTINGS.Input
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'

local Character = require'objects.Character'
local Enemy = require'objects.Enemy'
local Bullet = require'objects.Bullet'
local Aim = require'objects.Aim'

local Air = require'tiles.Air'

local M = {}
M.__index = M

local function new(_)
    local self = {
        aim = Aim(),
        character = Character(Vec(0, 0)),
        enemies = {Enemy(Vec(5, 5))},
        map = require'data.map',
        bullets = {
            character = {},
            enemies = {},
        },
        state = {
            debug = false,
        },
        timer = {
            clean = timer.CoolDown(5),
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

    self.map:draw()
    self.character:draw()

    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
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
    self.map:drawDebug()
    self.character:collider():draw(colors.BLUE)

    for _, enemy in ipairs(self.enemies) do
        enemy:collider():draw(colors.RED)
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
    for _, timer in pairs(timer) do
        timer:update(dt)
    end

    self.map:update(dt)
    self.character:update(dt)

    for _, enemy in ipairs(self.enemies) do
        enemy:look_at(self.character.pos + Vec(0.5, 0.5))
        enemy:update(dt)
        local bullet = enemy:tryshoot(dt, SETTINGS.EVILNESS)
        if bullet ~= nil then
            self.bullets.enemies[#self.bullets.enemies + 1] = bullet
        end
    end

    -- for _, wall in ipairs(self.walls) do
    --     wall:update(dt)
    -- end

    for _, bullet in ipairs(self.bullets.character) do
        bullet:update(dt)
    end
    for _, bullet in ipairs(self.bullets.enemies) do
        bullet:update(dt)
    end

    -- Collision
    self:clean()

    local col_character = {self.character:collider()}
    local col_walls = self.map.matrixColliders(self.map.walls)

    for o, collisor in ipairs(col_character) do
        Collider.checkCollisionsNear(
            collisor, self.character.pos, col_walls, self.map.spawn,
            function(i, j)
                local character = self.character
                local wall = self.map.walls[i][j]

                if getmetatable(wall) == Air then
                    return
                end

                local pos_wall = wall.pos
                local pos_character = character.pos
                local delta = pos_character - pos_wall

                while character:collider():collision(wall:collider()) do
                    character.pos = character.pos + 0.05 * delta
                end

                dbg.print('Character collided with wall ' .. j)
            end
        )
    end

    local col_enemies = {}
    for _, enemy in ipairs(self.enemies) do
        col_enemies[#col_enemies + 1] = enemy:collider()
    end

    for o, collisor in ipairs(col_enemies) do
        Collider.checkCollisionsNear(
            collisor, self.enemies[o].pos, col_walls, self.map.spawn,
            function(i, j)
                local enemy = self.enemies[o]
                local wall = self.map.walls[i][j]

                if getmetatable(wall) == Air then
                    return
                end

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
end

function M:clean()
    self.timer.clean:clock(function()
    end)
end

return M
