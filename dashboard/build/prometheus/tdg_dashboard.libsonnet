local grafana = import 'grafonnet/grafana.libsonnet';

local tdg_dashboard_raw = import 'dashboard/build/prometheus/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

tdg_dashboard_raw(
  datasource=variable.datasource.prometheus,
  job=variable.prometheus.job,
  alias=variable.prometheus.alias,
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
  value='tarantool',
  description='Prometheus Tarantool metrics job'
).addTemplate(
  grafana.template.custom(
    name='job',
    query='${PROMETHEUS_JOB}',
    current='${PROMETHEUS_JOB}',
    hide='variable',
    label='Prometheus job',
  )
).addTemplate(
  grafana.template.new(
    name='alias',
    datasource=variable.datasource.prometheus,
    query='label_values(tnt_info_uptime{job=~"$job"},alias)',
    includeAll=true,
    multi=true,
    current='all',
    label='Instances',
    refresh='time',
  )
)
