local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/build/prometheus/dashboard.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

dashboard.addPanels([
  common.row('Tarantool network activity'),

  common.default_graph(
    title='My custom component status',
    description=|||
      My custom component could have 3 statuses:
      code 2 is OK, code 1 is suspended process, code 0 means issues in component.
    |||,
    datasource=variable.datasource_var.prometheus,
    labelY1='requests per second',
    panel_width=24,
    panel_height=6,
  ).addTarget(common.default_metric_target(
    datasource_type=variable.datasource_type.prometheus,
    metric_name='my_component_status',
    job=variable.prometheus.job,
    converter='last',
  )),

  common.default_graph(
    title='My custom component load',
    description=|||
      My custom component processes requests
      and collects info on process to summary collector
      'my_component_load_metric'.
    |||,
    datasource=variable.datasource_var.prometheus,
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type=variable.datasource_type.prometheus,
    metric_name='my_component_load_metric_count',
    job=variable.prometheus.job,
  )),

  common.default_graph(
    title='My custom component process',
    description=|||
      My custom component processes requests
      and collects info on process to summary collector
      'my_component_load_metric'.
    |||,
    datasource=variable.datasource_var.prometheus,
    format='s',
    labelY1='process time',
    panel_width=12,
  ).addTarget(grafana.prometheus.target(
    expr=std.format('my_component_load_metric{job=~"%s",quantile="0.99"}', [variable.prometheus.job]),
    legendFormat='{{alias}}',
  )),
]).build()
