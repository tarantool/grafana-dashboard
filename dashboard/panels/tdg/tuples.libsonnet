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
      local filters = common_utils.prometheus_query_filters(cfg.filters);
      prometheus.target(
        expr=std.format(
          |||
            rate(%(metrics_prefix)s%(metric_name_sum)s{%(filters)s}[$__rate_interval]) / rate(%(metrics_prefix)s%(metric_name_count)s{%(filters)s}[$__rate_interval])
          |||,
          {
            metrics_prefix: cfg.metrics_prefix,
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            filters: filters,
          }
        ),
        legendFormat='{{type_name}} — {{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      local filters = common_utils.influxdb_query_filters(cfg.filters);
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metrics_prefix)s%(metric_name_sum)s") / mean("%(metrics_prefix)s%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metrics_prefix)s%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metrics_prefix)s%(metric_name_sum)s' %(filters)s) AND $timeFilter),
          (SELECT "value" as "%(metrics_prefix)s%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metrics_prefix)s%(metric_name_count)s' %(filters)s) AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_type_name" fill(none)
        |||, {
          metrics_prefix: cfg.metrics_prefix,
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
          filters: if filters == '' then '' else std.format('AND %s', filters),
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
    common_utils.target(cfg, 'tdg_scanned_tuples_max')
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
    common_utils.target(cfg, 'tdg_returned_tuples_max')
  ),
}
