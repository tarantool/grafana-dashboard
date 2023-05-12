local common_utils = import 'dashboard/panels/common.libsonnet';
local kafka_utils = import 'dashboard/panels/tdg/kafka/utils.libsonnet';

{
  row:: common_utils.row('TDG Kafka producer statistics'),

  idemp_stateage(
    cfg,
    title='Time since idemp_state change',
    description=|||
      Time elapsed since last idemp_state change.
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
    kafka_utils.kafka_target(cfg, 'tdg_kafka_eos_idemp_stateage')
  ),

  txn_stateage(
    cfg,
    title='Time since txn_state change',
    description=|||
      Time elapsed since last txn_state change.
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
    kafka_utils.kafka_target(cfg, 'tdg_kafka_eos_txn_stateage')
  ),
}
