local grafana = import 'grafonnet/grafana.libsonnet';

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
  ).addTemplate(
    grafana.template.custom(
      name='job',
      query='${PROMETHEUS_JOB}',
      current='${PROMETHEUS_JOB}',
      hide='variable',
      label='Prometheus job',
    ),
  ),
  datasource,
  job=job,
)
