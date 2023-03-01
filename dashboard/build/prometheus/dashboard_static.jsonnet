local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');

if WITH_INSTANCE_VARIABLE then
  dashboard_raw(
    datasource=DATASOURCE,
    job=JOB,
    alias=variable.prometheus.alias,
  ).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=DATASOURCE,
      query=std.format('label_values(%s{job="%s"},alias)', [variable.metrics.tarantool_indicator, JOB]),
      includeAll=true,
      multi=true,
      current='all',
      label='Instances',
      refresh='time',
    )
  ).build()
else
  dashboard_raw(
    datasource=DATASOURCE,
    job=JOB,
    alias='.*',
  ).build()
