local fiber = require('fiber')
local metrics = require('metrics')
local json_exporter = require('metrics.plugins.json')
local prometheus_exporter = require('metrics.plugins.prometheus')

local http_server = require('http.server')

local httpd

local function parse(listen)
    local parts = listen:split(':')
    return parts[1], tonumber(parts[2])
end

local function validate(cfg)
    assert(type(cfg.listen) == 'string')
    local host, port = parse(cfg.listen)
    assert(type(host) == 'string')
    assert(host ~= '')
    assert(port ~= 0)
end

local function apply(cfg)
    if httpd ~= nil then
        return
    end

    fiber.leak_backtrace_enable()

    local host, port = parse(cfg.listen)
    httpd = http_server.new(host, port)

    httpd:route(
        { method = 'GET', path = '/metrics/prometheus' },
        prometheus_exporter.collect_http
    )

    httpd:route(
        { method = 'GET', path = '/metrics/json' },
        function(request)
            return request:render({ text = json_exporter.export() })
        end
    )

    local http_middleware = metrics.http_middleware
    http_middleware.configure_default_collector('summary')

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

    httpd:start()

    local coordinator_status = metrics.gauge(
        'tarantool_coordinator_active',
        'Mock failover coordinator status'
    )
    local instance_status = metrics.gauge(
        'tarantool_instance_status',
        'Mock failover coordinator visibility'
    )

    fiber.create(function()
        local uuid = require('uuid')

        local active = 1

        local uuid_a = tostring(uuid.new())
        local uuid_b = tostring(uuid.new())

        while true do
            coordinator_status:set(active, {
                alias = uuid_a,
            })
            coordinator_status:set((active + 1) % 2, {
                alias = uuid_b,
            })

            instance_status:set(1, {
                alias = uuid_a,
                replicaset = 'storages_1',
                instance = 'storage_1_master',
            })

            instance_status:set(1, {
                alias = uuid_a,
                replicaset = 'storages_2',
                instance = 'storage_2_master',
            })

            instance_status:set(1, {
                alias = uuid_b,
                replicaset = 'storages_1',
                instance = 'storage_1_replica',
            })

            instance_status:set(0, {
                alias = uuid_b,
                replicaset = 'storages_2',
                instance = 'storage_2_replica',
            })

            active = (active + 1) % 2
            fiber.sleep(5)
        end
    end)

    box.watch('box.status', function()
        if box.info.ro then
            return
        end

        box.ctl.promote()

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

        for _, space_name in ipairs({'customers', 'clients'}) do
            local space = box.schema.space.create(space_name, {
                format = {
                    {name = 'id', type = 'unsigned'},
                    {name = 'bucket_id', type = 'unsigned'},
                    {name = 'name', type = 'string'},
                    {name = 'age', type = 'number'},
                },
                if_not_exists = true,
                engine = 'memtx',
                is_sync = true,
            })
            -- Primary index.
            space:create_index('id_index', {
                parts = {{field = 'id'}},
                if_not_exists = true,
            })
            space:create_index('bucket_id', {
                parts = { {field = 'bucket_id'} },
                unique = false,
                if_not_exists = true,
            })
            space:create_index('name_index', {
                parts = { {field = 'name'} },
                unique = false,
                if_not_exists = true,
            })
        end
    end)

    rawset(_G, 'include_vinyl_count', true)
end

local function stop()
    if httpd ~= nil then
        httpd:stop()
        httpd = nil
    end
end

return {
    validate = validate,
    apply = apply,
    stop = stop,
}
