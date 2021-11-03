local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard.libsonnet';
local section = import 'section.libsonnet';
local variable = import 'variable.libsonnet';

dashboard.new(
  grafana.dashboard.new(
    title='Tarantool dashboard',
    description='Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
    editable=true,
    schemaVersion=21,
    time_from='now-3h',
    time_to='now',
    refresh='30s',
    tags=['tarantool'],
  ).addRequired(
    type='grafana',
    id='grafana',
    name='Grafana',
    version='6.6.0'
  ).addRequired(
    type='panel',
    id='graph',
    name='Graph',
    version=''
  ).addRequired(
    type='panel',
    id='text',
    name='Text',
    version=''
  ).addRequired(
    type='datasource',
    id='influxdb',
    name='InfluxDB',
    version='1.0.0'
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
    description='InfluxDB Tarantool metrics measurement'
  ).addInput(
    name='INFLUXDB_POLICY',
    label='Policy',
    type='constant',
    value='default',
    description='InfluxDB Tarantool metrics policy'
  )
).addPanels(
  section.cluster_influxdb(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.http(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.net(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.slab(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.vinyl(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.cpu(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.runtime(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
).addPanels(
  section.operations(
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )
)
