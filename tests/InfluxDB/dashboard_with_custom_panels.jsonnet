local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/influxdb_dashboard.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

dashboard.addPanels([
  common.row('My custom metrics'),

  common.default_graph(
    title='My custom component status',
    description=|||
      My custom component could have 3 statuses:
      code 2 is OK, code 1 is suspended process, code 0 means issues in component.
    |||,
    datasource=variable.datasource.influxdb,
    labelY1='requests per second',
    panel_width=24,
    panel_height=6,
  ).addTarget(common.default_metric_target(
    datasource_type=variable.datasource_type.influxdb,
    metric_name='my_component_status',
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
    converter='last',
  )),

  common.default_graph(
    title='My custom component load',
    description=|||
      My custom component processes requests
      and collects info on process to summary collector
      'my_component_load_metric'.
    |||,
    datasource=variable.datasource.influxdb,
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type=variable.datasource_type.influxdb,
    metric_name='my_component_load_metric_count',
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement,
  )),

  common.default_graph(
    title='My custom component process',
    description=|||
      My custom component processes requests
      and collects info on process to summary collector
      'my_component_load_metric'.
    |||,
    datasource=variable.datasource.influxdb,
    format='s',
    labelY1='process time',
    panel_width=12,
  ).addTarget(
    grafana.influxdb.target(
      policy=variable.influxdb.policy,
      measurement=variable.influxdb.measurement,
      group_tags=['label_pairs_alias'],
      alias='$tag_label_pairs_alias',
    ).where('metric_name', '=', 'my_component_load_metric').where('label_pairs_quantile', '=', '0.99')
    .selectField('value').addConverter('mean')
  ),
]).build()
