local Input = require'modules.Input'
local Vec = require'modules.Vec'
local Collider = require'module.Collider'

SETTINGS = {
    SPECIALKEY_COOLDOWN = 0.2,
    BULLET_COOLDOWN = 0.3,

    CHARACTER_VELOCITY = 10,
    ENEMY_VELOCITY = 5,
    BULLET_VELOCITY = 15,

    EVILNESS = 0.5,

    TILES = 15,

    -- To be set during load
    TRANFORMATION = nil,
}

SETTINGS.Input = Input()

function SETTINGS.bulletLimit(pos)
    return Collider(
        pos - 2 * Vec(SETTINGS.TILES, SETTINGS.TILES),
        4 * Vec(SETTINGS.TILES, SETTINGS.TILES),
    )
end

return SETTINGS
