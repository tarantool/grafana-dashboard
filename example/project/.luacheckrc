std = {
    read_globals = {'require', 'debug', 'pcall', 'xpcall', 'tostring',
        'tonumber', 'type', 'assert', 'ipairs', 'math', 'error', 'string',
        'table', 'pairs', 'os', 'io', 'select', 'unpack', 'dofile', 'next',
        'loadstring', 'setfenv',
        'rawget', 'rawset', '_G',
        'getmetatable', 'setmetatable',
        'print', 'tonumber64', 'arg'

    },
    globals = {'box', 'vshard', 'package',
        'applier'
    }
}
redefined = false
