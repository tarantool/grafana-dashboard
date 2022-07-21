local fio = require('fio')
local log = require('log')
local yaml = require('yaml')
local fiber = require('fiber')
local net_box = require('net.box')

local APP_HOST = 'app'


local http_client = require('http.client').new({max_connections = 5})

local function http_request(route, method, count)
    if count <= 0 then
        return
    end

    for _ = 1, count do
        http_client:request(method, route)
    end
end

local function generate_http_load(name, instance)
    if instance.http_uri == nil then
        return
    end

    local count_200, count_400

    if name:match('router') ~= nil then
        count_200 = math.random(5, 10)
        count_400 = math.random(1, 2)
    else
        if name:match('replica') ~= nil then
            count_200 = math.random(1, 3)
            count_400 = math.random(0, 1)
        else
            count_200 = math.random(2, 5)
            count_400 = math.random(0, 2)
        end
    end

    local count_500 = math.random(0, 1)

    http_request(('%s/hello'):format(instance.http_uri), 'GET', count_200)
    http_request(('%s/hell0'):format(instance.http_uri), 'GET', count_400)
    http_request(('%s/goodbye'):format(instance.http_uri), 'POST', count_500)
end


-- Space operations constants
local SELECT = 'select'
local INSERT = 'insert'
local UPDATE = 'update'
local UPSERT = 'upsert'
local REPLACE = 'replace'
local DELETE = 'delete'

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

local function space_operations(instance, operation, count)
    if count <= 0 then
        return
    end

    local spaces = {
        instance.net_box.space.MY_SPACE,
        instance.net_box.space.MY_VINYL_SPACE
    }

    for _, space in ipairs(spaces) do
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
                local tuple = space:select({}, { limit = 1 })[1]
                if tuple == nil then return end
                space:update(tuple[1], {{ '=', 2, random_string(5) }})
            end

        elseif operation == UPSERT then
            for _ = 1, count do
                local tuple = space:select({}, { limit = 1 })[1]
                if tuple == nil then return end
                space:upsert(tuple, {{ '=', 2, random_string(5) }})
            end

        elseif operation == REPLACE then
            for _ = 1, count do
                local tuple = space:select({}, { limit = 1 })[1]
                if tuple == nil then return end
                space:replace{ tuple[1], random_string(5) }
            end

        elseif operation == DELETE then
            for _ = 1, count do
                local tuple = space:select({}, { limit = 1 })[1]
                if tuple == nil then return end
                space:delete{ tuple[1] }
            end
        end
    end
end

local function generate_space_load(name, instance)
    local space_load = {}

    if name:match('storage') ~= nil then
        if name:match('replica') ~= nil then
            space_load[SELECT] = math.random(3, 5)
        else
            space_load[INSERT] = math.random(5, 10)
            space_load[SELECT] = math.random(10, 20)
            space_load[UPDATE] = math.random(5, 10)
            space_load[UPSERT] = math.random(5, 10)
            space_load[REPLACE] = math.random(5, 10)
            space_load[DELETE] = math.random(1, 2)
        end
    else
        space_load[INSERT] = math.random(1, 3)
        space_load[UPDATE] = math.random(1, 3)
    end

    for operation, count in pairs(space_load) do
        space_operations(instance, operation, count)
    end
end


local function generate_operations_load(name, instance)
    if name:match('storage') ~= nil then
        instance.net_box:eval([[return box.execute("VALUES ('hello');")]])

        if math.random(0, 100) == 25 then
            -- duplicate key error and read-only instance error
            pcall(instance.net_box.space.MY_SPACE.insert, instance.net_box.space.MY_SPACE, {0, random_string(5)})
        end
    end

    if name:match('router') ~= nil then
        instance.net_box:eval('return true')
    end
end

local LEN = 'LEN'
local GET = 'GET'
local BORDERS = 'BORDERS'
local COUNT = 'COUNT'
local TRUNCATE = 'TRUNCATE'
local BIG_SELECT = 'BIG_SELECT'
local INSERT_MANY = 'INSERT_MANY'
local REPLACE_MANY = 'REPLACE_MANY'
local UPSERT_MANY = 'UPSERT_MANY'
local truncate_inited = false
local crud_index = 1
local crud_space_1 = 'customers'
local crud_space_2 = 'clients'
local crud_bad_space = 'non_existing_space'

local function crud_operations_ok(instance, operation, count, space_name)
    if count <= 0 then
        return
    end

    if operation == SELECT then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.select', {
                space_name, {{ '==', 'id', crud_index}}
            })

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == BIG_SELECT then
        for _ = 1, count do
            -- Setup bucket_id to disable map reduce.
            local _, err = instance.net_box:call('crud.select', {
                space_name, {{ '<=', 'id', crud_index}}
            }, { bucket_id = 1, first = 10 })

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == INSERT then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.insert', {
                space_name, {
                    crud_index,
                    box.NULL,
                    random_string(8),
                    math.random(20, 30),
                },
            })
            crud_index = crud_index + 1

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == INSERT_MANY then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.insert_many', {
                space_name, {
                    {
                        crud_index,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    },
                    {
                        crud_index + 1,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    },
                    {
                        crud_index + 2,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    },
                },
            })
            crud_index = crud_index + 3

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == UPDATE then
        -- Will also generate non-null map reduces
        local res, err = instance.net_box:call('crud.select', {
            space_name, {{ '<=', 'id', crud_index }}, { first = 1 }
        })

        if err ~= nil then
            log.error(err)
            return
        end

        if res.rows[1] == nil then
            log.warn('No record for update')
            return
        end

        for _ = 1, count do
            local _, err = instance.net_box:call('crud.update', {
                space_name,
                res.rows[1][1],
                {{ '=', 3, random_string(5) }},
            })

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == UPSERT then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.upsert', {
                space_name, {
                    crud_index,
                    box.NULL,
                    random_string(8),
                    math.random(20, 30),
                },
                {}
            })
            crud_index = crud_index + 1

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == UPSERT_MANY then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.upsert_many', {
                space_name, {
                    {{
                        crud_index,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    }, {}},
                    {{
                        crud_index + 1,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    }, {}},
                    {{
                        crud_index + 2,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    }, {}},
                },
            })
            crud_index = crud_index + 3

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == REPLACE then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.replace', {
                space_name, {
                    crud_index,
                    box.NULL,
                    random_string(8),
                    math.random(20, 30),
                },
            })
            crud_index = crud_index + 1

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == REPLACE_MANY then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.replace_many', {
                space_name, {
                    {
                        crud_index,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    },
                    {
                        crud_index + 1,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    },
                    {
                        crud_index + 2,
                        box.NULL,
                        random_string(8),
                        math.random(20, 30),
                    },
                },
            })
            crud_index = crud_index + 3

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == DELETE then
        for _ = 1, count do
            -- Will also generate non-null map reduces and tuple lookup.
            local res, err = instance.net_box:call('crud.select', {
                space_name, {{ '<=', 'id', crud_index }}, { first = 1 }
            })

            if err ~= nil then
                log.error(err)
                return
            end

            if res.rows[1] == nil then
                log.warn('No record for delete')
                return
            end

            local _, err = instance.net_box:call('crud.delete', {space_name, {res.rows[1][1]}})

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == COUNT then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.count', {
                space_name, {{ '==', 'id', crud_index}}
            })

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == GET then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.get', {
                space_name, crud_index,
            })

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == BORDERS then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.min', {space_name, 'id_index'})

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == LEN then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.len', {space_name})

            if err ~= nil then
                log.error(err)
            end
        end

    elseif operation == TRUNCATE then
        for _ = 1, count do
            local _, err = instance.net_box:call('crud.truncate', {space_name})

            if err ~= nil then
                log.error(err)
            end
        end
    end
end

local function crud_operations_err(instance, operation, count)
    if count <= 0 then
        return
    end

    if operation == SELECT then
        for _ = 1, count do
            instance.net_box:call('crud.select', {
                crud_bad_space, {{ '==', 'id', crud_index}}
            })
        end

    elseif operation == INSERT then
        for _ = 1, count do
            instance.net_box:call('crud.insert', {crud_bad_space, {}})
        end

    elseif operation == INSERT_MANY then
        for _ = 1, count do
            instance.net_box:call('crud.insert_many', {crud_bad_space, {{}}})
        end

    elseif operation == UPDATE then
        for _ = 1, count do
            instance.net_box:call('crud.update', {
                crud_bad_space, 1, {{ '==', 3, random_string(5) }},
            })
        end

    elseif operation == UPSERT then
        for _ = 1, count do
            instance.net_box:call('crud.upsert', {
                crud_bad_space, {}, {{ '==', 3, random_string(5) }}
            })
        end

    elseif operation == UPSERT_MANY then
        for _ = 1, count do
            instance.net_box:call('crud.upsert_many', {
                crud_bad_space, {{}, {{ '==', 3, random_string(5) }}}
            })
        end

    elseif operation == REPLACE then
        for _ = 1, count do
            instance.net_box:call('crud.replace', {crud_bad_space, {}})
        end

    elseif operation == REPLACE_MANY then
        for _ = 1, count do
            instance.net_box:call('crud.replace_many', {crud_bad_space, {{}}})
        end

    elseif operation == DELETE then
        for _ = 1, count do
            instance.net_box:call('crud.delete', {crud_bad_space, 1})
        end

    elseif operation == COUNT then
        for _ = 1, count do
            instance.net_box:call('crud.count', {
                crud_bad_space, {{ '==', 'id', crud_index}}
            })
        end

    elseif operation == GET then
        for _ = 1, count do
            instance.net_box:call('crud.get', {crud_bad_space, 1})
        end

    elseif operation == BORDERS then
        for _ = 1, count do
            instance.net_box:call('crud.min', {crud_bad_space, 'id_index'})
        end

    elseif operation == LEN then
        for _ = 1, count do
            instance.net_box:call('crud.len', {crud_bad_space})
        end

    elseif operation == TRUNCATE then
        for _ = 1, count do
            instance.net_box:call('crud.truncate', {crud_bad_space})
        end
    end
end

local function generate_crud_load(name, instance)
    local space_load_ok_1 = {}
    local space_load_ok_2 = {}
    local space_load_err = {}

    if name:match('router') ~= nil then
        space_load_ok_1[INSERT] = math.random(3, 5)
        space_load_ok_1[INSERT_MANY] = math.random(1, 2)
        space_load_ok_1[SELECT] = math.random(5, 10)
        space_load_ok_1[BIG_SELECT] = math.random(1, 3)
        space_load_ok_1[GET] = math.random(5, 10)
        space_load_ok_1[UPDATE] = math.random(2, 3)
        space_load_ok_1[REPLACE] = math.random(2, 3)
        space_load_ok_1[REPLACE_MANY] = math.random(1, 2)
        space_load_ok_1[UPSERT] = math.random(1, 2)
        space_load_ok_1[UPSERT_MANY] = math.random(1, 2)
        space_load_ok_1[DELETE] = math.random(1, 2)
        space_load_ok_1[LEN] = math.random(0, 1)
        space_load_ok_1[COUNT] = math.random(1, 2)
        space_load_ok_1[BORDERS] = math.random(1, 2)

        space_load_ok_2[INSERT] = math.random(6, 8)
        space_load_ok_2[INSERT_MANY] = math.random(1, 2)
        space_load_ok_2[SELECT] = math.random(2, 4)
        space_load_ok_2[BIG_SELECT] = math.random(2, 4)
        space_load_ok_2[GET] = math.random(5, 10)
        space_load_ok_2[UPDATE] = math.random(2, 3)
        space_load_ok_2[REPLACE] = math.random(2, 3)
        space_load_ok_2[REPLACE_MANY] = math.random(1, 2)
        space_load_ok_2[UPSERT] = math.random(1, 2)
        space_load_ok_2[UPSERT_MANY] = math.random(1, 2)
        space_load_ok_2[DELETE] = math.random(1, 2)
        space_load_ok_2[LEN] = math.random(0, 1)
        space_load_ok_2[COUNT] = math.random(1, 2)
        space_load_ok_2[BORDERS] = math.random(1, 2)

        space_load_err[INSERT] = math.random(1, 3)
        space_load_err[INSERT_MANY] = math.random(0, 1)
        space_load_err[SELECT] = math.random(2, 5)
        space_load_err[GET] = math.random(2, 5)
        space_load_err[UPDATE] = math.random(0, 1)
        space_load_err[REPLACE] = math.random(0, 1)
        space_load_err[REPLACE_MANY] = math.random(0, 1)
        space_load_err[UPSERT] = math.random(0, 1)
        space_load_err[UPSERT_MANY] = math.random(0, 1)
        space_load_err[DELETE] = math.random(0, 1)
        space_load_err[LEN] = math.random(0, 1)
        space_load_err[COUNT] = math.random(0, 1)
        space_load_err[BORDERS] = math.random(1, 2)

        if truncate_inited then
            space_load_ok_1[TRUNCATE] = math.floor(math.random(1, 1000) / 1000)
            space_load_ok_2[TRUNCATE] = math.floor(math.random(1, 1000) / 1000)
            space_load_err[TRUNCATE] = math.floor(math.random(1, 1000) / 1000)
        else
            space_load_ok_1[TRUNCATE] = 1
            space_load_ok_2[TRUNCATE] = 1
            space_load_err[TRUNCATE] = 1
            truncate_inited = true
        end
    else
        return
    end

    for operation, count in pairs(space_load_ok_1) do
        crud_operations_ok(instance, operation, count, crud_space_1)
    end

    for operation, count in pairs(space_load_ok_2) do
        crud_operations_ok(instance, operation, count, crud_space_2)
    end

    for operation, count in pairs(space_load_err) do
        crud_operations_err(instance, operation, count)
    end
end

local f = fio.open('instances.yml')
local instances = yaml.decode(f:read())
f:close()

for _, instance in pairs(instances) do
    if instance.http_port ~= nil then
        instance.http_uri = ('%s:%d'):format(APP_HOST, instance.http_port)
    end

    instance.advertise_uri = instance.advertise_uri:gsub('localhost', APP_HOST)
end

local cluster_cookie = require('cookie')

fiber.sleep(10)

for _, instance in pairs(instances) do
    instance.net_box = net_box.connect(
        instance.advertise_uri,
        { user = 'admin', password = cluster_cookie, reconnect_after = 5, wait_connected = 10 }
    )
    pcall(instance.net_box.eval, instance.net_box, 'return box.space.MY_SPACE:truncate()')
end

local load_generators = {
    generate_http_load,
    generate_space_load,
    generate_operations_load,
    generate_crud_load,
}

for name, instance in pairs(instances) do
    if name:match('router') ~= nil then
        local spaces = {instance.net_box.space.MY_SPACE, instance.net_box.space.MY_VINYL_SPACE}
        for _, space in ipairs(spaces) do
            local task_name = name .. "_" .. space.name
            local eval_str = string.format([[
                local expirationd = require('expirationd')
                local half_true = function() return math.random(0, 1) == 0 and true or false end
                local always_true = function() return true end
                expirationd.start("%s", %d, half_true, {
                                      process_expired_tuple = always_true,
                                      force = true })
            ]], task_name, space.id)
            instance.net_box:eval(eval_str)
        end
    end
end

while true do
    for name, instance in pairs(instances) do
        for _, load_generator in ipairs(load_generators) do
            local _, err = pcall(load_generator, name, instance)
            if err ~= nil then
                log.error(err)
                fiber.sleep(1)
            end
            fiber.yield()
        end
    end
end
