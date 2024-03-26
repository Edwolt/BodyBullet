local Input = require'modules.Input'
local Vec = require'modules.Vec'

SETTINGS = {
    TILES = 15,

    SPECIALKEY_COOLDOWN = 0.2,
    CLEAN_TIMING = 1.0,

    CHARACTER_VELOCITY = 10,
    ENEMY_VELOCITY = 3,
    BULLET_VELOCITY = 13,

    EVILNESS = 0.5,

    MUSCLE_TIMING = 1.0,
    IMPULSE_DURATION = 0.2,
    IMPULSE_VELOCITY = Vec(0, 30),

    BULLET_TIME_LIMIT = 0.7,

    SHOOT_COOLDOWN = 0.1,

    DASH_COOLDOWN = 2.0,
    DASH_DURATION = 0.2,
    DASH_DISTANCE_LIMIT = 12,

    TRANSFORMATION = nil, -- To be set during load
}

SETTINGS.Input = Input()

return SETTINGS
