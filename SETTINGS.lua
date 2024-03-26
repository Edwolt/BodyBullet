local Input = require'modules.Input'
local Vec = require'modules.Vec'

SETTINGS = {
    SPECIALKEY_COOLDOWN = 0.2,
    SHOOT_COOLDOWN = 0.1,
    DASH_COOLDOWN = 3.0,
    MUSCLE_TIMING = 1.0,
    CLEAN_TIMING = 1.0,
    IMPULSE_DURATION = 0.2,
    BULLET_TIME_LIMIT = 0.7,

    CHARACTER_VELOCITY = 10,
    ENEMY_VELOCITY = 3,
    BULLET_VELOCITY = 13,
    IMPULSE_VELOCITY = Vec(0, 30),

    EVILNESS = 0.5,

    TILES = 15,

    -- To be set during load
    TRANSFORMATION = nil,
}

SETTINGS.Input = Input()

return SETTINGS
