local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG Kafka brokers statistics'),

  local brokers_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, job, alias]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
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
      .where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean'),

  local brokers_rps_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, job, alias]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
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
      .where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  local brokers_quantile_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",quantile="0.99"}',
                        [metric_name, job, alias]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
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
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('last'),

  stateage(
    title='Time since state change',
    description=|||
      Time since last broker state change.
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
    format='µs',
    legend_avg=false,
    legend_max=false,
    panel_width=6,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_stateage',
    job,
    policy,
    measurement,
    alias,
  )),

  connects(
    title='Connection attempts',
    description=|||
      Number of connection attempts to a broker, including successful and failed,
      and name resolution failures.
      Graph shows mean attempts per second.
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
    labelY1='attempts per second',
    panel_width=6,
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_connects',
    job,
    policy,
    measurement,
    alias,
  )),

  disconnects(
    title='Disconnects',
    description=|||
      Number of disconnects from a broker (triggered by broker, network, load-balancer, etc.)
      Graph shows mean disconnects per second.
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
    labelY1='disconnects per second',
    panel_width=6,
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_disconnects',
    job,
    policy,
    measurement,
    alias,
  )),

  poll_wakeups(
    title='Poll wakeups',
    description=|||
      Number of broker thread poll wakeups.
      Graph shows mean wakeups per second.
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
    labelY1='wakeups per second',
    panel_width=6,
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_wakeups',
    job,
    policy,
    measurement,
    alias,
  )),

  outbuf(
    title='Requests awaiting transmission',
    description=|||
      Number of requests awaiting transmission to a broker.
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
    labelY1='requests',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_outbuf_cnt',
    job,
    policy,
    measurement,
    alias,
  )),

  outbuf_msg(
    title='Messages awaiting transmission',
    description=|||
      Number of messages awaiting transmission to a broker.
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
    labelY1='messages',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_outbuf_msg_cnt',
    job,
    policy,
    measurement,
    alias,
  )),

  waitresp(
    title='Requests waiting response',
    description=|||
      Number of requests in-flight to a broker awaiting response.
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
    labelY1='requests',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_waitresp_cnt',
    job,
    policy,
    measurement,
    alias,
  )),

  waitresp_msg(
    title='Messages awaiting response',
    description=|||
      Number of messages in-flight to a broker awaiting response.
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
    labelY1='messages',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_waitresp_msg_cnt',
    job,
    policy,
    measurement,
    alias,
  )),

  requests(
    title='Requests sent',
    description=|||
      Number of requests sent to a broker.
      Graph shows mean attempts per second.
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
    labelY1='requests per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_tx',
    job,
    policy,
    measurement,
    alias,
  )),

  request_bytes(
    title='Bytes sent',
    description=|||
      Amount of bytes sent to a broker.
      Graph shows mean bytes per second.
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
    labelY1='bytes per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_txbytes',
    job,
    policy,
    measurement,
    alias,
  )),

  request_errors(
    title='Transmission errors',
    description=|||
      Number of transmission errors to a broker.
      Graph shows mean errors per second.
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
    labelY1='errors per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_txerrs',
    job,
    policy,
    measurement,
    alias,
  )),

  request_retries(
    title='Request retries',
    description=|||
      Number of request retries to a broker.
      Graph shows mean retries per second.
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
    labelY1='retries per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_txretries',
    job,
    policy,
    measurement,
    alias,
  )),

  request_idle(
    title='Time since socket send',
    description=|||
      Time since last socket send to a broker (or -1 if no sends yet for current connection).
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
    format='µs',
    legend_avg=false,
    legend_max=false,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_txidle',
    job,
    policy,
    measurement,
    alias,
  )),

  request_timeout(
    title='Requests timed out',
    description=|||
      Number of requests timed out for a broker.
      Graph shows mean retries per second.
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
    labelY1='requests per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_req_timeouts',
    job,
    policy,
    measurement,
    alias,
  )),

  responses(
    title='Responses received',
    description=|||
      Number of responses received from a broker.
      Graph shows mean attempts per second.
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
    labelY1='responses per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_rx',
    job,
    policy,
    measurement,
    alias,
  )),

  response_bytes(
    title='Bytes received',
    description=|||
      Amount of bytes received from a broker.
      Graph shows mean bytes per second.
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
    labelY1='bytes per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_rxbytes',
    job,
    policy,
    measurement,
    alias,
  )),

  response_errors(
    title='Response errors',
    description=|||
      Number of errors received from a broker.
      Graph shows mean errors per second.
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
    labelY1='errors per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_rxerrs',
    job,
    policy,
    measurement,
    alias,
  )),

  response_corriderrs(
    title='Response corellation errors',
    description=|||
      Number of mber of unmatched correlation ids in response
      (typically for timed out requests).
      Graph shows mean errors per second.
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
    labelY1='errors per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_rxcorriderrs',
    job,
    policy,
    measurement,
    alias,
  )),

  response_idle(
    title='Time since socket receive',
    description=|||
      Time since last socket receive (or -1 if no sends yet for current connection).
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
    format='µs',
    legend_avg=false,
    legend_max=false,
  ).addTarget(brokers_target(
    datasource_type,
    'tdg_kafka_broker_rxidle',
    job,
    policy,
    measurement,
    alias,
  )),

  response_partial(
    title='Partial MessageSets received',
    description=|||
      Number of partial MessageSets received.
      Graph shows mean retries per second.
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
    labelY1='requests per second',
  ).addTarget(brokers_rps_target(
    datasource_type,
    'tdg_kafka_broker_rxpartial',
    job,
    policy,
    measurement,
    alias,
  )),

  requests_by_type(
    title='Requests sent by type',
    description=|||
      Number of requests sent, separated by type.
      Graph shows mean requests per second.
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
    labelY1='requests per second',
    legend_rightSide=true,
    panel_width=24,
    panel_height=10,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tdg_kafka_broker_req{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [job, alias]),
        legendFormat='{{request}} — {{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
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
      .where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  internal_producer_latency(
    title='Producer queue latency',
    description=|||
      99th percentile of internal producer queue latency.
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
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource_type,
    'tdg_kafka_broker_int_latency',
    job,
    policy,
    measurement,
    alias,
  )),

  internal_request_latency(
    title='Request queue latency',
    description=|||
      99th percentile of internal request queue latency.
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
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource_type,
    'tdg_kafka_broker_outbuf_latency',
    job,
    policy,
    measurement,
    alias,
  )),

  broker_latency(
    title='Broker latency',
    description=|||
      99th percentile of round-trip time.
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
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource_type,
    'tdg_kafka_broker_rtt',
    job,
    policy,
    measurement,
    alias,
  )),

  broker_throttle(
    title='Broker throttle',
    description=|||
      99th percentile of broker throttling time.
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
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource_type,
    'tdg_kafka_broker_throttle',
    job,
    policy,
    measurement,
    alias,
  )),
}
