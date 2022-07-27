local common_utils = import 'dashboard/panels/common.libsonnet';
local kafka_utils = import 'dashboard/panels/tdg/kafka/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

{
  row:: common_utils.row('TDG Kafka common statistics'),

  queue_operations(
    title='Operations in queue',
    description=|||
      Number of ops (callbacks, events, etc) waiting in queue
      for application to serve with rd_kafka_poll().
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='operations',
  ).addTarget(kafka_utils.kafka_target(
    datasource_type,
    'tdg_kafka_replyq',
    job,
    policy,
    measurement
  )),

  message_current(
    title='Messages in queue',
    description=|||
      Current number of messages in producer queues.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='current',
  ).addTarget(kafka_utils.kafka_target(
    datasource_type,
    'tdg_kafka_msg_size',
    job,
    policy,
    measurement
  )),

  message_size(
    title='Size of messages in queue',
    description=|||
      Current number of messages in producer queues.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='current',
  ).addTarget(kafka_utils.kafka_target(
    datasource_type,
    'tdg_kafka_msg_cnt',
    job,
    policy,
    measurement
  )),

  requests(
    title='Requests sent',
    description=common_utils.rate_warning(|||
      Number of requests sent to Kafka brokers.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_tx',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  request_bytes(
    title='Bytes sent',
    description=common_utils.rate_warning(|||
      Amount of bytes transmitted to Kafka brokers.
      Graph shows mean bytes per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_tx_bytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  responses(
    title='Responses received',
    description=common_utils.rate_warning(|||
      Number of responses received from Kafka brokers.
      Graph shows mean responses per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='responses per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_rx',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  response_bytes(
    title='Bytes received',
    description=common_utils.rate_warning(|||
      Amount of bytes received from Kafka brokers.
      Graph shows mean bytes per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_rx_bytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  messages_sent(
    title='Messages sent',
    description=common_utils.rate_warning(|||
      Number of messages transmitted (produced) to Kafka brokers.
      Graph shows mean messages per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_txmsgs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  message_bytes_sent(
    title='Message bytes sent',
    description=common_utils.rate_warning(|||
      Amount of message bytes (including framing, such as per-Message
      framing and MessageSet/batch framing) transmitted to Kafka brokers.
      Graph shows mean bytes per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_txmsg_bytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  messages_received(
    title='Messages received',
    description=common_utils.rate_warning(|||
      Number of messages consumed, not including ignored
      messages (due to offset, etc), from Kafka brokers.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_rxmsgs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  message_bytes_received(
    title='Message bytes received',
    description=common_utils.rate_warning(|||
      Amount of message bytes (including framing) received
      from Kafka brokers.
      Graph shows mean bytes per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(kafka_utils.kafka_rps_target(
    datasource_type,
    'tdg_kafka_rxmsg_bytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),
}
