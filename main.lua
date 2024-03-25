-- Globals
dbg = require'utils.dbg'
inspect = dbg.inspect
require'SETTINGS'

local Game = require'Game'
local Key = SETTINGS.Key

local Vec = require'modules.Vec'
local colors = require'modules.color'

local game

function love.load()
    dbg.print'GameJam'
    dbg.print(_VERSION)
    dbg.inspect{SETTINGS, 'SETTINGS'}

    dbg.log.load'main'
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

    Game:load()
    game = Game()

    dbg.log.loaded'main'
    dbg.print()
end

function love.draw()
    love.graphics.push()

    screen_size = Vec.windowSize()
    local tiles = 15
    love.graphics.scale(screen_size.x / tiles, screen_size.y / tiles)
    love.graphics.translate(tiles / 2, tiles / 2)
    game:draw()

    love.graphics.pop()
end

function love.update(dt)
    Key:update(dt)
    game:keydown()
    game:update(dt)
end
