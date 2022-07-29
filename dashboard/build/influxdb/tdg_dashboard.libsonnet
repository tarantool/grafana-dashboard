local grafana = import 'grafonnet/grafana.libsonnet';

local tdg_dashboard_raw = import 'dashboard/build/influxdb/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

tdg_dashboard_raw(
  datasource=variable.datasource.influxdb,
  policy=variable.influxdb.policy,
  measurement=variable.influxdb.measurement
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
)
