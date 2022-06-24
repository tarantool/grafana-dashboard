local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import '../../common.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG Kafka topics statistics'),

  local topics_target(
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} ({{topic}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),

  local partitions_target(
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} ({{topic}}, {{partition}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
          'label_pairs_partition',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic, $tag_label_pairs_partition) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),

  local partitions_rps_target(
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
        legendFormat='{{name}} ({{topic}}, {{partition}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
          'label_pairs_partition',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic, $tag_label_pairs_partition) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  local topics_quantile_target(
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
        legendFormat='{{name}} ({{topic}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      ).where('metric_name', '=', metric_name).where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('last'),

  age(
    title='Topic age',
    description=|||
      Age of client's topic object.
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
    panel_width=12,
  ).addTarget(topics_target(
    datasource,
    'tdg_kafka_topic_age',
    job,
    policy,
    measurement
  )),

  metadata_age(
    title='Topic metadata age',
    description=|||
      Age of metadata from broker for this topic.
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
    panel_width=12,
  ).addTarget(topics_target(
    datasource,
    'tdg_kafka_topic_metadata_age',
    job,
    policy,
    measurement
  )),

  topic_batchsize(
    title='Batch size',
    description=|||
      99th percentile of batch size.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='99th percentile',
    panel_width=12,
  ).addTarget(topics_quantile_target(
    datasource,
    'tdg_kafka_topic_batchsize',
    job,
    policy,
    measurement
  )),

  topic_batchcnt(
    title='Batch message count',
    description=|||
      99th percentile of batch message count.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='99th percentile',
    panel_width=12,
  ).addTarget(topics_quantile_target(
    datasource,
    'tdg_kafka_topic_batchcnt',
    job,
    policy,
    measurement
  )),

  partition_msgq(
    title='Messages in partition queue',
    description=|||
      Number of messages waiting to be produced in first-level
      queue of a partition.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_msgq_cnt',
    job,
    policy,
    measurement
  )),

  partition_xmit_msgq(
    title='Messages ready in partition queue',
    description=|||
      Number of messages ready to be produced in transmit
      queue of a partition.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_xmit_msgq_cnt',
    job,
    policy,
    measurement
  )),

  partition_fetchq_msgq(
    title='Messages pre-fetched in partition queue',
    description=|||
      Number of pre-fetched messages in fetch
      queue of a partition.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_fetchq_cnt',
    job,
    policy,
    measurement
  )),

  partition_msgq_bytes(
    title='Message size in partition queue',
    description=|||
      Amount of message bytes waiting to be produced in first-level
      queue of a partition.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_msgq_bytes',
    job,
    policy,
    measurement
  )),

  partition_xmit_msgq_bytes(
    title='Ready messages size in partition queue',
    description=|||
      Amount of message bytes ready to be produced in transmit
      queue of a partition.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_xmit_msgq_bytes',
    job,
    policy,
    measurement
  )),

  partition_fetchq_msgq_bytes(
    title='Pre-fetched messages size in partition queue',
    description=|||
      Amount of pre-fetched messages bytes in
      fetch queue of a partition.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_fetchq_size',
    job,
    policy,
    measurement
  )),

  partition_messages_sent(
    title='Partition messages sent',
    description=common_utils.rate_warning(|||
      Number of messages transmitted (produced) of a partition topic.
      Graph shows mean messages per second.
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
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(partitions_rps_target(
    datasource,
    'tdg_kafka_topic_partitions_txmsgs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  partition_message_bytes_sent(
    title='Partition message bytes sent',
    description=common_utils.rate_warning(|||
      Amout of message bytes transmitted (produced) of a partition topic.
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
    format='bytes',
    panel_width=6,
  ).addTarget(partitions_rps_target(
    datasource,
    'tdg_kafka_topic_partitions_txbytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  partition_messages_consumed(
    title='Partition messages consumed',
    description=common_utils.rate_warning(|||
      Number of messages consumed, not including ignored messages,
      of a partition topic.
      Graph shows mean messages per second.
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
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(partitions_rps_target(
    datasource,
    'tdg_kafka_topic_partitions_rxmsgs',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  partition_message_bytes_consumed(
    title='Partition message bytes consumed',
    description=common_utils.rate_warning(|||
      Amout of message bytes consumed, not including ignored messages,
      of a partition topic.
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
    format='bytes',
    panel_width=6,
  ).addTarget(partitions_rps_target(
    datasource,
    'tdg_kafka_topic_partitions_rxbytes',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  partition_messages_dropped(
    title='Partition messages dropped',
    description=common_utils.rate_warning(|||
      Number of dropped outdated messages of a partition topic.
      Graph shows mean messages per second.
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
    labelY1='messages per second',
    panel_width=12,
  ).addTarget(partitions_rps_target(
    datasource,
    'tdg_kafka_topic_partitions_rx_ver_drops',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  partition_messages_in_flight(
    title='Partition messages in flight',
    description=|||
      Current number of messages in-flight to/from broker
      of a partition topic.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='messages per second',
    panel_width=12,
  ).addTarget(partitions_target(
    datasource,
    'tdg_kafka_topic_partitions_msgs_inflight',
    job,
    policy,
    measurement,
  )),
}
