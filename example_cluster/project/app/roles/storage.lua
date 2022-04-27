local function init(opts)
    if opts.is_master then
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
            })
            -- primary index
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
    end

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
    role_name = 'app.roles.storage',
    dependencies = {
        'app.roles.custom',
        'cartridge.roles.crud-storage',
    },
    init = init,
    stop = stop,
    validate_config = validate_config,
    apply_config = apply_config,
}
