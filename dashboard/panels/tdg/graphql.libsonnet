local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG GraphQL requests'),

  local rps_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, job, alias]),
        legendFormat='{{operation_name}} ({{schema}}, {{entity}}) — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_operation_name',
          'label_pairs_schema',
          'label_pairs_entity',
        ],
        alias='$tag_label_pairs_operation_name ($tag_label_pairs_schema, $tag_label_pairs_entity) — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  local average_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s",alias=~"%(alias)s"} /
            %(metric_name_count)s{job=~"%(job)s",alias=~"%(alias)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: job,
            alias: alias,
          }
        ),
        legendFormat='{{operation_name}} ({{schema}}, {{entity}}) — {{alias}}'
      )
    else if datasource_type == variable.datasource_type.influxdb then
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
          policy_prefix: if policy == 'default' then '' else std.format('"%(policy)s".', policy),
          measurement: measurement,
          alias: alias,
        }),
        alias='$tag_label_pairs_operation_name ($tag_label_pairs_schema, $tag_label_pairs_entity) — $tag_label_pairs_alias'
      ),

  query_success_rps(
    title='Success queries',
    description=|||
      A number of successfully executed GraphQL queries.
      Graph shows mean requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='request per second',
  ).addTarget(rps_target(
    datasource_type,
    'tdg_graphql_query_time_count',
    job,
    policy,
    measurement,
    alias,
  )),

  query_success_latency(
    title='Success query latency',
    description=|||
      Average time of GraphQL query execution.
      Only success requests are count.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='average',
    format='ms',
  ).addTarget(average_target(
    datasource_type,
    'tdg_graphql_query_time',
    job,
    policy,
    measurement,
    alias,
  )),

  query_error_rps(
    title='Error queries',
    description=|||
      A number of GraphQL queries failed to execute.
      Graph shows mean requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='request per second',
  ).addTarget(rps_target(
    datasource_type,
    'tdg_graphql_query_fail',
    job,
    policy,
    measurement,
    alias,
  )),

  mutation_success_rps(
    title='Success mutations',
    description=|||
      A number of successfully executed GraphQL mutations.
      Graph shows mean requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='request per second',
  ).addTarget(rps_target(
    datasource_type,
    'tdg_graphql_mutation_time_count',
    job,
    policy,
    measurement,
    alias,
  )),

  mutation_success_latency(
    title='Success mutation latency',
    description=|||
      Average time of GraphQL mutation execution.
      Only success requests are count.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='average',
    format='ms',
  ).addTarget(average_target(
    datasource_type,
    'tdg_graphql_mutation_time',
    job,
    policy,
    measurement,
    alias,
  )),

  mutation_error_rps(
    title='Error mutations',
    description=|||
      A number of GraphQL mutations failed to execute.
      Graph shows mean requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='request per second',
  ).addTarget(rps_target(
    datasource_type,
    'tdg_graphql_mutation_fail',
    job,
    policy,
    measurement,
    alias,
  )),
}
