local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.influxdb,
  title: 'Tarantool Data Grid dashboard',
  description: 'Dashboard for Tarantool Data Grid ver. 2 application monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool', 'TDG'],
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

dashboard_raw(cfg).addTemplate(
  grafana.template.datasource(
    name='influxdb',
    query='influxdb',
    current=null,
    label='Datasource',
  )
).addTemplate(
  grafana.template.new(
    name='policy',
    datasource=cfg.datasource,
    query='SHOW RETENTION POLICIES',
    label='Retention policy',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='measurement',
    datasource=cfg.datasource,
    query=std.format('SHOW MEASUREMENTS WHERE "metric_name"=\'%s\'', variable.metrics.tarantool_indicator),
    label='Measurement',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='alias',
    datasource=cfg.datasource,
    query=std.format(
      'SHOW TAG VALUES FROM "%(policy)s"."%(measurement)s" WITH KEY="label_pairs_alias"',
      {
        policy: cfg.policy,
        measurement: cfg.measurement,
      },
    ),
    includeAll=true,
    multi=true,
    current='all',
    label='Instances',
    refresh='time',
  )
)
