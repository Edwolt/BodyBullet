--- Module to manage Keyboard and Mouse inputs

local keyIsDown = love.keyboard.isDown
local timer = require'modules.timer'

local Vec = require'modules.Vec'


M = {}
M.__index = M

local function new(_)
    local SPECIALKEY_COOLDOWN = SETTINGS.SPECIALKEY_COOLDOWN
    local BULLET_COOLDOWN = SETTINGS.BULLET_COOLDOWN

    local self = {
        cooldown = {
            pause = timer.CoolDown(SPECIALKEY_COOLDOWN),
            fullscreen = timer.CoolDown(SPECIALKEY_COOLDOWN),
            debug = timer.CoolDown(SPECIALKEY_COOLDOWN),
            giveup = timer.CoolDown(SPECIALKEY_COOLDOWN),
            next = timer.CoolDown(SPECIALKEY_COOLDOWN),
            shoot = timer.CoolDown(BULLET_COOLDOWN),
        },
        shootPressed = false,
    }

    setmetatable(self, M)
    return self
end
setmetatable(M, {__call = new})

function M:update(dt)
    for _, cooldown in pairs(self.cooldown) do
        cooldown:update(dt)
    end
end

----- Special Keys -----

function M:quit(f, ...)
    if keyIsDown'escape' then
        f(...)
    end
end

function M:fullscreen(f, ...)
    if keyIsDown'f' or keyIsDown'f11' then
        self.cooldown.fullscreen:clock(function(...)
            f(...)
        end, ...)
    end
end

function M:debug(f, ...)
    if keyIsDown'kp5' then
        self.cooldown.debug:clock(function(...)
            f(...)
        end, ...)
    end
end

function M:giveup(f, ...)
    if keyIsDown'g' then
        self.cooldown.giveup:clock(function(...)
            f(...)
        end, ...)
    end
end

function M:next(f, ...)
    if keyIsDown'n' then
        self.cooldown.giveup:clock(function(...)
            f(...)
        end, ...)
    end
end

function M:fast(f, ...)
    if keyIsDown'p' then
        self.cooldown.giveup:clock(function(...)
            f(...)
        end, ...)
    end
end

----- Game keys -----

function M:left(f, ...)
    if keyIsDown'left' or keyIsDown'a' then
        f(...)
    end
end

function M:right(f, ...)
    if keyIsDown'right' or keyIsDown'd' then
        f(...)
    end
end

function M:down(f, ...)
    if keyIsDown'down' or keyIsDown's' then
        f(...)
    end
end

function M:up(f, ...)
    if keyIsDown'up' or keyIsDown'w' then
        f(...)
    end
end

function M:shoot(f, ...)
    if love.mouse.isDown(1) then
        self.cooldown.shoot:clock(function(...)
            f(Vec.mousePosition(), ...)
        end, ...)
    end
end

return M
