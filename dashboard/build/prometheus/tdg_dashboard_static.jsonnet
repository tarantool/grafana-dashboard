local grafana = import 'grafonnet/grafana.libsonnet';

local tdg_dashboard_raw = import 'dashboard/build/prometheus/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');

if WITH_INSTANCE_VARIABLE then
  tdg_dashboard_raw(
    datasource=DATASOURCE,
    job=JOB,
    alias=variable.prometheus.alias,
  ).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=DATASOURCE,
      query=std.format('label_values(tnt_info_uptime{job="%s"},alias)', JOB),
      includeAll=true,
      multi=true,
      current='all',
      label='Instances',
      refresh='time',
    )
  ).build()
else
  tdg_dashboard_raw(
    datasource=DATASOURCE,
    job=JOB,
    alias='.*',
  ).build()
