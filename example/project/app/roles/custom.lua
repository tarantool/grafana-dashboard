local cartridge = require('cartridge')
local metrics = require("metrics")
local json_metrics = require("metrics.plugins.json")
local prometheus = require("metrics.plugins.prometheus")
local http_middleware = metrics.http_middleware

metrics.set_global_labels({ alias = 'instance'})
metrics.enable_default_metrics()

local function init(opts) -- luacheck: no unused args
    -- if opts.is_master then
    -- end
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

    httpd:route(
        { method = 'GET', path = '/metrics' },
        http_middleware.v1(
            function(req)
                return req:render({ text = json_metrics.export() })
            end,
            http_collector
        )
    )

    httpd:route(
        { path = '/metrics/prometheus' },
        http_middleware.v1(
            prometheus.collect_http,
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
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
    -- dependencies = {'cartridge.roles.vshard-router'},
}
