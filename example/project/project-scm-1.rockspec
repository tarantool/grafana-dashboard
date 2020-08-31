package = 'project'
version = 'scm-1'
source  = {
    url = '/dev/null',
}
-- Put any modules your app depends on here
dependencies = {
    'tarantool',
    'lua >= 5.1',
    'checks == 3.0.1-1',
    'http == 1.1.0-1',
    'cartridge == 2.1.2-1',
    'metrics == scm-1'
}
build = {
    type = 'none';
}
