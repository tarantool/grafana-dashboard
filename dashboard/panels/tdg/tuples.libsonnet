local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG tuples statistics'),

  local average_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s",alias=~"%(alias)s"} /
            %(metric_name_count)s{job=~"%(job)s",alias=~"%(alias)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: cfg.filters.job[1],
            alias: cfg.filters.alias[1],
          }
        ),
        legendFormat='{{type_name}} — {{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s' AND "label_pairs_alias" =~ %(alias)s) AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s' AND "label_pairs_alias" =~ %(alias)s) AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_type_name" fill(null)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
          alias: cfg.filters.label_pairs_alias[1],
        }),
        alias='$tag_label_pairs_type_name — $tag_label_pairs_alias'
      ),

  tuples_scanned_average(
    cfg,
    title='Tuples scanned (average)',
    description=|||
      Amount of tuples scanned in request.
      Data resets between each collect.
      Graph shows average per request.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per request',
    panel_width=12,
  ).addTarget(
    average_target(cfg, 'tdg_scanned_tuples')
  ),

  tuples_returned_average(
    cfg,
    title='Tuples returned (average)',
    description=|||
      Amount of tuples returned in request.
      Data resets between each collect.
      Graph shows average per request.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per request',
    panel_width=12,
  ).addTarget(
    average_target(cfg, 'tdg_returned_tuples')
  ),

  tuples_scanned_max(
    cfg,
    title='Tuples scanned (max)',
    description=|||
      Amount of tuples scanned in request.
      Data resets between each collect.
      Graph shows maximum observation.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per request',
    decimals=0,
    panel_width=12,
  ).addTarget(
    common_utils.default_metric_target(cfg, 'tdg_scanned_tuples_max')
  ),

  tuples_returned_max(
    cfg,
    title='Tuples returned (max)',
    description=|||
      Amount of tuples returned in request.
      Data resets between each collect.
      Graph shows maximum observation.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per request',
    decimals=0,
    panel_width=12,
  ).addTarget(
    common_utils.default_metric_target(cfg, 'tdg_returned_tuples_max')
  ),
}
