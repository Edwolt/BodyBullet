local Input = require'modules.Input'
SETTINGS = {
    SPECIALKEY_COOLDOWN = 0.2,

    -- To be set during load
    tranformation = nil,
}

SETTINGS.Input = Input()


return SETTINGS
