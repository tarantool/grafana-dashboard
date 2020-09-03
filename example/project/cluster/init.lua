#!/usr/bin/env tarantool

local fio = require('fio')
if os.getenv('ENABLE_TEST_COVERAGE') == 'true' then
    local cfg_luacov = dofile(fio.pathjoin('.luacov'))
    cfg_luacov.statsfile = fio.pathjoin('luacov.stats.out')

    local coverage = require('luacov.runner')
    coverage.init(cfg_luacov)
    rawset(_G, 'coverage', coverage)
end

local function get_base_dir()
    return fio.abspath(fio.dirname(arg[0]) .. '/app/')
end

local function extend_path(path)
    package.path = package.path .. ';' .. path
end

local function extend_cpath(path)
    package.cpath = package.cpath .. ';' .. path
end

local function set_base_load_paths(base_dir)
    extend_path(base_dir .. '/?.lua')
    extend_path(base_dir .. '/?/init.lua')
    extend_cpath(base_dir .. '/?.dylib')
    extend_cpath(base_dir .. '/?.so')
end

local function set_rocks_load_paths(base_dir)
    extend_path(base_dir..'/.rocks/share/tarantool/?.lua')
    extend_path(base_dir..'/.rocks/share/tarantool/?/init.lua')
    extend_cpath(base_dir..'/.rocks/lib/tarantool/?.dylib')
    extend_cpath(base_dir..'/.rocks/lib/tarantool/?.so')
end

local function set_load_paths(base_dir)
    set_base_load_paths(base_dir)
    set_rocks_load_paths(base_dir)
end

set_load_paths(get_base_dir())

require('init')
