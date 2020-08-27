local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local dashboard = import 'dashboard.libsonnet';

local raw_dashboard = grafana.dashboard.new(
  title='Example Prometheus dashboard',
  description='Example dashboard',
  editable=true,
  schemaVersion=21,
  time_from='now-6h',
  time_to='now',
  refresh='30s',
  tags=['tag1', 'tag2'],
);

local datasource = '${DS_PROMETHEUS}';
local job = '[[job]]';

dashboard.build(
  raw_dashboard
  .addInput(
    name='DS_PROMETHEUS',
    label='Prometheus',
    type='datasource',
    pluginId='prometheus',
    pluginName='Prometheus',
    description='Prometheus Tarantool metrics bank'
  )
  .addInput(
    name='PROMETHEUS_JOB',
    label='Job',
    type='constant',
    pluginId=null,
    pluginName=null,
    description='Prometheus Tarantool metrics job'
  )
  .addRequired(
    type='datasource',
    id='prometheus',
    name='Prometheus',
    version='1.0.0'
  )
  .addRequired(
    type='panel',
    id='stat',
    name='Stat',
    version='',
  )
  .addRequired(
    type='panel',
    id='table',
    name='Table',
    version='',
  )
  .addTemplate(
    grafana.template.custom(
      name='job',
      query='${PROMETHEUS_JOB}',
      current='${PROMETHEUS_JOB}',
      hide='variable',
      label='Prometheus job',
    ),
  ).addPanel(
    cluster.health_overview_table(
      datasource=datasource,
      job=job,
    ),
    { w: 12, h: 8, x: 0, y: 0 }
  ).addPanel(
    cluster.health_overview_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 8, h: 3, x: 12, y: 0 }
  ).addPanel(
    cluster.memory_used_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 4, h: 5, x: 12, y: 3 }
  ).addPanel(
    cluster.memory_reserved_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 4, h: 5, x: 16, y: 3 }
  ).addPanel(
    cluster.space_ops_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 4, h: 4, x: 20, y: 0 }
  ).addPanel(
    cluster.http_rps_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 4, h: 4, x: 20, y: 4 }
  ),
  datasource,
  job=job,
  offset=8,
)
