local grafana = import 'grafonnet/grafana.libsonnet';
local target = import 'target.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;

{
  local operation_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    operation=null,
  ) = graph.new(
    title=(if title != null then title else std.format('%s requests', std.asciiUpper(operation))),
    description=(
      if description != null then
        description
      else
        std.format('Average count of %s requests per second from all Tarantool spaces', std.asciiUpper(operation))
    ),
    datasource=datasource,

    format='none',
    labelY1='requests per second',
    fill=0,
    decimals=2,
    decimalsY1=0,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    influxdb.target(
      policy=policy,
      measurement=measurement,
      group_tags=['label_pairs_alias'],
      alias='$tag_label_pairs_alias',
    ).where('metric_name', '=', 'tnt_stats_op_total').where('label_pairs_operation', '=', operation)
    .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  select_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    operation='select'
  ),

  insert_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    operation='insert'
  ),

  replace_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    operation='replace'
  ),

  upsert_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    operation='upsert'
  ),

  update_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    operation='update'
  ),

  delete_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    operation='delete'
  ),
}
