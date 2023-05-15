local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local tdg_dashboard_raw = import 'dashboard/build/influxdb/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local POLICY = std.extVar('POLICY');
local MEASUREMENT = std.extVar('MEASUREMENT');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = if std.extVar('TITLE') != '' then std.extVar('TITLE') else 'Tarantool Data Grid dashboard';

local cfg = config.prepare({
  type: variable.datasource_type.influxdb,
  title: TITLE,
  datasource: DATASOURCE,
  policy: POLICY,
  measurement: MEASUREMENT,
  filters: if WITH_INSTANCE_VARIABLE then { label_pairs_alias: ['=~', variable.influxdb.alias] } else {},
});

if WITH_INSTANCE_VARIABLE then
  tdg_dashboard_raw(cfg).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=cfg.datasource,
      query=std.format(
        'SHOW TAG VALUES FROM %(policy_prefix)s"%(measurement)s" WITH KEY="label_pairs_alias"',
        {
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%s".', cfg.policy),
          measurement: cfg.measurement,
        },
      ),
      includeAll=true,
      multi=true,
      current='all',
      label='Instances',
      refresh='time',
    )
  ).build()
else
  tdg_dashboard_raw(cfg).build()
