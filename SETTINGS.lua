local Input = require'modules.Input'

SETTINGS = {
    SPECIALKEY_COOLDOWN = 0.2,
    BULLET_COOLDOWN = 0.3,

    CHARACTER_VELOCITY = 10,
    ENEMY_VELOCITY = 5,
    BULLET_VELOCITY = 15,
    BULLET_TIME_LIMIT = 0.7,

    EVILNESS = 0.5,

    TILES = 15,

    -- To be set during load
    TRANSFORMATION = nil,
}

SETTINGS.Input = Input()

return SETTINGS
