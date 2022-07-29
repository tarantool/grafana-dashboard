local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

dashboard_raw(
  datasource=variable.datasource.prometheus,
  job=variable.prometheus.job,
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
)
