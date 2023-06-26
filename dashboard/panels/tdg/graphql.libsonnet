local common_utils = import 'dashboard/panels/common.libsonnet';

{
  row:: common_utils.row('TDG GraphQL requests'),

  local rps_target(
    cfg,
    metric_name,
  ) = common_utils.target(
    cfg,
    metric_name,
    legend={
      prometheus: '{{operation_name}} ({{schema}}, {{entity}}) — {{alias}}',
      influxdb: '$tag_label_pairs_operation_name ($tag_label_pairs_schema, $tag_label_pairs_entity) — $tag_label_pairs_alias',
    },
    group_tags=[
      'label_pairs_alias',
      'label_pairs_operation_name',
      'label_pairs_schema',
      'label_pairs_entity',
    ],
    rate=true,
  ),

  local average_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == 'prometheus' then
      local filters = common_utils.prometheus_query_filters(cfg.filters);
      prometheus.target(
        expr=std.format(
          |||
            %(metrics_prefix)s%(metric_name_sum)s{%(filters)s} / %(metrics_prefix)s%(metric_name_count)s{%(filters)s}
          |||,
          {
            metrics_prefix: cfg.metrics_prefix,
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            filters: filters,
          }
        ),
        legendFormat='{{operation_name}} ({{schema}}, {{entity}}) — {{alias}}'
      )
    else if cfg.type == 'influxdb' then
      local filters = common_utils.influxdb_query_filters(cfg.filters);
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metrics_prefix)s%(metric_name_sum)s") / mean("%(metrics_prefix)s%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metrics_prefix)s%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metrics_prefix)s%(metric_name_sum)s' %(filters)s)
          AND $timeFilter),
          (SELECT "value" as "%(metrics_prefix)s%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metrics_prefix)s%(metric_name_count)s' %(filters)s)
          AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_operation_name",
          "label_pairs_schema", "label_pairs_entity" fill(null)
        |||, {
          metrics_prefix: cfg.metrics_prefix,
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
          filters: if filters == '' then '' else std.format('AND %s', filters),
        }),
        alias='$tag_label_pairs_operation_name ($tag_label_pairs_schema, $tag_label_pairs_entity) — $tag_label_pairs_alias'
      ),

  query_success_rps(
    cfg,
    title='Success queries',
    description=|||
      A number of successfully executed GraphQL queries.
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='request per second',
  ).addTarget(
    rps_target(cfg, 'tdg_graphql_query_time_count')
  ),

  query_success_latency(
    cfg,
    title='Success query latency',
    description=|||
      Average time of GraphQL query execution.
      Only success requests are count.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='average',
    format='ms',
  ).addTarget(
    average_target(cfg, 'tdg_graphql_query_time')
  ),

  query_error_rps(
    cfg,
    title='Error queries',
    description=|||
      A number of GraphQL queries failed to execute.
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='request per second',
  ).addTarget(
    rps_target(cfg, 'tdg_graphql_query_fail')
  ),

  mutation_success_rps(
    cfg,
    title='Success mutations',
    description=|||
      A number of successfully executed GraphQL mutations.
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='request per second',
  ).addTarget(
    rps_target(cfg, 'tdg_graphql_mutation_time_count')
  ),

  mutation_success_latency(
    cfg,
    title='Success mutation latency',
    description=|||
      Average time of GraphQL mutation execution.
      Only success requests are count.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='average',
    format='ms',
  ).addTarget(
    average_target(cfg, 'tdg_graphql_mutation_time')
  ),

  mutation_error_rps(
    cfg,
    title='Error mutations',
    description=|||
      A number of GraphQL mutations failed to execute.
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='request per second',
  ).addTarget(
    rps_target(cfg, 'tdg_graphql_mutation_fail')
  ),
}
