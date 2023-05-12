local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool operations statistics'),

  local operation_rps(
    cfg,
    title=null,
    description=null,
    labelY1=null,
    operation=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    min=0,
    labelY1=labelY1,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tnt_stats_op_total{job=~"%s",alias=~"%s",operation="%s"}[$__rate_interval])',
                        [cfg.job, cfg.filters.alias, operation]),
        legendFormat='{{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', 'tnt_stats_op_total')
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .where('label_pairs_operation', '=', operation)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  local space_operation_rps(
    cfg,
    title=null,
    description=null,
    operation=null,
  ) = operation_rps(
    cfg,
    title=(if title != null then title else std.format('%s space requests', std.asciiUpper(operation))),
    description=std.format(|||
      Total count of %s requests to all instance spaces.
      Graph shows average requests per second.
    |||, std.asciiUpper(operation)),
    labelY1='requests per second',
    operation=operation,
  ),

  space_select_rps(
    cfg,
    title=null,
    description=null,
  ):: space_operation_rps(
    cfg,
    title=title,
    description=description,
    operation='select'
  ),

  space_insert_rps(
    cfg,
    title=null,
    description=null,
  ):: space_operation_rps(
    cfg,
    title=title,
    description=description,
    operation='insert'
  ),

  space_replace_rps(
    cfg,
    title=null,
    description=null,
  ):: space_operation_rps(
    cfg,
    title=title,
    description=description,
    operation='replace'
  ),

  space_upsert_rps(
    cfg,
    title=null,
    description=null,
  ):: space_operation_rps(
    cfg,
    title=title,
    description=description,
    operation='upsert'
  ),

  space_update_rps(
    cfg,
    title=null,
    description=null,
  ):: space_operation_rps(
    cfg,
    title=title,
    description=description,
    operation='update'
  ),

  space_delete_rps(
    cfg,
    title=null,
    description=null,
  ):: space_operation_rps(
    cfg,
    title=title,
    description=description,
    operation='delete'
  ),

  call_rps(
    cfg,
    title='Call requests',
    description=|||
      Requests to execute stored procedures.
      Graph shows average requests per second.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    operation='call'
  ),

  eval_rps(
    cfg,
    title='Eval calls',
    description=|||
      Calls to evaluate Lua code.
      Graph shows average requests per second.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    operation='eval'
  ),

  error_rps(
    cfg,
    title='Request errors',
    description=|||
      Requests resulted in error.
      Graph shows average errors per second.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='errors per second',
    operation='error'
  ),

  auth_rps(
    cfg,
    title='Authentication requests',
    description=|||
      Authentication requests.
      Graph shows average requests per second.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    operation='auth'
  ),

  SQL_prepare_rps(
    cfg,
    title='SQL prepare calls',
    description=|||
      SQL prepare calls.
      Graph shows average calls per second.

      Panel works with Tarantool 2.x.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    operation='prepare'
  ),

  SQL_execute_rps(
    cfg,
    title='SQL execute calls',
    description=|||
      SQL execute calls.
      Graph shows average calls per second.

      Panel works with Tarantool 2.x.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    operation='execute'
  ),

  txn_begin_rps(
    cfg,
    title='Transaction begins',
    description=|||
      Panel displays the count of IPROTO_CALL and
      IPROTO_EVAL operations with `box.begin()`, IPROTO_EXECUTE
      operations with `TRANSACTION START` and IPROTO_BEGIN operations.
      Graph shows average calls per second.

      Panel works with Tarantool 2.10 or newer.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='begins per second',
    operation='begin'
  ),

  txn_commit_rps(
    cfg,
    title='Transaction commits',
    description=|||
      Panel displays the count of IPROTO_CALL and
      IPROTO_EVAL operations with `box.commit()`, IPROTO_EXECUTE
      operations with `COMMIT` and IPROTO_COMMIT operations.
      Graph shows average calls per second.

      Panel works with Tarantool 2.10 or newer.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='commits per second',
    operation='commit'
  ),

  txn_rollback_rps(
    cfg,
    title='Transaction rollbacks',
    description=|||
      Panel displays the count of IPROTO_CALL and
      IPROTO_EVAL operations with `box.rollback()`, IPROTO_EXECUTE
      operations with `ROLLBACK` and IPROTO_ROLLBACK operations.
      Graph shows average calls per second.

      Panel works with Tarantool 2.10 or newer.
    |||,
  ):: operation_rps(
    cfg,
    title=title,
    description=description,
    labelY1='rollbacks per second',
    operation='rollback'
  ),
}
