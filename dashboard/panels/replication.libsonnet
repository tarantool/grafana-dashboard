local grafana = import 'grafonnet/grafana.libsonnet';

local timeseries = import 'dashboard/grafana/timeseries.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local utils = import 'dashboard/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Replication overview'),

  replication_status(
    title='Tarantool replication status',
    description=|||
      `follows` status means replication is running.
      Otherwise, `not running` is displayed.

      Panel works with `metrics >= 0.13.0` and Grafana 8.x.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=datasource,
    panel_width=8,
    max=1,
    min=0,
  ).addValueMapping(
    1, 'green', 'follows'
  ).addValueMapping(
    0, 'red', 'not running'
  ).addRangeMapping(
    0.001, 0.999, '-'
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_replication_status{job=~"%s",alias=~"%s"%s}', [job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{alias}} {{stream}} ({{id}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_stream', 'label_pairs_id'],
        alias='$tag_label_pairs_alias $tag_label_pairs_stream ($tag_label_pairs_id)',
        fill='null',
      ).where('metric_name', '=', 'tnt_replication_status').where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('last')
  ),

  replication_lag(
    title='Tarantool replication lag',
    description=|||
      Replication lag value for Tarantool instance.

      Panel works with `metrics >= 0.13.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    decimals=null,
    decimalsY1=null,
    legend_avg=false,
    min=0,
    panel_width=8,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_replication_lag{job=~"%s",alias=~"%s"%s}', [job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{alias}} ({{id}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_id'],
        alias='$tag_label_pairs_alias ($tag_label_pairs_id)',
        fill='null',
      ).where('metric_name', '=', 'tnt_replication_lag').where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean')
  ),

  clock_delta(
    title='Instances clock delta',
    description=|||
      Clock drift across the cluster.
      max shows difference with the fastest clock (always positive),
      min shows difference with the slowest clock (always negative).

      Panel works with `metrics >= 0.10.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    decimals=null,
    decimalsY1=null,
    fill=1,
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_clock_delta{job=~"%s",alias=~"%s"%s}', [job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{alias}} ({{delta}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_delta'],
        alias='$tag_label_pairs_alias ($tag_label_pairs_delta)',
        fill='null',
      ).where('metric_name', '=', 'tnt_clock_delta').where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('last')
  ),

  local syncro_warning(description) = std.join(
    '\n',
    [description, |||
      Panel works with metrics 0.15.0 or newer, Tarantool 2.8.1 or newer.
    |||]
  ),

  synchro_queue_owner(
    title='Synchronous queue owner',
    description=syncro_warning(|||
      Instance ID of the current synchronous replication master.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='owner id',
    decimals=0,
    panel_width=6,
    legend_avg=false,
    legend_max=false,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_synchro_queue_owner',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  synchro_queue_term(
    title='Synchronous queue term',
    description=syncro_warning(|||
      Current queue term.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='term',
    decimals=0,
    panel_width=6,
    legend_avg=false,
    legend_max=false,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_synchro_queue_term',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  synchro_queue_length(
    title='Synchronous queue transactions',
    description=syncro_warning(|||
      Count of transactions collecting confirmations now.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='current',
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_synchro_queue_len',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  synchro_queue_busy(
    title='Synchronous queue busy',
    description=syncro_warning(|||
      Whether the queue is processing any system entry (CONFIRM/ROLLBACK/PROMOTE/DEMOTE).

      Panel works with Grafana 8.x.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=datasource,
    panel_width=6,
    max=1,
    min=0,
  ).addValueMapping(
    1, 'yellow', 'busy'
  ).addValueMapping(
    0, 'green', 'not busy'
  ).addRangeMapping(
    0.001, 0.999, '-'
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_synchro_queue_busy',
    job,
    policy,
    measurement,
    alias,
    labels=labels
  )),
}
