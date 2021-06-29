local common = import 'common.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: grafana.row.new(title='Tarantool operations statistics'),

  local operation_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    labelY1=null,
    operation=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    min=0,
    labelY1=labelY1,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(tnt_stats_op_total{job=~"%s",operation="%s"}[%s])', [job, operation, rate_time_range]),
        legendFormat='{{alias}}'
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', 'tnt_stats_op_total').where('label_pairs_operation', '=', operation)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  local space_operation_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    operation=null,
  ) = operation_rps(
    title=(if title != null then title else std.format('%s space requests', std.asciiUpper(operation))),
    description=(
      if description != null then
        description
      else
        std.format(|||
          total count of %s requests to all instance spaces.
          Graph shows average requests per second.
          If `No data` displayed for Prometheus panel,
          check up your 'rate_time_range' variable.
        |||, std.asciiUpper(operation))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='requests per second',
    operation=operation,
  ),

  space_select_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='select'
  ),

  space_insert_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='insert'
  ),

  space_replace_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='replace'
  ),

  space_upsert_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='upsert'
  ),

  space_update_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='update'
  ),

  space_delete_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='delete'
  ),

  call_rps(
    title='Call requests',
    description=|||
      Requests to execute stored procedures.
      Graph shows average requests per second.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='requests per second',
    operation='call'
  ),

  eval_rps(
    title='Eval calls',
    description=|||
      Calls to evaluate Lua code.
      Graph shows average requests per second.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='requests per second',
    operation='eval'
  ),

  error_rps(
    title='Request errors',
    description=|||
      Requests resulted in error.
      Graph shows average errors per second.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='errors per second',
    operation='error'
  ),

  auth_rps(
    title='Authentication requests',
    description=|||
      Authentication requests.
      Graph shows average errors per second.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='requests per second',
    operation='auth'
  ),

  SQL_prepare_rps(
    title='SQL prepare calls',
    description=|||
      SQL prepare calls. Panel works with Tarantool 2.x.
      Graph shows average errors per second.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='requests per second',
    operation='prepare'
  ),

  SQL_execute_rps(
    title='SQL execute calls',
    description=|||
      SQL execute calls. Panel works with Tarantool 2.x.
      Graph shows average errors per second.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    labelY1='requests per second',
    operation='execute'
  ),
}
