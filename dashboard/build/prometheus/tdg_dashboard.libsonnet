local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local tdg_dashboard_raw = import 'dashboard/build/prometheus/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.prometheus,
  title: 'Tarantool Data Grid dashboard',
  filters: { alias: ['=~', variable.prometheus.alias] },
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

tdg_dashboard_raw(cfg).addTemplate(
  grafana.template.datasource(
    name='prometheus',
    query='prometheus',
    current=null,
    label='Datasource',
  )
).addTemplate(
  grafana.template.new(
    name='job',
    datasource=cfg.datasource,
    query=std.format('label_values(%s,job)', variable.metrics.tarantool_indicator),
    label='Prometheus job',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='alias',
    datasource=cfg.datasource,
    query=std.format('label_values(%s{job=~"%s"},alias)', [variable.metrics.tarantool_indicator, cfg.filters.job[1]]),
    includeAll=true,
    multi=true,
    current='all',
    label='Instances',
    refresh='time',
  )
)
