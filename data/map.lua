local Vec = require'modules.Vec'
local colors = require'modules.colors'

local Wall = require'tiles.Wall'
local Air = require'tiles.Air'

local map = {
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
    {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1},
    {1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

local n, m = #map, #map[1]
local spawn = Vec(math.floor(n / 2), math.floor(m / 2))

local walls = {}
for i = 1, n do
    walls[i] = {}
    for j = 1, m do
        if map[i][j] == 1 then
            walls[i][j] = Wall(Vec(i, j) - spawn)
        else
            walls[i][j] = Air(Vec(i, j) - spawn)
        end
    end
end

local M = {
    spawn = spawn,
    walls = walls,
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
            wall:collider():draw(colors.RED)
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
