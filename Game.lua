local Input = SETTINGS.Input
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'
local timer = require'modules.timer'

local Character = require'objects.Character'
local Enemy = require'objects.Enemy'
local Bullet = require'objects.Bullet'
local Aim = require'objects.Aim'

local Air = require'tiles.Air'

local M = {}
M.__index = M

-- Planned Levels
-- [ ] Legs
-- [ ] Stomach
-- [ ] Heart (circulatory system)
-- [ ] Brain
local function new(_)
    local self = {
        aim = Aim(),
        character = Character(Vec(0, 0)),
        enemies = {},
        map = require'data.map',
        bullets = {
            character = {},
            enemies = {},
        },
        state = {
            level = {'legs', enemies = 30},
            debug = false,
            gameover = false,
        },
        timers = {
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

function M:drawDistant()
    love.graphics.push()

    -- Centering camera
    love.graphics.translate(0, 5)
    love.graphics.scale(0.08, 0.08)


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

    -- self.aim:draw(self.character.pos + Vec.mousePosition())

    if self.state.debug then
        self:drawDebug()
    end

    local legs = self.map.areas.legs
    for _, col in ipairs(legs) do
        col:draw(colors.RED)
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

    Input:fullscreen(function()
        dbg.print'toggle fullscree'
        love.window.setFullscreen(not love.window.getFullscreen())
    end)

    Input:giveup(function()
        self.state.gameover = true
    end)

    local dir = Vec(0, 0)
    Input:right(function() dir.x = dir.x + 1 end)
    Input:left(function() dir.x = dir.x - 1 end)
    Input:down(function() dir.y = dir.y + 1 end)
    Input:up(function() dir.y = dir.y - 1 end)
    self.character:move(dir:versor())

    Input:shoot(function(pos)
        self.bullets.character[#self.bullets.character + 1] =
            self.character:shoot(pos + self.character.pos)
    end)
end

function M:update(dt)
    for _, timer in pairs(self.timers) do
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

    -- Character x Walls
    local col_character = Collider.getColliderList{self.character}
    local col_walls = self.map.matrixColliders(self.map.walls)
    for _, collisor in ipairs(col_character) do
        Collider.checkCollisionsNear(
            collisor, self.character.pos, col_walls, self.map.spawn,
            function(i, j)
                local character = self.character
                local wall = self.map.walls[i][j]

                if getmetatable(wall) == Air then return end

                local pos_wall = wall.pos
                local pos_character = character.pos
                local delta = pos_character - pos_wall

                local iteration = 0
                while character:collider():collision(wall:collider()) do
                    character.pos = character.pos + 0.05 * delta
                    iteration = iteration + 1
                    if iteration > 1000 then
                        break
                    end
                end

                dbg.print('Character collided with wall ' .. j)
            end
        )
    end

    -- Enemies x Walls
    local col_enemies = Collider.getColliderList(self.enemies)
    for o, collisor in ipairs(col_enemies) do
        Collider.checkCollisionsNear(
            collisor, self.enemies[o].pos, col_walls, self.map.spawn,
            function(i, j)
                local enemy = self.enemies[o]
                local wall = self.map.walls[i][j]

                if getmetatable(wall) == Air then return end
                if not enemy:isAlive() then return end

                local pos_wall = wall.pos
                local pos_enemy = enemy.pos
                local delta = pos_enemy - pos_wall

                local iteration = 0
                while enemy:collider():collision(wall:collider()) do
                    enemy.pos = enemy.pos + 0.05 * delta
                    iteration = iteration + 1
                    if iteration > 1000 then
                        break
                    end
                end

                dbg.print(('Enemy %d collided with wall %d'):format(i, j))
            end
        )
    end

    -- Character Bullets x Walls
    local col_character_bullets = Collider.getColliderList(self.bullets
        .character)
    for o, collisor in ipairs(col_character_bullets) do
        Collider.checkCollisionsNear(
            collisor, self.bullets.character[o].pos, col_walls, self.map.spawn,
            function(i, j)
                local bullet = self.bullets.character[o]
                local wall = self.map.walls[i][j]

                if getmetatable(wall) == Air then return end
                if not bullet:isAlive() then return end

                bullet:kill()
            end
        )
    end

    -- Enemies Bullets x Walls
    local col_enemies_bullets = Collider.getColliderList(self.bullets.enemies)
    for o, collisor in ipairs(col_enemies_bullets) do
        Collider.checkCollisionsNear(
            collisor, self.bullets.enemies[o].pos, col_walls, self.map.spawn,
            function(i, j)
                local bullet = self.bullets.enemies[o]
                local wall = self.map.walls[i][j]

                if getmetatable(wall) == Air then return end
                if not bullet:isAlive() then return end

                bullet:kill()
            end
        )
    end

    -- Character x Enemies
    Collider.checkCollisionsNtoM(
        col_character, col_enemies,
        function(i, j)
            local character = self.character
            local enemy = self.enemies[j]

            if not enemy:isAlive() then return end

            character:damage(1)
            enemy:damage(5)
        end
    )

    dbg.checkCollisions('%d x %d <= %d', #col_enemies, #self.map.areas.legs)
    for i, col_enemy in ipairs(col_enemies) do
        local collide = false
        for _, col_area in ipairs(self.map.areas.legs) do
            if col_enemy:collide(area) then
                collide = true
                break
            end
        end
        self.enemies[i].insideArea = collide
    end

    if not self.character:isAlive() then
        self.state.gameover = true
    end
end

function M:clean()
    function cleanDead(list)
        local res = {}
        for _, object in ipairs(list) do
            if object:isAlive() then
                res[#res + 1] = object
            end
        end
        return res
    end

    self.timers.clean:clock(function()
        local newBullets = {}
        self.bullets.character = cleanDead(self.bullets.character)
        self.bullets.enemies = cleanDead(self.bullets.enemies)
        self.enemies = cleanDead(self.enemies)
    end)
end

return M
