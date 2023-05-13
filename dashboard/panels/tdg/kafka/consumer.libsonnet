local common_utils = import 'dashboard/panels/common.libsonnet';
local kafka_utils = import 'dashboard/panels/tdg/kafka/utils.libsonnet';

{
  row:: common_utils.row('TDG Kafka consumer statistics'),

  stateage(
    cfg,
    title='Time since state change',
    description=|||
      Time elapsed since last state change.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='ms',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_cgrp_stateage')
  ),

  rebalance_age(
    cfg,
    title='Time since rebalance',
    description=|||
      Time elapsed since last rebalance (assign or revoke).
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='ms',
    panel_width=12,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_cgrp_rebalance_age')
  ),

  rebalances(
    cfg,
    title='Rebalance activity',
    description=|||
      Number of rebalances (assign or revoke).
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='rebalances per second',
    panel_width=12,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_cgrp_rebalance_cnt', rate=true)
  ),

  assignment_size(
    cfg,
    title='Assignment partition count',
    description=|||
      Current assignment's partition count.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    panel_width=12,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_cgrp_assignment_size')
  ),
}
