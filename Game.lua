local Muscle = require'tiles.Muscle'

local Input = SETTINGS.Input
local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'
local timer = require'modules.timer'

local Character = require'objects.Character'
local Enemy = require'objects.Enemy'
local Aim = require'objects.Aim'
local Stomach = require'objects.Stomach'

local Wall = require'tiles.Wall'

local M = {}
M.__index = M

-- State is shared between games
local state = {
    debug = false,
    gameover = false,
}

local stomach = Stomach()
-- Planned Levels
-- [X] Legs
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
        state = state,
        level_name = 'legs',
        timers = {
            clean = timer.Timer(SETTINGS.CLEAN_TIMING),
        },
    }
    self.level = self.map.levels[self.level_name]()
    self.state.gameover = false

    return setmetatable(self, M)
end
setmetatable(M, {__call = new})

function M:isCharacterInnerArea()
    local collides = false
    for _, col_area in ipairs(self.level.area) do
        if self.character:collider():collision(col_area) then
            collides = true
        end
    end
    return collides
end

function M:draw()
    if self:isCharacterInnerArea() then
        self:drawNear()
    else
        self:drawDistant()
    end
end

function M:drawNear()
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
    love.graphics.scale(0.2, 0.2)
    love.graphics.translate(-self.character.pos.x, -self.character.pos.y)
    love.graphics.translate(-0.5, -0.5)
    -- love.graphics.translate(0, 5)
    -- love.graphics.scale(0.08, 0.08)


    stomach:draw()
    self.map:drawDistant()
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

    inspect{self.level.checkpoint}
    self.level.checkpoint:draw()

    if self.state.debug then
        self:drawDebug()
    end


    love.graphics.pop()
end

function M:drawDebug()
    self.map:drawDebug()

    self.aim:collider(self.character.pos):draw(colors.YELLOW)
    self.character:collider():draw(colors.BLUE)

    for _, area in ipairs(self.level.area) do
        area:draw(colors.GREEN)
    end

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

    -- Penalize going out area
    if self:isCharacterInnerArea() then
        Input:shoot(function(pos)
            self.bullets.character[#self.bullets.character + 1] =
                self.character:shoot(pos + self.character.pos)
        end)
    end
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

    -- Character x Tiles
    local col_character = Collider.getColliderList{self.character}
    local col_tiles = self.map.matrixColliders(self.map.tiles)
    local col_enemies = Collider.getColliderList(self.enemies)
    local col_character_bullets = Collider.getColliderList(
        self.bullets.character
    )
    local col_enemies_bullets = Collider.getColliderList(self.bullets.enemies)
    local col_area = self.level.area

    local function avoidWall(obj, wall)
        local pos_wall = wall.pos
        local pos_obj = obj.pos
        local delta = pos_obj - pos_wall

        local iteration = 0
        while obj:collider():collision(wall:collider()) do
            obj.pos = obj.pos + 0.05 * delta
            iteration = iteration + 1
            if iteration > 1000 then break end
        end
    end

    local function muscleImpulse(obj, muscle)
        local VELOCITY = SETTINGS.IMPULSE_VELOCITY
        local DURATION = SETTINGS.IMPULSE_DURATION
        if muscle.transition == 'contract' then
            if muscle.kind == 'down' then
                obj:createImpulse(VELOCITY, DURATION)
            else
                obj:createImpulse(-VELOCITY, DURATION)
            end
        elseif muscle.transition == 'relax' then
            if muscle.kind == 'down' then
                obj:createImpulse(-VELOCITY, DURATION)
            else
                obj:createImpulse(VELOCITY, DURATION)
            end
        end
    end

    for _, collisor in ipairs(col_character) do
        Collider.checkCollisionsNear(
            collisor, self.character.pos, col_tiles, self.map.spawn,
            function(i, j)
                local character = self.character
                local tile = self.map.tiles[i][j]

                local meta = getmetatable(tile)
                if meta == Wall then
                    avoidWall(character, tile)
                    dbg.print('Character collided with wall ' .. j)
                elseif meta == Muscle then
                    muscleImpulse(character, tile)
                    dbg.print('Character impulsioned by muscle ' .. j)
                end
            end
        )
    end

    -- Enemies x Walls
    for o, collisor in ipairs(col_enemies) do
        Collider.checkCollisionsNear(
            collisor, self.enemies[o].pos, col_tiles, self.map.spawn,
            function(i, j)
                local enemy = self.enemies[o]
                local tile = self.map.tiles[i][j]

                local meta = getmetatable(tile)
                if meta == Wall then
                    avoidWall(enemy, tile)
                    dbg.print(('Enemy %d collided with wall %d'):format(i, j))
                elseif meta == Muscle then
                    muscleImpulse(enemy, tile)
                    dbg.print(('Enemy %d impulsioned by muscle %d'):format(i, j))
                end
            end
        )
    end

    -- Character Bullets x Walls
    for o, collisor in ipairs(col_character_bullets) do
        Collider.checkCollisionsNear(
            collisor, self.bullets.character[o].pos, col_tiles, self.map.spawn,
            function(i, j)
                local bullet = self.bullets.character[o]
                local tile = self.map.tiles[i][j]

                local meta = getmetatable(tile)
                if meta == Wall then
                    bullet:kill()
                end
            end
        )
    end

    -- Enemies Bullets x Walls
    for o, collisor in ipairs(col_enemies_bullets) do
        Collider.checkCollisionsNear(
            collisor, self.bullets.enemies[o].pos, col_tiles, self.map.spawn,
            function(i, j)
                local bullet = self.bullets.enemies[o]
                local tile = self.map.tiles[i][j]

                local meta = getmetatable(tile)
                if meta == Wall then
                    bullet:kill()
                end
            end
        )
    end

    -- Character Bullets x Enemies
    Collider.checkCollisionsNtoM(
        col_enemies, col_character_bullets,
        function(i, j)
            local enemy = self.enemies[i]
            local bullet = self.bullets.character[j]

            enemy:damage()
            bullet:damage()
        end
    )

    -- Enemies Bullets x Character
    Collider.checkCollisionsNtoM(
        col_character, col_enemies_bullets,
        function(_, j)
            local character = self.character
            local bullet = self.bullets.enemies[j]

            character:damage()
            bullet:damage()
        end
    )

    -- Character x Enemies
    Collider.checkCollisionsNtoM(
        col_character, col_enemies,
        function(_, j)
            local character = self.character
            local enemy = self.enemies[j]

            if not enemy:isAlive() then return end

            character:damage(1)
            enemy:damage(5)
        end
    )

    dbg.log.collisions(
        'Custom', '%d x %d <= %d',
        #col_enemies, #self.level.area
    )
    for i, col_enemy in ipairs(col_enemies) do
        local collide = false
        for _, col in ipairs(col_area) do
            if col_enemy:collision(col) then
                collide = true
                break
            end
        end
        self.enemies[i].insideArea = collide
    end


    -- Spwaning enemies
    local l_enemies = self.level.enemies
    while l_enemies.i <= #l_enemies.list and #self.enemies < l_enemies.max do
        local randidx = love.math.random(#self.level.area)
        local randarea = self.level.area[randidx]

        local Class = l_enemies.list[l_enemies.i]
        inspect{Class, 'class'}
        local enemy = Class(randarea:randomPoint())
        local collides = false
        Collider.checkCollisionsNear(
            enemy:collider(), enemy.pos,
            col_tiles, self.map.spawn,
            function(i, j)
                if getmetatable(self.map.tiles[i][j]) == Wall then
                    collides = true
                end
            end
        )

        if collides then
            return
        end

        l_enemies.i = l_enemies.i + 1
        self.enemies[#self.enemies + 1] = enemy
    end

    if not self.character:isAlive() then
        self.state.gameover = true
    end
end

function M:clean()
    local function cleanDead(list)
        local res = {}
        for _, object in ipairs(list) do
            if object:isAlive() then
                res[#res + 1] = object
            end
        end
        return res
    end

    self.timers.clean:clock(function()
        self.bullets.character = cleanDead(self.bullets.character)
        self.bullets.enemies = cleanDead(self.bullets.enemies)
        self.enemies = cleanDead(self.enemies)
    end)
end

function M:isLevelConcluded()
    return #self.enemies == 0
        and self.level.enemies.i > #self.level.enemies.list
end

return M
