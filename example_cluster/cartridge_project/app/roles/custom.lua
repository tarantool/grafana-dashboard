local cartridge = require('cartridge')
local config = require('cartridge.argparse')
local fiber = require('fiber')

local function init(opts)
    local local_cfg = config.get_opts({
        user = 'string',
        password = 'string'
    })

    local metrics = cartridge.service_get('metrics')
    local http_middleware = metrics.http_middleware

    http_middleware.configure_default_collector('summary')

    local httpd = cartridge.service_get('httpd')
    httpd:route(
        { method = 'GET', path = '/hello' },
        http_middleware.v1(
            function()
                fiber.sleep(0.02)
                return { status = 200, body = 'Hello world!' }
            end
        )
    )
    httpd:route(
        { method = 'GET', path = '/hell0' },
        http_middleware.v1(
            function()
                fiber.sleep(0.01)
                return { status = 400, body = 'Hell0 world!' }
            end
        )
    )
    httpd:route(
        { method = 'POST', path = '/goodbye' },
        http_middleware.v1(
            function()
                fiber.sleep(0.005)
                return { status = 500, body = 'Goodbye cruel world!' }
            end
        )
    )

    if opts.is_master then
        local sp = box.schema.space.create('MY_SPACE', { if_not_exists = true })
        sp:format({
            { name = 'key', type = 'number', is_nullable = false },
            { name = 'value', type = 'string', is_nullable = false },
        })
        sp:create_index('pk', { parts = { 'key' }, if_not_exists = true })

        local v_sp = box.schema.space.create('MY_VINYL_SPACE', { if_not_exists = true, engine = 'vinyl' })
        v_sp:format({
            { name = 'key', type = 'number', is_nullable = false },
            { name = 'value', type = 'string', is_nullable = false },
        })
        v_sp:create_index('pk', { parts = { 'key' }, if_not_exists = true })

        if local_cfg.user and local_cfg.password then
            -- cluster-wide user privileges
            box.schema.user.create(local_cfg.user, { password = local_cfg.password, if_not_exists = true })
            box.schema.user.grant(local_cfg.user, 'read,write,execute', 'universe', nil, { if_not_exists = true })
        end
    end

    rawset(_G, 'include_vinyl_count', true)

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
