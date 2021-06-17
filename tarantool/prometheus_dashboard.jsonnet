local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local dashboard = import 'dashboard.libsonnet';

local row = grafana.row;

local raw_dashboard = grafana.dashboard.new(
  title='Tarantool dashboard',
  description='Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
  editable=true,
  schemaVersion=21,
  time_from='now-3h',
  time_to='now',
  refresh='30s',
  tags=['tarantool'],
);

local datasource = '${DS_PROMETHEUS}';
local rate_time_range = '$rate_time_range';
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
  .addInput(
    name='PROMETHEUS_RATE_TIME_RANGE',
    label='Rate time range',
    type='constant',
    value='2m',
    description='Time range for computing rps graphs with rate(). At the very minimum it should be two times the scrape interval.'
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
  )
  .addTemplate(
    grafana.template.custom(
      name='rate_time_range',
      query='${PROMETHEUS_RATE_TIME_RANGE}',
      current='${PROMETHEUS_RATE_TIME_RANGE}',
      hide='variable',
      label='rate() time range',
    ),
  ).addPanel(
    row.new(title='Cluster overview'),
    { w: 24, h: 1, x: 0, y: 0 }
  )
  .addPanel(
    cluster.health_overview_table(
      datasource=datasource,
      job=job,
    ),
    { w: 12, h: 8, x: 0, y: 1 }
  ).addPanel(
    cluster.health_overview_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 8, h: 3, x: 12, y: 1 }
  ).addPanel(
    cluster.memory_used_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 4, h: 5, x: 12, y: 4 }
  ).addPanel(
    cluster.memory_reserved_stat(
      datasource=datasource,
      job=job,
    ),
    { w: 4, h: 5, x: 16, y: 4 }
  ).addPanel(
    cluster.space_ops_stat(
      datasource=datasource,
      job=job,
      rate_time_range=rate_time_range,
    ),
    { w: 4, h: 4, x: 20, y: 1 }
  ).addPanel(
    cluster.http_rps_stat(
      datasource=datasource,
      job=job,
      rate_time_range=rate_time_range,
    ),
    { w: 4, h: 4, x: 20, y: 5 }
  ),
  datasource,
  job=job,
  rate_time_range=rate_time_range,
  offset=9,
)
