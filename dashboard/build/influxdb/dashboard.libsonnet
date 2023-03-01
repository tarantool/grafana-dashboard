local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard_raw = import 'dashboard/build/influxdb/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

dashboard_raw(
  datasource=variable.datasource.influxdb,
  policy=variable.influxdb.policy,
  measurement=variable.influxdb.measurement,
  alias=variable.influxdb.alias,
).addInput(
  name='DS_INFLUXDB',
  label='InfluxDB bank',
  type='datasource',
  pluginId='influxdb',
  pluginName='InfluxDB',
  description='InfluxDB Tarantool metrics bank'
).addTemplate(
  grafana.template.new(
    name='policy',
    datasource=variable.datasource.influxdb,
    query='SHOW RETENTION POLICIES',
    label='Retention policy',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='measurement',
    datasource=variable.datasource.influxdb,
    query=std.format('SHOW MEASUREMENTS WHERE "metric_name"=\'%s\'', variable.metrics.tarantool_indicator),
    label='Measurement',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='alias',
    datasource=variable.datasource.influxdb,
    query=std.format('SHOW TAG VALUES FROM "%s" WITH KEY="label_pairs_alias"', variable.influxdb.measurement),
    includeAll=true,
    multi=true,
    current='all',
    label='Instances',
    refresh='time',
  )
)
