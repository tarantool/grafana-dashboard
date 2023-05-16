local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local POLICY = std.extVar('POLICY');
local MEASUREMENT = std.extVar('MEASUREMENT');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = if std.extVar('TITLE') != '' then std.extVar('TITLE') else 'Tarantool Data Grid dashboard';

local cfg = config.prepare({
  type: variable.datasource_type.influxdb,
  title: TITLE,
  description: 'Dashboard for Tarantool Data Grid ver. 2 application monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool', 'TDG'],
  datasource: DATASOURCE,
  policy: POLICY,
  measurement: MEASUREMENT,
  filters: if WITH_INSTANCE_VARIABLE then { label_pairs_alias: ['=~', variable.influxdb.alias] } else {},
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

dashboard_raw(cfg).build()
