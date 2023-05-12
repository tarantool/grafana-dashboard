local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG Kafka brokers statistics'),

  local brokers_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_type',
          'label_pairs_connector_name',
          'label_pairs_broker_name',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),

  local brokers_rps_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_type',
          'label_pairs_connector_name',
          'label_pairs_broker_name',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  local brokers_quantile_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",quantile="0.99"}',
                        [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_type',
          'label_pairs_connector_name',
          'label_pairs_broker_name',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('last'),

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
    brokers_rps_target(cfg, 'tdg_kafka_broker_connects')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_disconnects')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_wakeups')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_tx')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_txbytes')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_txerrs')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_txretries')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_req_timeouts')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_rx')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_rxbytes')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_rxerrs')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_rxcorriderrs')
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
    brokers_rps_target(cfg, 'tdg_kafka_broker_rxpartial')
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
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tdg_kafka_broker_req{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{request}} — {{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_type',
          'label_pairs_connector_name',
          'label_pairs_broker_name',
          'label_pairs_request',
        ],
        alias='$tag_label_pairs_request — $tag_label_pairs_name ($tag_label_pairs_broker_name) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', 'tdg_kafka_broker_req')
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
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
