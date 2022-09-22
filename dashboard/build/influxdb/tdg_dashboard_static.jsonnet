local grafana = import 'grafonnet/grafana.libsonnet';

local tdg_dashboard_raw = import 'dashboard/build/influxdb/tdg_dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local POLICY = std.extVar('POLICY');
local MEASUREMENT = std.extVar('MEASUREMENT');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');

if WITH_INSTANCE_VARIABLE then
  tdg_dashboard_raw(
    datasource=DATASOURCE,
    policy=POLICY,
    measurement=MEASUREMENT,
    alias=variable.influxdb.alias,
  ).addTemplate(
    grafana.template.new(
      name='alias',
      datasource=DATASOURCE,
      query=std.format(
        'SHOW TAG VALUES FROM %(policy_prefix)s"%(measurement)s" WITH KEY="label_pairs_alias"',
        {
          policy_prefix: if POLICY == 'default' then '' else std.format('"%s".', POLICY),
          measurement: MEASUREMENT,
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
  tdg_dashboard_raw(
    datasource=std.extVar('DATASOURCE'),
    policy=std.extVar('POLICY'),
    measurement=std.extVar('MEASUREMENT'),
    alias='/^.*$/',
  ).build()
