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
).addTemplate(
  grafana.template.new(
    name='job',
    datasource=variable.datasource.prometheus,
    query=std.format('label_values(%s,job)', variable.metrics.tarantool_indicator),
    label='Prometheus job',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='alias',
    datasource=variable.datasource.prometheus,
    query=std.format('label_values(%s{job=~"%s"},alias)', [variable.metrics.tarantool_indicator, variable.prometheus.job]),
    includeAll=true,
    multi=true,
    current='all',
    label='Instances',
    refresh='time',
  )
)
