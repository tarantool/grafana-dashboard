local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.prometheus,
  title: 'Tarantool dashboard',
  description: 'Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool'],
  datasource: variable.datasource.prometheus,
  filters: { job: ['=~', variable.prometheus.job], alias: ['=~', variable.prometheus.alias] },
  sections: [
    'cluster',
    'replication',
    'http',
    'net',
    'slab',
    'mvcc',
    'space',
    'vinyl',
    'cpu',
    'runtime',
    'luajit',
    'operations',
    'crud',
    'expirationd',
  ],
});

dashboard_raw(cfg)
