local common_utils = import 'dashboard/panels/common.libsonnet';
local kafka_utils = import 'dashboard/panels/tdg/kafka/utils.libsonnet';

{
  row:: common_utils.row('TDG Kafka producer statistics'),

  idemp_stateage(
    title='Time since idemp_state change',
    description=|||
      Time elapsed since last idemp_state change.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='ms',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(kafka_utils.kafka_target(
    datasource_type,
    'tdg_kafka_eos_idemp_stateage',
    job,
    policy,
    measurement,
    alias,
  )),

  txn_stateage(
    title='Time since txn_state change',
    description=|||
      Time elapsed since last txn_state change.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='ms',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(kafka_utils.kafka_target(
    datasource_type,
    'tdg_kafka_eos_txn_stateage',
    job,
    policy,
    measurement,
    alias,
  )),
}
