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

local load_generators = { generate_http_load, generate_space_load, generate_operations_load }

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
