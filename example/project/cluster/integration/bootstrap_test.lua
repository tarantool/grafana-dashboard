local test = require('luatest')
local group = test.group('cluster')
local fiber = require('fiber')

local helper = require('test.helper')
local cluster_helpers = require('cartridge.test-helpers')

local replicasets = {
    {
        uuid = cluster_helpers.uuid('a'),
        roles = { 'vshard-router', 'app.roles.custom' },
        servers = {
            {
                instance_uuid = cluster_helpers.uuid('a', 1),
                alias = 'tnt-router',
                env = {
                    ['TARANTOOL_APP_NAME'] = 'example-app',
                    ['TARANTOOL_LOG_LEVEL'] = 6,
                }
            }
        },
    },
    {
        uuid = cluster_helpers.uuid('b'),
        roles = { 'vshard-storage', 'app.roles.custom' },
        servers = {
            {
                instance_uuid = cluster_helpers.uuid('b', 1),
                alias = 'tnt-storage-1-master',
                env = {
                    ['TARANTOOL_APP_NAME'] = 'example-app',
                    ['TARANTOOL_LOG_LEVEL'] = 6,
                }
            },
            {
                instance_uuid = cluster_helpers.uuid('b', 2),
                alias = 'tnt-storage-1-replica',
                env = {
                    ['TARANTOOL_APP_NAME'] = 'example-app',
                    ['TARANTOOL_LOG_LEVEL'] = 6,
                }
            },
        }
    },
    {
        uuid = cluster_helpers.uuid('c'),
        roles = { 'vshard-storage', 'app.roles.custom' },
        servers = {
            {
                instance_uuid = cluster_helpers.uuid('c', 1),
                alias = 'tnt-storage-2-master',
                env = {
                    ['TARANTOOL_APP_NAME'] = 'example-app',
                    ['TARANTOOL_LOG_LEVEL'] = 6,
                }
            },
            {
                instance_uuid = cluster_helpers.uuid('c', 2),
                alias = 'tnt-storage-2-replica',
                env = {
                    ['TARANTOOL_APP_NAME'] = 'example-app',
                    ['TARANTOOL_LOG_LEVEL'] = 6,
                }
            }
        },
    }
}

local instances = {}
for _, replicaset in ipairs(replicasets) do
    for _, server in ipairs(replicaset.servers) do
        table.insert(instances, server.alias)
    end
end

test.before_suite(function()
    group.cluster = cluster_helpers.Cluster:new({
        datadir = helper.datadir,
        server_command = helper.server_command,
        use_vshard = true,
        replicasets = replicasets
    })

    group.cluster:start()
    group.cluster:upload_config({
        metrics = {
            export = {
                {
                    path = '/metrics',
                    format = 'json'
                },
                {
                    path = '/metrics/prometheus',
                    format = 'prometheus'
                }
            }
        }
    })
end)

test.after_suite(function()
    group.cluster:stop()
end)

local function http_request(alias, count)
    if count <= 0 then
        return
    end

    for _ = 1, count do
        group.cluster:server(alias):http_request('get', '/hello')
    end
end

group.test_cluster = function()
    test.helpers.retrying({ timeout = math.huge },
        function()
            fiber.sleep(10)

            -- Generate some traffic
            for _, alias in ipairs(instances) do
                http_request(alias, math.random(0, 5))
            end

            -- Fail this function so cluster don't stop
            error('running cluster')
        end
    )
end
