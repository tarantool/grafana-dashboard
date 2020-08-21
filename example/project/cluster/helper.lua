local fio = require('fio')
local lt = require('luatest')
local json = require('json')
local Server = require('cartridge.test-helpers.server')

local helper = {}

helper.root = fio.dirname(fio.abspath(package.search('init')))
helper.datadir = fio.pathjoin(helper.root, 'dev')
helper.server_command = fio.pathjoin(helper.root, 'cluster/init.lua')

lt.before_suite(function()
    fio.rmtree(helper.datadir)
    fio.mktree(helper.datadir)
end)

function Server:build_env()
    return {
        TARANTOOL_ALIAS = self.alias,
        TARANTOOL_WORKDIR = self.workdir,
        TARANTOOL_HTTP_PORT = self.http_port,
        TARANTOOL_ADVERTISE_URI = self.advertise_uri,
        TARANTOOL_CLUSTER_COOKIE = self.cluster_cookie,
        TARANTOOL_LOG_LEVEL = 6,
        TZ = 'Europe/Moscow'
    }
end

Server.constructor_checks.api_host = '?string'
Server.constructor_checks.api_port = '?string'
function Server:api_request(method, path, options)
    method = method and string.upper(method)
    if not self.http_client then
        error('http_port not configured')
    end
    options = options or {}
    local body = options.body or (options.json and json.encode(options.json))
    local http_options = options.http or {}
    local url = self.api_host .. ':' .. self.api_port .. path
    local response = self.http_client:request(method, url, body, http_options)
    local ok, json_body = pcall(json.decode, response.body)
    if ok then
        response.json = json_body
    end
    if not options.raw and response.status ~= 200 then
        error({type = 'HTTPRequest', response = response})
    end
    return response
end

return helper
