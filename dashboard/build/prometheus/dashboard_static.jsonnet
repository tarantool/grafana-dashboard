local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard_raw = import 'dashboard/build/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = if std.extVar('TITLE') != '' then std.extVar('TITLE') else 'Tarantool dashboard';

local cfg = config.prepare({
  type: variable.datasource_type.prometheus,
  title: TITLE,
  description: 'Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
  grafana_tags: ['tarantool'],
  datasource: DATASOURCE,
  filters: { job: ['=~', JOB] } + if WITH_INSTANCE_VARIABLE then { alias: ['=~', variable.prometheus.alias] } else {},
  sections: [
    'cluster',
    'replication',
    'http',
    'net',
    'slab',
    'mvcc',
    'space',
    'vinyl',
    'cpu',
    'runtime',
    'luajit',
    'operations',
    'crud',
    'expirationd',
  ],
});

if WITH_INSTANCE_VARIABLE then
  dashboard_raw(cfg).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=cfg.datasource,
      query=std.format('label_values(%s{job="%s"},alias)', [variable.metrics.tarantool_indicator, cfg.filters.job[1]]),
      includeAll=true,
      multi=true,
      current='all',
      label='Instances',
      refresh='time',
    )
  ).build()
else
  dashboard_raw(cfg).build()
