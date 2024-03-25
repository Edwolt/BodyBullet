-- Globals
dbg = require'utils.dbg'
inspect = dbg.inspect
require'SETTINGS'

local colors = require'modules.color'
local Game = require'Game'
local Key = SETTINGS.Key

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
    game:draw()
end

function love.update(dt)
    Key:update(dt)
    game:keydown()
    game.update(dt)
end
