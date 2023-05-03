local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local utils = import 'dashboard/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('expirationd module statistics'),

  local target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
    labels=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"%s}', [metric_name, job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean'),

  local rps_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
    labels=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"%s}[$__rate_interval])',
                        [metric_name, job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  tuples_checked(
    title='Tuples checked',
    description=|||
      A number of task tuples checked for expiration (expired + skipped).
      Graph shows mean tuples per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(rps_target(
    datasource_type,
    'expirationd_checked_count',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  tuples_expired(
    title='Tuples expired',
    description=|||
      A number of task expired tuples.
      Graph shows mean tuples per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(rps_target(
    datasource_type,
    'expirationd_expired_count',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  restarts(
    title='Restart count',
    description=|||
      A number of task restarts since start.
      From the start is equal to 1.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    panel_width=12,
  ).addTarget(target(
    datasource_type,
    'expirationd_restarts',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  operation_time(
    title='Operation time',
    description=|||
      A task's operation time.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    panel_width=12,
  ).addTarget(target(
    datasource_type,
    'expirationd_working_time',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),
}
