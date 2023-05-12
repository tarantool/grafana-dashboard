local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard_raw = import 'dashboard/build/influxdb/dashboard_raw.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local DATASOURCE = std.extVar('DATASOURCE');
local POLICY = std.extVar('POLICY');
local MEASUREMENT = std.extVar('MEASUREMENT');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = std.extVar('TITLE');

if WITH_INSTANCE_VARIABLE then
  dashboard_raw(
    datasource=DATASOURCE,
    policy=POLICY,
    measurement=MEASUREMENT,
    alias=variable.influxdb.alias,
    title=TITLE,
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
  dashboard_raw(
    datasource=DATASOURCE,
    policy=POLICY,
    measurement=MEASUREMENT,
    alias='/^.*$/',
    title=TITLE,
  ).build()
