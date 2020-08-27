local test = require('luatest')
local group = test.group('cluster')

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

local function http_request(alias, method, endpoint, count)
    if count <= 0 then
        return
    end

    for _ = 1, count do
        group.cluster:server(alias):http_request(method, endpoint, { raise = false })
    end
end

local last_key = {
    ['tnt-router'] = 1,
    ['tnt-storage-1-master'] = 1,
    ['tnt-storage-2-master'] = 1,
}

local charset = {} -- [0-9a-zA-Z]
for c = 48, 57  do table.insert(charset, string.char(c)) end
for c = 65, 90  do table.insert(charset, string.char(c)) end
for c = 97, 122 do table.insert(charset, string.char(c)) end

local function random_string(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return random_string(length - 1) .. charset[math.random(1, #charset)]
end

local function space_operations(alias, operation, count)
    if count <= 0 then
        return
    end

    local space = group.cluster:server(alias).net_box.space.MY_SPACE

    if operation == 'select' then
        for _ = 1, count do
            space[operation](space, {}, { limit = 1 })
        end

    elseif operation == 'insert' then
        for _ = 1, count do
            space[operation](space, { last_key[alias], random_string(5) })
            last_key[alias] = last_key[alias] + 1
        end

    elseif operation == 'update' then
        for _ = 1, count do
            local key = space:select({}, { limit = 1 })[1][1]
            space[operation](space, key, {{ '=', 2, random_string(5) }})
        end

    elseif operation == 'upsert' then
        for _ = 1, count do
            local tuple = space:select({}, { limit = 1 })[1]
            space[operation](space, tuple, {{ '=', 2, random_string(5) }})
        end

    elseif operation == 'replace' then
        for _ = 1, count do
            local key = space:select({}, { limit = 1 })[1][1]
            space[operation](space, { key, random_string(5) })
        end

    elseif operation == 'delete' then
        for _ = 1, count do
            local key = space:select({}, { limit = 1 })[1][1]
            space[operation](space, { key })
        end
    end
end

group.test_cluster = function()
    test.helpers.retrying({ timeout = math.huge },
        function()
            -- Generate some HTTP traffic
            http_request('tnt-router', 'get', '/hello', math.random(5, 10))
            http_request('tnt-router', 'get', '/hell0', math.random(1, 2))
            http_request('tnt-router', 'post', '/goodbye', math.random(0, 1))
            http_request('tnt-storage-1-master', 'get', '/hello', math.random(2, 5))
            http_request('tnt-storage-1-master', 'get', '/hell0', math.random(0, 1))
            http_request('tnt-storage-1-master', 'post', '/goodbye', math.random(0, 1))
            http_request('tnt-storage-1-replica', 'get', '/hello', math.random(1, 3))
            http_request('tnt-storage-1-replica', 'get', '/hell0', math.random(0, 1))
            http_request('tnt-storage-1-replica', 'post', '/goodbye', math.random(0, 1))
            http_request('tnt-storage-2-master', 'get', '/hello', math.random(2, 5))
            http_request('tnt-storage-2-master', 'get', '/hell0', math.random(0, 1))
            http_request('tnt-storage-2-master', 'post', '/goodbye', math.random(0, 1))
            http_request('tnt-storage-2-replica', 'get', '/hello', math.random(1, 3))
            http_request('tnt-storage-2-replica', 'get', '/hell0', math.random(0, 1))
            http_request('tnt-storage-2-replica', 'post', '/goodbye', math.random(0, 1))

            -- Generate some space traffic
            space_operations('tnt-router', 'insert', math.random(1, 3))
            space_operations('tnt-router', 'update', math.random(1, 3))
            space_operations('tnt-storage-1-master', 'insert', math.random(5, 10))
            space_operations('tnt-storage-1-master', 'select', math.random(10, 20))
            space_operations('tnt-storage-1-master', 'update', math.random(5, 10))
            space_operations('tnt-storage-1-master', 'upsert', math.random(5, 10))
            space_operations('tnt-storage-1-master', 'replace', math.random(5, 10))
            space_operations('tnt-storage-1-master', 'delete', math.random(1, 2))
            space_operations('tnt-storage-1-replica', 'select', math.random(3, 5))
            space_operations('tnt-storage-2-master', 'insert', math.random(5, 10))
            space_operations('tnt-storage-2-master', 'select', math.random(10, 20))
            space_operations('tnt-storage-2-master', 'update', math.random(5, 10))
            space_operations('tnt-storage-2-master', 'upsert', math.random(5, 10))
            space_operations('tnt-storage-2-master', 'replace', math.random(5, 10))
            space_operations('tnt-storage-2-master', 'delete', math.random(1, 2))
            space_operations('tnt-storage-2-replica', 'select', math.random(3, 5))

            -- Fail this function so cluster don't stop
            error('running cluster')
        end
    )
end
