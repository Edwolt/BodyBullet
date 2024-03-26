local clone = require'utils.clone'

local Vec = require'modules.Vec'
local Collider = require'modules.Collider'
local colors = require'modules.colors'

local Wall = require'tiles.Wall'
local Air = require'tiles.Air'


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

local walls = {}
for i = 1, n do
    walls[2 * i - 1] = {}
    walls[2 * i] = {}
    for j = 1, m do
        if map[i][j] == 1 then
            walls[2 * i - 1][2 * j - 1] = Wall(Vec(2 * i - 1, 2 * j - 1) - spawn)
            walls[2 * i - 0][2 * j - 1] = Wall(Vec(2 * i - 0, 2 * j - 1) - spawn)
            walls[2 * i - 1][2 * j - 0] = Wall(Vec(2 * i - 1, 2 * j - 0) - spawn)
            walls[2 * i - 0][2 * j - 0] = Wall(Vec(2 * i - 0, 2 * j - 0) - spawn)
        else
            walls[2 * i - 1][2 * j - 1] = Air(Vec(2 * i - 1, 2 * j - 1) - spawn)
            walls[2 * i - 0][2 * j - 1] = Air(Vec(2 * i - 0, 2 * j - 1) - spawn)
            walls[2 * i - 1][2 * j - 0] = Air(Vec(2 * i - 1, 2 * j - 0) - spawn)
            walls[2 * i - 0][2 * j - 0] = Air(Vec(2 * i - 0, 2 * j - 0) - spawn)
        end
    end
end

local M = {
    spawn = spawn,
    walls = walls,
    levels = {
        legs = {
            enemies_left = 30,
            max_enemies = 10,
            area = {
                Collider(Vec(-14, -11), Vec(29, 28)),
            },
        },
    },
}

function M:draw()
    dbg.log.enter'Map Draw'
    for _, l in ipairs(self.walls) do
        for _, wall in ipairs(l) do
            wall:draw()
        end
    end
    dbg.log.exit'Map Draw'
end

function M:drawDebug()
    for _, l in ipairs(self.walls) do
        for _, wall in ipairs(l) do
            if getmetatable(wall) ~= Air then
                wall:collider():draw(colors.RED)
            end
        end
    end
end

function M:update(dt)
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
