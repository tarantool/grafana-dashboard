local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard.libsonnet';
local section = import 'section.libsonnet';

local datasource = '${DS_PROMETHEUS}';
local rate_time_range = '$rate_time_range';
local job = '[[job]]';

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
    type='panel',
    id='stat',
    name='Stat',
    version='',
  ).addRequired(
    type='panel',
    id='table',
    name='Table',
    version='',
  ).addRequired(
    type='datasource',
    id='prometheus',
    name='Prometheus',
    version='1.0.0'
  ).addInput(
    name='DS_PROMETHEUS',
    label='Prometheus',
    type='datasource',
    pluginId='prometheus',
    pluginName='Prometheus',
    description='Prometheus Tarantool metrics bank'
  ).addInput(
    name='PROMETHEUS_JOB',
    label='Job',
    type='constant',
    pluginId=null,
    pluginName=null,
    description='Prometheus Tarantool metrics job'
  ).addInput(
    name='PROMETHEUS_RATE_TIME_RANGE',
    label='Rate time range',
    type='constant',
    value='2m',
    description='Time range for computing rps graphs with rate(). At the very minimum it should be two times the scrape interval.'
  ).addTemplate(
    grafana.template.custom(
      name='job',
      query='${PROMETHEUS_JOB}',
      current='${PROMETHEUS_JOB}',
      hide='variable',
      label='Prometheus job',
    )
  ).addTemplate(
    grafana.template.custom(
      name='rate_time_range',
      query='${PROMETHEUS_RATE_TIME_RANGE}',
      current='${PROMETHEUS_RATE_TIME_RANGE}',
      hide='variable',
      label='rate() time range',
    )
  )
).addPanels(
  section.cluster_prometheus(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.http(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.net(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.slab(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.vinyl(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.cpu(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.memory_misc(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
).addPanels(
  section.operations(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  )
)
