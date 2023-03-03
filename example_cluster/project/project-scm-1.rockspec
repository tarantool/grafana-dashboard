package = 'project'
version = 'scm-1'
source  = {
    url = '/dev/null',
}
-- Put any modules your app depends on here
dependencies = {
    'tarantool',
    'lua >= 5.1',
    'cartridge == 2.7.6-1',
    'metrics == 0.16.0-1',
    'crud == 1.0.0-1',
    'expirationd == 1.3.1-1',
}
build = {
    type = 'none';
}
