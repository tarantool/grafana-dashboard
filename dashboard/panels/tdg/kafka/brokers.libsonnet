local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import '../../common.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG Kafka brokers statistics'),

  local brokers_target(
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource == '${DS_INFLUXDB}' then
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
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),

  local brokers_rps_target(
    datasource,
    metric_name,
    job=null,
    rate_time_range=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[%s])',
                        [metric_name, job, rate_time_range]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource == '${DS_INFLUXDB}' then
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
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  local brokers_quantile_target(
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s",quantile="0.99"}',
                        [metric_name, job]),
        legendFormat='{{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource == '${DS_INFLUXDB}' then
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
      ).where('metric_name', '=', metric_name).where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('last'),

  stateage(
    title='Time since state change',
    description=|||
      Time since last broker state change.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='µs',
    legend_avg=false,
    legend_max=false,
    panel_width=6,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_stateage',
    job,
    policy,
    measurement
  )),

  connects(
    title='Connection attempts',
    description=common_utils.rate_warning(|||
      Number of connection attempts to a broker, including successful and failed,
      and name resolution failures.
      Graph shows mean attempts per second.
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
    labelY1='attempts per second',
    panel_width=6,
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_connects',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  disconnects(
    title='Disconnects',
    description=common_utils.rate_warning(|||
      Number of disconnects from a broker (triggered by broker, network, load-balancer, etc.)
      Graph shows mean disconnects per second.
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
    labelY1='disconnects per second',
    panel_width=6,
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_disconnects',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  poll_wakeups(
    title='Poll wakeups',
    description=common_utils.rate_warning(|||
      Number of broker thread poll wakeups.
      Graph shows mean wakeups per second.
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
    labelY1='wakeups per second',
    panel_width=6,
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_wakeups',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  outbuf(
    title='Requests awaiting transmission',
    description=|||
      Number of requests awaiting transmission to a broker.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_outbuf_cnt',
    job,
    policy,
    measurement
  )),

  outbuf_msg(
    title='Messages awaiting transmission',
    description=|||
      Number of messages awaiting transmission to a broker.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='messages',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_outbuf_msg_cnt',
    job,
    policy,
    measurement
  )),

  waitresp(
    title='Requests waiting response',
    description=|||
      Number of requests in-flight to a broker awaiting response.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_waitresp_cnt',
    job,
    policy,
    measurement
  )),

  waitresp_msg(
    title='Messages awaiting response',
    description=|||
      Number of messages in-flight to a broker awaiting response.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='messages',
    panel_width=6,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_waitresp_msg_cnt',
    job,
    policy,
    measurement
  )),

  requests(
    title='Requests sent',
    description=common_utils.rate_warning(|||
      Number of requests sent to a broker.
      Graph shows mean attempts per second.
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
    labelY1='requests per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_tx',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  request_bytes(
    title='Bytes sent',
    description=common_utils.rate_warning(|||
      Amount of bytes sent to a broker.
      Graph shows mean bytes per second.
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
    labelY1='bytes per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_txbytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  request_errors(
    title='Transmission errors',
    description=common_utils.rate_warning(|||
      Number of transmission errors to a broker.
      Graph shows mean errors per second.
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
    labelY1='errors per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_txerrs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  request_retries(
    title='Request retries',
    description=common_utils.rate_warning(|||
      Number of request retries to a broker.
      Graph shows mean retries per second.
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
    labelY1='retries per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_txretries',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  request_idle(
    title='Time since socket send',
    description=|||
      Time since last socket send to a broker (or -1 if no sends yet for current connection).
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='µs',
    legend_avg=false,
    legend_max=false,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_txidle',
    job,
    policy,
    measurement
  )),

  request_timeout(
    title='Requests timed out',
    description=common_utils.rate_warning(|||
      Number of requests timed out for a broker.
      Graph shows mean retries per second.
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
    labelY1='requests per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_req_timeouts',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  responses(
    title='Responses received',
    description=common_utils.rate_warning(|||
      Number of responses received from a broker.
      Graph shows mean attempts per second.
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
    labelY1='responses per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_rx',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  response_bytes(
    title='Bytes received',
    description=common_utils.rate_warning(|||
      Amount of bytes received from a broker.
      Graph shows mean bytes per second.
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
    labelY1='bytes per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_rxbytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  response_errors(
    title='Response errors',
    description=common_utils.rate_warning(|||
      Number of errors received from a broker.
      Graph shows mean errors per second.
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
    labelY1='errors per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_rxerrs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  response_corriderrs(
    title='Response corellation errors',
    description=common_utils.rate_warning(|||
      Number of mber of unmatched correlation ids in response
      (typically for timed out requests).
      Graph shows mean errors per second.
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
    labelY1='errors per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_rxcorriderrs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  response_idle(
    title='Time since socket receive',
    description=|||
      Time since last socket receive (or -1 if no sends yet for current connection).
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='µs',
    legend_avg=false,
    legend_max=false,
  ).addTarget(brokers_target(
    datasource,
    'tdg_kafka_broker_rxidle',
    job,
    policy,
    measurement
  )),

  response_partial(
    title='Partial MessageSets received',
    description=common_utils.rate_warning(|||
      Number of partial MessageSets received.
      Graph shows mean retries per second.
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
    labelY1='requests per second',
  ).addTarget(brokers_rps_target(
    datasource,
    'tdg_kafka_broker_rxpartial',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  requests_by_type(
    title='Requests sent by type',
    description=common_utils.rate_warning(|||
      Number of requests sent, separated by type.
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
    labelY1='requests per second',
    legend_rightSide=true,
    panel_width=24,
    panel_height=10,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(tdg_kafka_broker_req{job=~"%s"}[%s])',
                        [job, rate_time_range]),
        legendFormat='{{request}} — {{name}} ({{broker_name}}) — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource == '${DS_INFLUXDB}' then
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
      ).where('metric_name', '=', 'tdg_kafka_broker_req')
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  internal_producer_latency(
    title='Producer queue latency',
    description=|||
      99th percentile of internal producer queue latency.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource,
    'tdg_kafka_broker_int_latency',
    job,
    policy,
    measurement
  )),

  internal_request_latency(
    title='Request queue latency',
    description=|||
      99th percentile of internal request queue latency.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource,
    'tdg_kafka_broker_outbuf_latency',
    job,
    policy,
    measurement
  )),

  broker_latency(
    title='Broker latency',
    description=|||
      99th percentile of round-trip time.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='µs',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource,
    'tdg_kafka_broker_rtt',
    job,
    policy,
    measurement
  )),

  broker_throttle(
    title='Broker throttle',
    description=|||
      99th percentile of broker throttling time.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='ms',
    labelY1='99th percentile',
    panel_width=6,
  ).addTarget(brokers_quantile_target(
    datasource,
    'tdg_kafka_broker_throttle',
    job,
    policy,
    measurement
  )),
}
