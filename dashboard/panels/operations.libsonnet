local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool operations statistics'),

  local operation_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labelY1=null,
    operation=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    min=0,
    labelY1=labelY1,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tnt_stats_op_total{job=~"%s",alias=~"%s",operation="%s"}[$__rate_interval])',
                        [job, alias, operation]),
        legendFormat='{{alias}}'
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', 'tnt_stats_op_total')
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_operation', '=', operation)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  local space_operation_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    operation=null,
  ) = operation_rps(
    title=(if title != null then title else std.format('%s space requests', std.asciiUpper(operation))),
    description=std.format(|||
      Total count of %s requests to all instance spaces.
      Graph shows average requests per second.
    |||, std.asciiUpper(operation)),
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='requests per second',
    operation=operation,
  ),

  space_select_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='select'
  ),

  space_insert_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='insert'
  ),

  space_replace_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='replace'
  ),

  space_upsert_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='upsert'
  ),

  space_update_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='update'
  ),

  space_delete_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='delete'
  ),

  call_rps(
    title='Call requests',
    description=|||
      Requests to execute stored procedures.
      Graph shows average requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='requests per second',
    operation='call'
  ),

  eval_rps(
    title='Eval calls',
    description=|||
      Calls to evaluate Lua code.
      Graph shows average requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='requests per second',
    operation='eval'
  ),

  error_rps(
    title='Request errors',
    description=|||
      Requests resulted in error.
      Graph shows average errors per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='errors per second',
    operation='error'
  ),

  auth_rps(
    title='Authentication requests',
    description=|||
      Authentication requests.
      Graph shows average requests per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='requests per second',
    operation='auth'
  ),

  SQL_prepare_rps(
    title='SQL prepare calls',
    description=|||
      SQL prepare calls.
      Graph shows average calls per second.

      Panel works with Tarantool 2.x.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='requests per second',
    operation='prepare'
  ),

  SQL_execute_rps(
    title='SQL execute calls',
    description=|||
      SQL execute calls.
      Graph shows average calls per second.

      Panel works with Tarantool 2.x.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='requests per second',
    operation='execute'
  ),
}
