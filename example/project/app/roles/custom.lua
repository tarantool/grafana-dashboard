local cartridge = require('cartridge')

local function init(opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end
    local metrics = cartridge.service_get('metrics')
    local http_middleware = metrics.http_middleware

    local http_collector = http_middleware.build_default_collector('average')

    local httpd = cartridge.service_get('httpd')
    httpd:route(
        { method = 'GET', path = '/hello' },
        http_middleware.v1(
            function()
                return { body = 'Hello world!' }
            end,
            http_collector
        )
    )

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
    role_name = 'app.roles.custom',
    dependencies = { 'cartridge.roles.metrics' },
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
}
