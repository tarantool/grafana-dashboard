local grafana = import 'grafonnet/grafana.libsonnet';


local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = std.extVar('TITLE');
local SECTIONS = std.extVar("SECTIONS");
# TODO: extract this mess
local sections = if SECTIONS != null && SECTIONS != "" then
                   std.split(SECTIONS, ',')
                 else
                   ['cluster_prometheus', 'replication', 'http', 'net', 'slab', 'mvcc', 'space', 'vinyl', 'cpu', 'luajit', 'operations', 'crud', 'expirationd'];

if WITH_INSTANCE_VARIABLE then
  dashboard_raw(
    datasource=DATASOURCE,
    job=JOB,
    alias=variable.prometheus.alias,
    title=TITLE,
    sections=sections,
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
    title=TITLE,
    sections=sections,
  ).build()
