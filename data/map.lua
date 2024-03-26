local clone = require'utils.clone'
local CheckPoint = require'objects.CheckPoint'
local Enemy = require'objects.Enemy'
local SquareEnemy = require'objects.SquareEnemy'


local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'

local Wall = require'tiles.Wall'
local Air = require'tiles.Air'
local Muscle = require'tiles.Muscle'

local halfmap = require'data.halfmap'

local map = {}
for i = #halfmap, 1, -1 do
    map[#map + 1] = clone(halfmap[i])
end
for i = 1, #halfmap do
    map[#map + 1] = clone(halfmap[i])
end


local n, m = #map, #map[1]
local spawn = Vec(84.5, 154)

local tiles = {}
for i = 1, n do
    tiles[2 * i - 1] = {}
    tiles[2 * i] = {}
    for j = 1, m do
        local Class
        if map[i][j] == 0 then
            Class = Air
        elseif map[i][j] == 1 then
            Class = Wall
        elseif map[i][j] == 2 then
            -- Muscle Down
            Class = function(pos) return Muscle(pos, 'down') end
        elseif map[i][j] == 3 then
            -- Muscle Up
            Class = function(pos) return Muscle(pos, 'up') end
        end

        tiles[2 * i - 1][2 * j - 1] = Class(Vec(2 * i - 1, 2 * j - 1) - spawn)
        tiles[2 * i - 0][2 * j - 1] = Class(Vec(2 * i - 0, 2 * j - 1) - spawn)
        tiles[2 * i - 1][2 * j - 0] = Class(Vec(2 * i - 1, 2 * j - 0) - spawn)
        tiles[2 * i - 0][2 * j - 0] = Class(Vec(2 * i - 0, 2 * j - 0) - spawn)
    end
end

local function repeatList(val, tab)
    local res = {}
    for _ = 1, val do
        for _, cell in ipairs(tab) do
            res[#res + 1] = cell
        end
    end
    return res
end

local M = {
    spawn = spawn,
    tiles = tiles,
    levels = {
        -- Making a function avoid changing values
        legs = function()
            return {
                enemies = {
                    i = 1,
                    max = 10,
                    list = repeatList(30, {Enemy}),
                },
                area = {
                    Collider(Vec(-14, -11), Vec(29, 28)),
                },
                checkpoint = CheckPoint(Vec(0.5, 0.5)),
            }
        end,
        stomach = function()
            return {
                enemies = {
                    i = 1,
                    max = 10,
                    list = repeatList(6, {Enemy, Enemy, Enemy, Enemy, SquareEnemy}),
                },
                area = {
                    Collider(Vec(3, -48), Vec(8, 9)),
                    Collider(Vec(-10, -40), Vec(23, 15)),
                    Collider(Vec(-20, -35), Vec(10, 5)),
                },
                checkpoint = CheckPoint(Vec(4, -33)),
            }
        end,
    },
}

function M:draw()
    dbg.log.enter'Map Draw'
    for _, l in ipairs(self.tiles) do
        for _, tile in ipairs(l) do
            tile:draw()
        end
    end
    dbg.log.exit'Map Draw'
end

function M:drawDistant()
    dbg.log.enter'Map Draw'
    for _, l in ipairs(self.tiles) do
        for _, tile in ipairs(l) do
            if getmetatable(tile) == Wall then
                tile:draw()
            end
        end
    end
    dbg.log.exit'Map Draw'
end

function M:drawDebug()
    for _, l in ipairs(self.tiles) do
        for _, tile in ipairs(l) do
            if getmetatable(tile) ~= Air then
                tile:collider():draw(colors.RED)
            end
        end
    end
end

function M:update(dt)
    for _, l in ipairs(self.tiles) do
        for _, tile in ipairs(l) do
            tile:update(dt)
        end
    end
end

function M.matrixColliders(list)
    local res = {}
    for i, l in ipairs(list) do
        res[i] = {}
        for j, obj in ipairs(l) do
            res[i][j] = obj:collider()
        end
    end
    return res
end

return M
