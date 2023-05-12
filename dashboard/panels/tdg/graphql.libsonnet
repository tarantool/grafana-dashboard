local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG GraphQL requests'),

  local rps_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, cfg.filters.job[1], cfg.filters.alias[1]]),
        legendFormat='{{operation_name}} ({{schema}}, {{entity}}) — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_operation_name',
          'label_pairs_schema',
          'label_pairs_entity',
        ],
        alias='$tag_label_pairs_operation_name ($tag_label_pairs_schema, $tag_label_pairs_entity) — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name).where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias[1])
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

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
        legendFormat='{{operation_name}} ({{schema}}, {{entity}}) — {{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s' AND "label_pairs_alias" =~ %(alias)s)
          AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s' AND "label_pairs_alias" =~ %(alias)s)
          AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_operation_name",
          "label_pairs_schema", "label_pairs_entity" fill(null)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
          alias: cfg.filters.label_pairs_alias[1],
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
