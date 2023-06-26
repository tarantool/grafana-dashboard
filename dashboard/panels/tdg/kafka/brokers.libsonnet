local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';

{
  row:: common_utils.row('TDG Kafka brokers statistics'),

  local brokers_target(
    cfg,
    metric_name,
    rate=false,
  ) = common_utils.target(
    cfg,
    metric_name,
    legend={
      prometheus: '{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      influxdb: '$tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
    },
    group_tags=[
      'label_pairs_alias',
      'label_pairs_name',
      'label_pairs_type',
      'label_pairs_connector_name',
      'label_pairs_broker_name',
    ],
    rate=rate,
  ),

  local brokers_quantile_target(
    cfg,
    metric_name,
  ) = common_utils.target(
    cfg,
    metric_name,
    additional_filters={
      prometheus: { quantile: ['=', '0.99'] },
      influxdb: { label_pairs_quantile: ['=', '0.99'] },
    },
    legend={
      prometheus: '{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      influxdb: '$tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
    },
    group_tags=[
      'label_pairs_alias',
      'label_pairs_name',
      'label_pairs_type',
      'label_pairs_connector_name',
      'label_pairs_broker_name',
    ],
    converter='last',
  ),

  stateage(
    cfg,
    title='Time since state change',
    description=|||
      Time since last broker state change.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='µs',
    legend_avg=false,
    legend_max=false,
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_stateage')
  ),

  connects(
    cfg,
    title='Connection attempts',
    description=|||
      Number of connection attempts to a broker, including successful and failed,
      and name resolution failures.
      Graph shows mean attempts per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='attempts per second',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_connects', rate=true)
  ),

  disconnects(
    cfg,
    title='Disconnects',
    description=|||
      Number of disconnects from a broker (triggered by broker, network, load-balancer, etc.)
      Graph shows mean disconnects per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='disconnects per second',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_disconnects', rate=true)
  ),

  poll_wakeups(
    cfg,
    title='Poll wakeups',
    description=|||
      Number of broker thread poll wakeups.
      Graph shows mean wakeups per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='wakeups per second',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_wakeups', rate=true)
  ),

  outbuf(
    cfg,
    title='Requests awaiting transmission',
    description=|||
      Number of requests awaiting transmission to a broker.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_outbuf_cnt')
  ),

  outbuf_msg(
    cfg,
    title='Messages awaiting transmission',
    description=|||
      Number of messages awaiting transmission to a broker.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_outbuf_msg_cnt')
  ),

  waitresp(
    cfg,
    title='Requests waiting response',
    description=|||
      Number of requests in-flight to a broker awaiting response.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_waitresp_cnt')
  ),

  waitresp_msg(
    cfg,
    title='Messages awaiting response',
    description=|||
      Number of messages in-flight to a broker awaiting response.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages',
    panel_width=6,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_waitresp_msg_cnt')
  ),

  requests(
    cfg,
    title='Requests sent',
    description=|||
      Number of requests sent to a broker.
      Graph shows mean attempts per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_tx', rate=true)
  ),

  request_bytes(
    cfg,
    title='Bytes sent',
    description=|||
      Amount of bytes sent to a broker.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_txbytes', rate=true)
  ),

  request_errors(
    cfg,
    title='Transmission errors',
    description=|||
      Number of transmission errors to a broker.
      Graph shows mean errors per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='errors per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_txerrs', rate=true)
  ),

  request_retries(
    cfg,
    title='Request retries',
    description=|||
      Number of request retries to a broker.
      Graph shows mean retries per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='retries per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_txretries', rate=true)
  ),

  request_idle(
    cfg,
    title='Time since socket send',
    description=|||
      Time since last socket send to a broker (or -1 if no sends yet for current connection).
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='µs',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_txidle')
  ),

  request_timeout(
    cfg,
    title='Requests timed out',
    description=|||
      Number of requests timed out for a broker.
      Graph shows mean retries per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_req_timeouts', rate=true)
  ),

  responses(
    cfg,
    title='Responses received',
    description=|||
      Number of responses received from a broker.
      Graph shows mean attempts per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='responses per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_rx', rate=true)
  ),

  response_bytes(
    cfg,
    title='Bytes received',
    description=|||
      Amount of bytes received from a broker.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_rxbytes', rate=true)
  ),

  response_errors(
    cfg,
    title='Response errors',
    description=|||
      Number of errors received from a broker.
      Graph shows mean errors per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='errors per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_rxerrs', rate=true)
  ),

  response_corriderrs(
    cfg,
    title='Response corellation errors',
    description=|||
      Number of mber of unmatched correlation ids in response
      (typically for timed out requests).
      Graph shows mean errors per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='errors per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_rxcorriderrs', rate=true)
  ),

  response_idle(
    cfg,
    title='Time since socket receive',
    description=|||
      Time since last socket receive (or -1 if no sends yet for current connection).
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='µs',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_rxidle')
  ),

  response_partial(
    cfg,
    title='Partial MessageSets received',
    description=|||
      Number of partial MessageSets received.
      Graph shows mean retries per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
  ).addTarget(
    brokers_target(cfg, 'tdg_kafka_broker_rxpartial', rate=true)
  ),

  requests_by_type(
    cfg,
    title='Requests sent by type',
    description=|||
      Number of requests sent, separated by type.
      Graph shows mean requests per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    legend_rightSide=true,
    panel_width=24,
    panel_height=10,
  ).addTarget(
    common_utils.target(
      cfg,
      'tdg_kafka_broker_req',
      legend={
        prometheus: '{{request}} — {{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
        influxdb: '$tag_label_pairs_request — $tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      },
      group_tags=[
        'label_pairs_alias',
        'label_pairs_name',
        'label_pairs_type',
        'label_pairs_connector_name',
        'label_pairs_broker_name',
        'label_pairs_request',
      ],
      rate=true,
    ),
  ),

  internal_producer_latency(
    cfg,
    title='Producer queue latency',
    description=|||
      99th percentile of internal producer queue latency.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(
    brokers_quantile_target(cfg, 'tdg_kafka_broker_int_latency')
  ),

  internal_request_latency(
    cfg,
    title='Request queue latency',
    description=|||
      99th percentile of internal request queue latency.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(
    brokers_quantile_target(cfg, 'tdg_kafka_broker_outbuf_latency')
  ),

  broker_latency(
    cfg,
    title='Broker latency',
    description=|||
      99th percentile of round-trip time.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(
    brokers_quantile_target(cfg, 'tdg_kafka_broker_rtt')
  ),

  broker_throttle(
    cfg,
    title='Broker throttle',
    description=|||
      99th percentile of broker throttling time.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='ms',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(
    brokers_quantile_target(cfg, 'tdg_kafka_broker_throttle')
  ),
}
