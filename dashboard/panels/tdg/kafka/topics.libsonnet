local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG Kafka topics statistics'),

  local topics_target(
    cfg,
    metric_name
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{topic}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),

  local partitions_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{topic}}, {{partition}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
          'label_pairs_partition',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic, $tag_label_pairs_partition) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),

  local partitions_rps_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{topic}}, {{partition}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
          'label_pairs_partition',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic, $tag_label_pairs_partition) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  local topics_quantile_target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",quantile="0.99"}',
                        [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{topic}}) — {{alias}} ({{type}}, {{connector_name}})',
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
          'label_pairs_topic',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_topic) — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('last'),

  age(
    cfg,
    title='Topic age',
    description=|||
      Age of client's topic object.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='ms',
    panel_width=12,
  ).addTarget(
    topics_target(cfg, 'tdg_kafka_topic_age')
  ),

  metadata_age(
    cfg,
    title='Topic metadata age',
    description=|||
      Age of metadata from broker for this topic.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='ms',
    panel_width=12,
  ).addTarget(
    topics_target(cfg, 'tdg_kafka_topic_metadata_age')
  ),

  topic_batchsize(
    cfg,
    title='Batch size',
    description=|||
      99th percentile of batch size.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='99th percentile',
    panel_width=12,
  ).addTarget(
    topics_quantile_target(cfg, 'tdg_kafka_topic_batchsize')
  ),

  topic_batchcnt(
    cfg,
    title='Batch message count',
    description=|||
      99th percentile of batch message count.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='99th percentile',
    panel_width=12,
  ).addTarget(
    topics_quantile_target(cfg, 'tdg_kafka_topic_batchcnt')
  ),

  partition_msgq(
    cfg,
    title='Messages in partition queue',
    description=|||
      Number of messages waiting to be produced in first-level
      queue of a partition.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_msgq_cnt')
  ),

  partition_xmit_msgq(
    cfg,
    title='Messages ready in partition queue',
    description=|||
      Number of messages ready to be produced in transmit
      queue of a partition.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_xmit_msgq_cnt')
  ),

  partition_fetchq_msgq(
    cfg,
    title='Messages pre-fetched in partition queue',
    description=|||
      Number of pre-fetched messages in fetch
      queue of a partition.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_fetchq_cnt')
  ),

  partition_msgq_bytes(
    cfg,
    title='Message size in partition queue',
    description=|||
      Amount of message bytes waiting to be produced in first-level
      queue of a partition.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_msgq_bytes')
  ),

  partition_xmit_msgq_bytes(
    cfg,
    title='Ready messages size in partition queue',
    description=|||
      Amount of message bytes ready to be produced in transmit
      queue of a partition.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_xmit_msgq_bytes')
  ),

  partition_fetchq_msgq_bytes(
    cfg,
    title='Pre-fetched messages size in partition queue',
    description=|||
      Amount of pre-fetched messages bytes in
      fetch queue of a partition.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_fetchq_size')
  ),

  partition_messages_sent(
    cfg,
    title='Partition messages sent',
    description=|||
      Number of messages transmitted (produced) of a partition topic.
      Graph shows mean messages per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(
    partitions_rps_target(cfg, 'tdg_kafka_topic_partitions_txmsgs')
  ),

  partition_message_bytes_sent(
    cfg,
    title='Partition message bytes sent',
    description=|||
      Amout of message bytes transmitted (produced) of a partition topic.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
    format='bytes',
    panel_width=6,
  ).addTarget(
    partitions_rps_target(cfg, 'tdg_kafka_topic_partitions_txbytes')
  ),

  partition_messages_consumed(
    cfg,
    title='Partition messages consumed',
    description=|||
      Number of messages consumed, not including ignored messages,
      of a partition topic.
      Graph shows mean messages per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages per second',
    panel_width=6,
  ).addTarget(
    partitions_rps_target(cfg, 'tdg_kafka_topic_partitions_rxmsgs')
  ),

  partition_message_bytes_consumed(
    cfg,
    title='Partition message bytes consumed',
    description=|||
      Amout of message bytes consumed, not including ignored messages,
      of a partition topic.
      Graph shows mean bytes per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='bytes per second',
    format='bytes',
    panel_width=6,
  ).addTarget(
    partitions_rps_target(cfg, 'tdg_kafka_topic_partitions_rxbytes')
  ),

  partition_messages_dropped(
    cfg,
    title='Partition messages dropped',
    description=|||
      Number of dropped outdated messages of a partition topic.
      Graph shows mean messages per second.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages per second',
    panel_width=12,
  ).addTarget(
    partitions_rps_target(cfg, 'tdg_kafka_topic_partitions_rx_ver_drops')
  ),

  partition_messages_in_flight(
    cfg,
    title='Partition messages in flight',
    description=|||
      Current number of messages in-flight to/from broker
      of a partition topic.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='messages per second',
    panel_width=12,
  ).addTarget(
    partitions_target(cfg, 'tdg_kafka_topic_partitions_msgs_inflight')
  ),
}
