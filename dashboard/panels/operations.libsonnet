local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';
local utils = import 'dashboard/utils.libsonnet';

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
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    min=0,
    labelY1=labelY1,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tnt_stats_op_total{job=~"%s",alias=~"%s",operation="%s",%s}[$__rate_interval])',
                        [job, alias, operation, utils.generate_labels_string(labels)]),
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
    labels=null,
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
    labels=labels,
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
    labels=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='select',
    labels=labels,
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
    labels=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='insert',
    labels=labels,
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
    labels=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='replace',
    labels=labels,
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
    labels=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='upsert',
    labels=labels,
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
    labels=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='update',
    labels=labels,
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
    labels=null,
  ):: space_operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    operation='delete',
    labels=labels,
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
    labels=null,
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
    operation='call',
    labels=labels,
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
    labels=null,
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
    operation='eval',
    labels=labels,
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
    labels=null,
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
    operation='error',
    labels=labels,
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
    labels=null,
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
    operation='auth',
    labels=labels,
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
    labels=null,
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
    operation='prepare',
    labels=labels,
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
    labels=null,
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
    operation='execute',
    labels=labels,
  ),

  txn_begin_rps(
    title='Transaction begins',
    description=|||
      Panel displays the count of IPROTO_CALL and
      IPROTO_EVAL operations with `box.begin()`, IPROTO_EXECUTE
      operations with `TRANSACTION START` and IPROTO_BEGIN operations.
      Graph shows average calls per second.

      Panel works with Tarantool 2.10 or newer.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='begins per second',
    operation='begin',
    labels=labels,
  ),

  txn_commit_rps(
    title='Transaction commits',
    description=|||
      Panel displays the count of IPROTO_CALL and
      IPROTO_EVAL operations with `box.commit()`, IPROTO_EXECUTE
      operations with `COMMIT` and IPROTO_COMMIT operations.
      Graph shows average calls per second.

      Panel works with Tarantool 2.10 or newer.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='commits per second',
    operation='commit',
    labels=labels,
  ),

  txn_rollback_rps(
    title='Transaction rollbacks',
    description=|||
      Panel displays the count of IPROTO_CALL and
      IPROTO_EVAL operations with `box.rollback()`, IPROTO_EXECUTE
      operations with `ROLLBACK` and IPROTO_ROLLBACK operations.
      Graph shows average calls per second.

      Panel works with Tarantool 2.10 or newer.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    labelY1='rollbacks per second',
    operation='rollback',
    labels=labels,
  ),
}
