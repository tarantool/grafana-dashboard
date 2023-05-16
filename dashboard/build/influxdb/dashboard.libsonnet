local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.influxdb,
  title: 'Tarantool dashboard',
  description: 'Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool'],
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
