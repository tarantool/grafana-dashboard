local crud = require('crud')

local function init(opts) -- luacheck: no unused args
    crud.cfg{
        stats = true,
        stats_driver = 'metrics',
        stats_quantiles = true,
    }

    rawset(_G, 'crud', crud)

    return true
end

local function stop()
end

local function validate_config(conf_new, conf_old) -- luacheck: no unused args
    return true
end

local function apply_config(conf, opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end

    return true
end

return {
    role_name = 'app.roles.router',
    dependencies = {
        'app.roles.custom',
        'cartridge.roles.metrics',
        'cartridge.roles.crud-router',
    },
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
}
