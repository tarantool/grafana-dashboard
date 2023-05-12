local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = if std.extVar('TITLE') != '' then std.extVar('TITLE') else 'Tarantool dashboard';

local cfg = config.prepare({
  type: variable.datasource_type.prometheus,
  title: TITLE,
  datasource: DATASOURCE,
  job: JOB,
  filters: if WITH_INSTANCE_VARIABLE then {} else { alias: '.*' },
});

if WITH_INSTANCE_VARIABLE then
  dashboard_raw(cfg).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=cfg.datasource,
      query=std.format('label_values(%s{job="%s"},alias)', [variable.metrics.tarantool_indicator, cfg.job]),
      includeAll=true,
      multi=true,
      current='all',
      label='Instances',
      refresh='time',
    )
  ).build()
else
  dashboard_raw(cfg).build()
