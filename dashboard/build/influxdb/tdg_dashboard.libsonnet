local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.influxdb,
  title: 'Tarantool Data Grid dashboard',
  description: 'Dashboard for Tarantool Data Grid ver. 2 application monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool', 'TDG'],
  datasource: variable.datasource.influxdb,
  policy: variable.influxdb.policy,
  measurement: variable.influxdb.measurement,
  filters: { label_pairs_alias: ['=~', variable.influxdb.alias] },
  sections: [
    'cluster',
    'replication',
    'net',
    'slab',
    'mvcc',
    'space',
    'vinyl',
    'cpu_extended',
    'runtime',
    'luajit',
    'operations',
    'tdg_kafka_common',
    'tdg_kafka_brokers',
    'tdg_kafka_topics',
    'tdg_kafka_consumer',
    'tdg_kafka_producer',
    'expirationd',
    'tdg_tuples',
    'tdg_file_connectors',
    'tdg_graphql',
    'tdg_iproto',
    'tdg_rest_api',
    'tdg_tasks',
  ],
});

dashboard_raw(cfg)
