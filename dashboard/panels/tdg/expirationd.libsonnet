local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import '../common.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG expirationd statistics'),

  local target(
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),

  local rps_target(
    datasource,
    metric_name,
    job=null,
    rate_time_range=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[%s])',
                        [metric_name, job, rate_time_range]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  tuples_checked(
    title='Tuples checked',
    description=common_utils.rate_warning(|||
      A number of task tuples checked for expiration (expired + skipped).
      Graph shows mean tuples per second.
    |||),
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(rps_target(
    datasource,
    'tdg_expiration_checked_count',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  tuples_expired(
    title='Tuples expired',
    description=common_utils.rate_warning(|||
      A number of task expired tuples.
      Graph shows mean tuples per second.
    |||, datasource),
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(rps_target(
    datasource,
    'tdg_expiration_expired_count',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  restarts(
    title='Restart count',
    description=|||
      A number of task restarts since start.
      From the start is equal to 1.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    panel_width=12,
  ).addTarget(target(
    datasource,
    'tdg_expiration_restarts',
    job,
    policy,
    measurement,
  )),

  operation_time(
    title='Operation time',
    description=|||
      A task's operation time.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    panel_width=12,
  ).addTarget(target(
    datasource,
    'tdg_expiration_working_time',
    job,
    policy,
    measurement,
  )),
}
