local grafana = import 'grafonnet/grafana.libsonnet';

local tdg_dashboard_raw = import 'dashboard/build/prometheus/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

tdg_dashboard_raw(
  datasource=variable.datasource_var.prometheus,
  job=variable.prometheus.job,
  rate_time_range=variable.prometheus.rate_time_range
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
