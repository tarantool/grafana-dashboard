local common_utils = import '../../common.libsonnet';
local kafka_utils = import 'utils.libsonnet';

{
  row:: common_utils.row('TDG Kafka consumer statistics'),

  stateage(
    title='Time since state change',
    description=|||
      Time elapsed since last state change.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='ms',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(kafka_utils.kafka_target(
    datasource,
    'tdg_kafka_cgrp_stateage',
    job,
    policy,
    measurement
  )),

  rebalance_age(
    title='Time since rebalance',
    description=|||
      Time elapsed since last rebalance (assign or revoke).
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='ms',
    panel_width=12,
  ).addTarget(kafka_utils.kafka_target(
    datasource,
    'tdg_kafka_cgrp_rebalance_age',
    job,
    policy,
    measurement
  )),

  rebalances(
    title='Rebalance activity',
    description=common_utils.rate_warning(|||
      Number of rebalances (assign or revoke).
      Graph shows mean requests per second.
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
    labelY1='rebalances per second',
    panel_width=12,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource,
    'tdg_kafka_cgrp_rebalance_cnt',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  assignment_size(
    title='Assignment partition count',
    description=|||
      Current assignment's partition count.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    panel_width=12,
  ).addTarget(kafka_utils.kafka_target(
    datasource,
    'tdg_kafka_cgrp_assignment_size',
    job,
    policy,
    measurement
  )),
}
