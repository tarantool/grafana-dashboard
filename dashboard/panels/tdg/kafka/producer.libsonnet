local common_utils = import '../../common.libsonnet';
local kafka_utils = import 'utils.libsonnet';

{
  row:: common_utils.row('TDG Kafka producer statistics'),

  idemp_stateage(
    title='Time since idemp_state change',
    description=|||
      Time elapsed since last idemp_state change.
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
    'tdg_kafka_eos_idemp_stateage',
    job,
    policy,
    measurement
  )),

  txn_stateage(
    title='Time since txn_state change',
    description=|||
      Time elapsed since last txn_state change.
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
    'tdg_kafka_eos_txn_stateage',
    job,
    policy,
    measurement
  )),
}
