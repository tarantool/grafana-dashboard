local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG tuples statistics'),

  local average_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s"} /
            %(metric_name_count)s{job=~"%(job)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: job,
          }
        ),
        legendFormat='{{type_name}} — {{alias}}'
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s') AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s') AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_type_name" fill(none)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if policy == 'default' then '' else std.format('"%(policy)s".', policy),
          measurement: measurement,
        }),
        alias='$tag_label_pairs_type_name — $tag_label_pairs_alias'
      ),

  tuples_scanned_average(
    title='Tuples scanned (average)',
    description=|||
      Amount of tuples scanned in request.
      Data resets between each collect.
      Graph shows average per request.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per request',
    panel_width=12,
  ).addTarget(average_target(
    datasource_type,
    'tdg_scanned_tuples',
    job,
    policy,
    measurement,
  )),

  tuples_returned_average(
    title='Tuples returned (average)',
    description=|||
      Amount of tuples returned in request.
      Data resets between each collect.
      Graph shows average per request.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per request',
    panel_width=12,
  ).addTarget(average_target(
    datasource_type,
    'tdg_returned_tuples',
    job,
    policy,
    measurement,
  )),

  tuples_scanned_max(
    title='Tuples scanned (max)',
    description=|||
      Amount of tuples scanned in request.
      Data resets between each collect.
      Graph shows maximum observation.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per request',
    decimals=0,
    panel_width=12,
  ).addTarget(common_utils.default_metric_target(
    datasource_type,
    'tdg_scanned_tuples_max',
    job,
    policy,
    measurement,
  )),

  tuples_returned_max(
    title='Tuples returned (max)',
    description=|||
      Amount of tuples returned in request.
      Data resets between each collect.
      Graph shows maximum observation.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per request',
    decimals=0,
    panel_width=12,
  ).addTarget(common_utils.default_metric_target(
    datasource_type,
    'tdg_returned_tuples_max',
    job,
    policy,
    measurement,
  )),
}
