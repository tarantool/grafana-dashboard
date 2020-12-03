local test = require('luatest')
local group = test.group('cluster')

local helper = require('test.helper')
local cluster_helpers = require('cartridge.test-helpers')

local app = 'example-app'
local log_level = 6

local cluster_alias = {
    tnt_router = 'tnt_router',
    tnt_storage_1_master = 'tnt_storage_1_master',
    tnt_storage_1_replica = 'tnt_storage_1_replica',
    tnt_storage_2_master = 'tnt_storage_2_master',
    tnt_storage_2_replica = 'tnt_storage_2_replica',
}

local instances = {}

local replicasets = {
    {
        uuid = cluster_helpers.uuid('a'),
        roles = { 'vshard-router', 'app.roles.custom' },
        servers = {
            {
                instance_uuid = cluster_helpers.uuid('a', 1),
                alias = cluster_alias.tnt_router,
                env = {
                    ['TARANTOOL_APP_NAME'] = app,
                    ['TARANTOOL_LOG_LEVEL'] = log_level,
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
                alias = cluster_alias.tnt_storage_1_master,
                env = {
                    ['TARANTOOL_APP_NAME'] = app,
                    ['TARANTOOL_LOG_LEVEL'] = log_level,
                }
            },
            {
                instance_uuid = cluster_helpers.uuid('b', 2),
                alias = cluster_alias.tnt_storage_1_replica,
                env = {
                    ['TARANTOOL_APP_NAME'] = app,
                    ['TARANTOOL_LOG_LEVEL'] = log_level,
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
                alias = cluster_alias.tnt_storage_2_master,
                env = {
                    ['TARANTOOL_APP_NAME'] = app,
                    ['TARANTOOL_LOG_LEVEL'] = log_level,
                }
            },
            {
                instance_uuid = cluster_helpers.uuid('c', 2),
                alias = cluster_alias.tnt_storage_2_replica,
                env = {
                    ['TARANTOOL_APP_NAME'] = app,
                    ['TARANTOOL_LOG_LEVEL'] = log_level,
                }
            }
        },
    }
}

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
                    path = '/metrics/json',
                    format = 'json'
                },
                {
                    path = '/metrics/prometheus',
                    format = 'prometheus'
                }
            }
        }
    })

    for instance, alias in pairs(cluster_alias) do
        instances[instance] = group.cluster:server(alias)
    end
end)

test.after_suite(function()
    group.cluster:stop()
end)

-- Space operations constants
local SELECT = 'select'
local INSERT = 'insert'
local UPDATE = 'update'
local UPSERT = 'upsert'
local REPLACE = 'replace'
local DELETE = 'delete'

-- HTTP methods constants
local GET = 'get'
local POST = 'post'

local function http_request(server, method, endpoint, count)
    if count <= 0 then
        return
    end

    for _ = 1, count do
        server:http_request(method, endpoint, { raise = false })
    end
end

local last_key = 1

local charset = {} -- [0-9a-zA-Z]
for c = 48, 57  do table.insert(charset, string.char(c)) end
for c = 65, 90  do table.insert(charset, string.char(c)) end
for c = 97, 122 do table.insert(charset, string.char(c)) end

local function random_string(length)
    if not length or length <= 0 then return '' end
    math.randomseed(os.clock()^5)
    return random_string(length - 1) .. charset[math.random(1, #charset)]
end

local function space_operations(server, operation, count)
    if count <= 0 then
        return
    end

    local space = server.net_box.space.MY_SPACE

    if operation == SELECT then
        for _ = 1, count do
            space:select({}, { limit = 1 })
        end

    elseif operation == INSERT then
        for _ = 1, count do
            space:insert{ last_key, random_string(5) }
            last_key = last_key + 1
        end

    elseif operation == UPDATE then
        for _ = 1, count do
            local key = space:select({}, { limit = 1 })[1][1]
            space:update(key, {{ '=', 2, random_string(5) }})
        end

    elseif operation == UPSERT then
        for _ = 1, count do
            local tuple = space:select({}, { limit = 1 })[1]
            space:upsert(tuple, {{ '=', 2, random_string(5) }})
        end

    elseif operation == REPLACE then
        for _ = 1, count do
            local key = space:select({}, { limit = 1 })[1][1]
            space:replace{ key, random_string(5) }
        end

    elseif operation == DELETE then
        for _ = 1, count do
            local key = space:select({}, { limit = 1 })[1][1]
            space:delete{ key }
        end
    end
end

group.test_cluster = function()
    test.helpers.retrying({ timeout = math.huge },
        function()
            -- Generate some HTTP traffic
            http_request(instances.tnt_router, GET, '/hello', math.random(5, 10))
            http_request(instances.tnt_router, GET, '/hell0', math.random(1, 2))
            http_request(instances.tnt_router, POST, '/goodbye', math.random(0, 1))
            http_request(instances.tnt_storage_1_master, GET, '/hello', math.random(2, 5))
            http_request(instances.tnt_storage_1_master, GET, '/hell0', math.random(0, 1))
            http_request(instances.tnt_storage_1_master, POST, '/goodbye', math.random(0, 1))
            http_request(instances.tnt_storage_1_replica, GET, '/hello', math.random(1, 3))
            http_request(instances.tnt_storage_1_replica, GET, '/hell0', math.random(0, 1))
            http_request(instances.tnt_storage_1_replica, POST, '/goodbye', math.random(0, 1))
            http_request(instances.tnt_storage_2_master, GET, '/hello', math.random(2, 5))
            http_request(instances.tnt_storage_2_master, GET, '/hell0', math.random(0, 1))
            http_request(instances.tnt_storage_2_master, POST, '/goodbye', math.random(0, 1))
            http_request(instances.tnt_storage_2_replica, GET, '/hello', math.random(1, 3))
            http_request(instances.tnt_storage_2_replica, GET, '/hell0', math.random(0, 1))
            http_request(instances.tnt_storage_2_replica, POST, '/goodbye', math.random(0, 1))

            -- Generate some space traffic
            space_operations(instances.tnt_router, INSERT, math.random(1, 3))
            space_operations(instances.tnt_router, UPDATE, math.random(1, 3))
            space_operations(instances.tnt_storage_1_master, INSERT, math.random(5, 10))
            space_operations(instances.tnt_storage_1_master, SELECT, math.random(10, 20))
            space_operations(instances.tnt_storage_1_master, UPDATE, math.random(5, 10))
            space_operations(instances.tnt_storage_1_master, UPSERT, math.random(5, 10))
            space_operations(instances.tnt_storage_1_master, REPLACE, math.random(5, 10))
            space_operations(instances.tnt_storage_1_master, DELETE, math.random(1, 2))
            space_operations(instances.tnt_storage_1_replica, SELECT, math.random(3, 5))
            space_operations(instances.tnt_storage_2_master, INSERT, math.random(5, 10))
            space_operations(instances.tnt_storage_2_master, SELECT, math.random(10, 20))
            space_operations(instances.tnt_storage_2_master, UPDATE, math.random(5, 10))
            space_operations(instances.tnt_storage_2_master, UPSERT, math.random(5, 10))
            space_operations(instances.tnt_storage_2_master, REPLACE, math.random(5, 10))
            space_operations(instances.tnt_storage_2_master, DELETE, math.random(1, 2))
            space_operations(instances.tnt_storage_2_replica, SELECT, math.random(3, 5))

            -- Fail this function so cluster don't stop
            error('running cluster')
        end
    )
end
