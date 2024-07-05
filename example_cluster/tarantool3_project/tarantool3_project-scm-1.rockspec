package = 'tarantool3_project'
version = 'scm-1'
source  = {
    url = '/dev/null',
}
dependencies = {
    'tarantool',
    'lua >= 5.1',
    'crud == 1.5.2-1',
    'metrics == scm-1',
    'expirationd == 1.3.1-1',
    'http == 1.5.0-1',
}
build = {
    type = 'none';
}
