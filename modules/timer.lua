--- Watch
local Watch = {}
Watch.__index = Watch

local function new(_)
    local self = {time = 0}

    return setmetatable(self, T)
end

function Watch:update(dt)
    self.time = self.time + dt
end

function Watch:reset()
    self.time = 0
end

function Watch:decrease(value)
    self.time = self.time - value
end

--- Interval Timer
local Timer = {}
Timer.__index = Timer

local function new(_, duration)
    local self = {
        time = 0,
        duration = duration,
    }

    return setmetatable(self, Timer)
end
setmetatable(Timer, {__call = new})


function Timer:update(dt)
    self.time = self.time + dt
end

function Timer:clock(f, ...)
    while self.time > self.duration do
        self.time = self.time - self.duration
        f(...)
    end
end

--- Cool Down Timer
local CoolDown = {}
CoolDown.__index = CoolDown

local function new(_, duration)
    local self = {
        time = 0,
        duration = duration,
        active = false,
    }

    return setmetatable(self, CoolDown)
end
setmetatable(CoolDown, {__call = new})

function CoolDown:update(dt)
    if self.active then
        self.time = self.time + dt
    end
end

function CoolDown:clock(f, ...)
    if not self.active then
        f(...)
        self.time = 0
        self.active = true
    elseif self.time > self.duration then
        self.active = false
    end
end

--- Span Timer
local Span = {}
Span.__index = Span

local function new(_, duration)
    local self = {
        time = 0,
        duration = duration,
        active = true,
    }

    return setmetatable(self, Span)
end
setmetatable(Span, {__call = new})

function Span:update(dt)
    if self.active then
        self.time = self.time + dt
    end
end

function Span:clock(f, ...)
    if self.time < self.duration then
        f(...)
    else
        self.active = false
    end
end

return {
    Watch = Watch,
    --- Interval Timer
    Timer = Timer,
    --- Cool Down Timer
    CoolDown = CoolDown,
    -- CountDown
    Span = Span,
}
