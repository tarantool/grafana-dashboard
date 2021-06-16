local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard.libsonnet';

local row = grafana.row;

local raw_dashboard = grafana.dashboard.new(
  title='Example InfluxDB dashboard',
  description='Example dashboard',
  editable=true,
  schemaVersion=21,
  time_from='now-6h',
  time_to='now',
  refresh='30s',
  tags=['tag1', 'tag2'],
);

local datasource = '${DS_INFLUXDB}';
local policy = '${INFLUXDB_POLICY}';
local measurement = '${INFLUXDB_MEASUREMENT}';

dashboard.build(
  raw_dashboard
  .addInput(
    name='DS_INFLUXDB',
    label='InfluxDB bank',
    type='datasource',
    pluginId='influxdb',
    pluginName='InfluxDB',
    description='InfluxDB Tarantool metrics bank'
  )
  .addInput(
    name='INFLUXDB_MEASUREMENT',
    label='Measurement',
    type='constant',
    description='InfluxDB Tarantool metrics measurement'
  )
  .addInput(
    name='INFLUXDB_POLICY',
    label='Policy',
    type='constant',
    value='default',
    description='InfluxDB Tarantool metrics policy'
  )
  .addRequired(
    type='datasource',
    id='influxdb',
    name='InfluxDB',
    version='1.0.0'
  )
  .addPanel(
    row.new(title='Cluster overview'),
    { w: 24, h: 1, x: 0, y: 0 }
  ),
  datasource,
  policy=policy,
  measurement=measurement,
  offset=1,
)
