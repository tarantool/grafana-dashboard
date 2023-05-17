local grafana = import 'grafonnet/grafana.libsonnet';

local config = import 'dashboard/build/config.libsonnet';
local dashboard = import 'dashboard/build/dashboard.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local yaml_cfg = importstr 'dashboard.yml';

local cfg = config.prepare(std.parseYaml(yaml_cfg));

dashboard(cfg).addPanels([
  common.row('My custom metrics'),

  common.default_graph(
    cfg,
    title='My custom component status',
    description=|||
      My custom component could have 3 statuses:
      code 2 is OK, code 1 is suspended process, code 0 means issues in component.
    |||,
    labelY1='requests per second',
    panel_width=24,
    panel_height=6,
  ).addTarget(common.target(
    cfg,
    metric_name='my_component_status',
    converter='last',
  )),

  common.default_graph(
    cfg,
    title='My custom component load',
    description=|||
      My custom component processes requests
      and collects info on process to summary collector
      'my_component_load_metric'.
    |||,
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(
    common.target(cfg, 'my_component_load_metric_count', rate=true)
  ),

  common.default_graph(
    cfg,
    title='My custom component process',
    description=|||
      My custom component processes requests
      and collects info on process to summary collector
      'my_component_load_metric'.
    |||,
    format='s',
    labelY1='process time',
    panel_width=12,
  ).addTarget(
    grafana.influxdb.target(
      policy=cfg.policy,
      measurement=cfg.measurement,
      group_tags=['label_pairs_alias'],
      alias='$tag_label_pairs_alias',
      fill='null',
    ).where('metric_name', '=', 'my_component_load_metric')
    .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias[1])
    .where('label_pairs_quantile', '=', '0.99')
    .selectField('value').addConverter('mean')
  ),
]).build()
