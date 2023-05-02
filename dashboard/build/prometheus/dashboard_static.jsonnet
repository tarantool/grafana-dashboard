local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';
local utils = import 'dashboard/utils.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = std.extVar('TITLE');
local LABELS = if std.extVar('LABELS') != '' then utils.parseLabels(std.extVar('LABELS')) else {};

if WITH_INSTANCE_VARIABLE then
  dashboard_raw(
    datasource=DATASOURCE,
    job=JOB,
    alias=variable.prometheus.alias,
    title=TITLE,
    labels=LABELS,
  ).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=DATASOURCE,
      query=std.format('label_values(%s{job="%s", %s},alias)', [variable.metrics.tarantool_indicator, JOB, utils.generate_labels_string(LABELS)]),
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
    title=TITLE,
    labels=LABELS,
  ).build()
