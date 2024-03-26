return {
    print = print,
    log = {
        load = function(name)
            print(('> Loading %s ...'):format(name))
        end,

        loaded = function(name)
            print(('> Loaded %s'):format(name))
        end,

        loadedv = function(name, value)
            print(('> Loaded %s = %s'):format(name, tostring(value)))
        end,

        save = function(name, value)
            print(('> Saving %s = %s'):format(name, tostring(value)))
        end,

        saved = function(name)
            print(('> Saved %s'):format(name))
        end,

        enter = function(name)
            print(('> Entering %s ...'):format(name))
        end,

        exit = function(name)
            print(('> Exited %s'):format(name))
        end,

        checkCollisions = function(str, ...)
            local mul = 1
            for _, i in ipairs{...} do
                mul = i * mul
            end
            print(('* Checking Collision ' .. str):format(..., mul))
        end,
    },
    inspect = function(opts)
        local value = opts[1]
        local name = opts[2] and opts[2] .. ' = ' or ''
        local show_meta = opts.meta or false

        if type(value) == 'table' then
            print(name .. '{')

            for ki, i in pairs(value) do
                print(('  %s = %s'):format(tostring(ki), tostring(i)))
            end

            if show_meta then
                local meta = getmetatable(value)
                for ki, i in pairs(meta) do
                    print((' $%s = %s'):format(tostring(ki), tostring(i)))
                end
            end

            print'}'
        else
            print(name .. tostring(value))
        end
    end,
}
