local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('expirationd module statistics'),

  local target(cfg, metric_name) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),

  local rps_target(cfg, metric_name) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  tuples_checked(
    cfg,
    title='Tuples checked',
    description=|||
      A number of task tuples checked for expiration (expired + skipped).
      Graph shows mean tuples per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(
    rps_target(cfg, 'expirationd_checked_count')
  ),

  tuples_expired(
    cfg,
    title='Tuples expired',
    description=|||
      A number of task expired tuples.
      Graph shows mean tuples per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(
    rps_target(cfg, 'expirationd_expired_count')
  ),

  restarts(
    cfg,
    title='Restart count',
    description=|||
      A number of task restarts since start.
      From the start is equal to 1.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    panel_width=12,
  ).addTarget(
    target(cfg, 'expirationd_restarts')
  ),

  operation_time(
    cfg,
    title='Operation time',
    description=|||
      A task's operation time.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='s',
    panel_width=12,
  ).addTarget(
    target(cfg, 'expirationd_working_time')
  ),
}
