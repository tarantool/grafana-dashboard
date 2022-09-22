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
).addInput(
  name='INFLUXDB_MEASUREMENT',
  label='Measurement',
  type='constant',
  value='tarantool_http',
  description='InfluxDB Tarantool metrics measurement'
).addInput(
  name='INFLUXDB_POLICY',
  label='Policy',
  type='constant',
  value='autogen',
  description='InfluxDB Tarantool metrics policy'
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
