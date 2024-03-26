-- Globals
dbg = require'utils.dbg'
inspect = dbg.inspect
require'SETTINGS'

local Game = require'Game'
local Input = SETTINGS.Input

local Vec = require'modules.Vec'
local colors = require'modules.colors'

local game

function love.load()
    dbg.print'GameJam'
    dbg.print(_VERSION)
    dbg.inspect{SETTINGS, 'SETTINGS'}

    dbg.log.load'main'
    -- Configure Lua
    love.graphics.setDefaultFilter('nearest', 'nearest', 0)
    love.graphics.setBackgroundColor(colors.WHITE)

    love.window.setTitle'Body Bullet'
    love.window.setMode(
        800, 800,
        {
            msaa = 0,
            resizable = true,
            borderless = true,
        }
    )

    love.mouse.setGrabbed(true)
    love.mouse.setVisible(false)

    -- Calculate tranformation
    local tranformation = love.math.newTransform()
    local screen_size = Vec.windowSize()
    local tiles = SETTINGS.TILES
    tranformation:scale(screen_size.x / tiles, screen_size.y / tiles)
    tranformation:translate(tiles / 2, tiles / 2)
    SETTINGS.TRANSFORMATION = tranformation

    -- Instatiate Game
    game = Game()

    dbg.log.loaded'main'
    dbg.print()
end

function love.draw()
    dbg.log.enter'Draw'
    love.graphics.push()
    love.graphics.replaceTransform(SETTINGS.TRANSFORMATION)

    game:draw()

    love.graphics.pop()
    dbg.log.exit'Draw'
    dbg.print()
end

function love.update(dt)
    dbg.log.enter'Update'
    if game.state.gameover then
        game = Game()
    end

    Input:update(dt)
    game:keydown()
    game:update(dt)

    dbg.log.exit'Update'
    dbg.print()
end
