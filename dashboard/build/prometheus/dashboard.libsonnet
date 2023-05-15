local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local cfg = config.prepare({
  type: variable.datasource_type.prometheus,
  title: 'Tarantool dashboard',
  filters: { alias: ['=~', variable.prometheus.alias] },
});

dashboard_raw(cfg).addTemplate(
  grafana.template.datasource(
    name='prometheus',
    query='prometheus',
    current=null,
    label='Datasource',
  )
).addTemplate(
  grafana.template.new(
    name='job',
    datasource=cfg.datasource,
    query=std.format('label_values(%s,job)', variable.metrics.tarantool_indicator),
    label='Prometheus job',
    refresh='load',
  )
).addTemplate(
  grafana.template.new(
    name='alias',
    datasource=cfg.datasource,
    query=std.format('label_values(%s{job=~"%s"},alias)', [variable.metrics.tarantool_indicator, cfg.filters.job[1]]),
    includeAll=true,
    multi=true,
    current='all',
    label='Instances',
    refresh='time',
  )
)
