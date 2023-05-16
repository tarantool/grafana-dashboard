local config = import 'dashboard/build/config.libsonnet';
local dashboard = import 'dashboard/build/dashboard.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.influxdb,
  title: 'Tarantool dashboard',
  description: 'Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool'],
  datasource: variable.datasource.influxdb,
  policy: variable.influxdb.policy,
  measurement: variable.influxdb.measurement,
  filters: { label_pairs_alias: ['=~', variable.influxdb.alias] },
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

dashboard(cfg)
