local common_utils = import 'dashboard/panels/common.libsonnet';
local kafka_utils = import 'dashboard/panels/tdg/kafka/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

{
  row:: common_utils.row('TDG Kafka common statistics'),

  queue_operations(
    cfg,
    title='Operations in queue',
    description=|||
      Number of ops (callbacks, events, etc) waiting in queue
      for application to serve with rd_kafka_poll().
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='operations',
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_replyq')
  ),

  message_current(
    cfg,
    title='Messages in queue',
    description=|||
      Current number of messages in producer queues.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='current',
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_msg_size')
  ),

  message_size(
    cfg,
    title='Size of messages in queue',
    description=|||
      Current number of messages in producer queues.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='current',
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_msg_cnt')
  ),

  requests(
    cfg,
    title='Requests sent',
    description=|||
      Number of requests sent to Kafka brokers.
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_tx', rate=true)
  ),

  request_bytes(
    cfg,
    title='Bytes sent',
    description=|||
      Amount of bytes transmitted to Kafka brokers.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_tx_bytes', rate=true)
  ),

  responses(
    cfg,
    title='Responses received',
    description=|||
      Number of responses received from Kafka brokers.
      Graph shows mean responses per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='responses per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_rx', rate=true)
  ),

  response_bytes(
    cfg,
    title='Bytes received',
    description=|||
      Amount of bytes received from Kafka brokers.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_rx_bytes', rate=true)
  ),

  messages_sent(
    cfg,
    title='Messages sent',
    description=|||
      Number of messages transmitted (produced) to Kafka brokers.
      Graph shows mean messages per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_txmsgs', rate=true)
  ),

  message_bytes_sent(
    cfg,
    title='Message bytes sent',
    description=|||
      Amount of message bytes (including framing, such as per-Message
      framing and MessageSet/batch framing) transmitted to Kafka brokers.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_txmsg_bytes', rate=true)
  ),

  messages_received(
    cfg,
    title='Messages received',
    description=|||
      Number of messages consumed, not including ignored
      messages (due to offset, etc), from Kafka brokers.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_rxmsgs', rate=true)
  ),

  message_bytes_received(
    cfg,
    title='Message bytes received',
    description=|||
      Amount of message bytes (including framing) received
      from Kafka brokers.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
    panel_width=6,
  ).addTarget(
    kafka_utils.kafka_target(cfg, 'tdg_kafka_rxmsg_bytes', rate=true)
  ),
}
