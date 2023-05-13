local grafana = import 'grafonnet/grafana.libsonnet';

local timeseries = import 'dashboard/grafana/timeseries.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Replication overview'),

  replication_status(
    cfg,
    title='Tarantool replication status',
    description=|||
      `follows` status means replication is running.
      Otherwise, `not running` is displayed.

      Panel works with `metrics >= 0.13.0` and Grafana 8.x.
    |||,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=cfg.datasource,
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
    common.target(
      cfg,
      'tnt_replication_status',
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} {{stream}} ({{id}})',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias $tag_label_pairs_stream ($tag_label_pairs_id)',
      },
      group_tags=['label_pairs_alias', 'label_pairs_stream', 'label_pairs_id'],
      converter='last',
    ),
  ),

  replication_lag(
    cfg,
    title='Tarantool replication lag',
    description=|||
      Replication lag value for Tarantool instance.

      Panel works with `metrics >= 0.13.0`.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='s',
    decimals=null,
    decimalsY1=null,
    legend_avg=false,
    min=0,
    panel_width=8,
  ).addTarget(
    common.target(
      cfg,
      'tnt_replication_lag',
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} ({{id}})',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias ($tag_label_pairs_id)',
      },
      group_tags=['label_pairs_alias', 'label_pairs_id'],
    ),
  ),

  clock_delta(
    cfg,
    title='Instances clock delta',
    description=|||
      Clock drift across the cluster.
      max shows difference with the fastest clock (always positive),
      min shows difference with the slowest clock (always negative).

      Panel works with `metrics >= 0.10.0`.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='s',
    decimals=null,
    decimalsY1=null,
    fill=1,
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(
    common.target(
      cfg,
      'tnt_clock_delta',
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} ({{delta}})',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias ($tag_label_pairs_delta)',
      },
      group_tags=['label_pairs_alias', 'label_pairs_delta'],
      converter='last',
    ),
  ),

  local syncro_warning(description) = std.join(
    '\n',
    [description, |||
      Panel works with metrics 0.15.0 or newer, Tarantool 2.8.1 or newer.
    |||]
  ),

  synchro_queue_owner(
    cfg,
    title='Synchronous queue owner',
    description=syncro_warning(|||
      Instance ID of the current synchronous replication master.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='owner id',
    decimals=0,
    panel_width=6,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    common.target(cfg, 'tnt_synchro_queue_owner')
  ),

  synchro_queue_term(
    cfg,
    title='Synchronous queue term',
    description=syncro_warning(|||
      Current queue term.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='term',
    decimals=0,
    panel_width=6,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    common.target(cfg, 'tnt_synchro_queue_term')
  ),

  synchro_queue_length(
    cfg,
    title='Synchronous queue transactions',
    description=syncro_warning(|||
      Count of transactions collecting confirmations now.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='current',
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_synchro_queue_len')
  ),

  synchro_queue_busy(
    cfg,
    title='Synchronous queue busy',
    description=syncro_warning(|||
      Whether the queue is processing any system entry (CONFIRM/ROLLBACK/PROMOTE/DEMOTE).

      Panel works with Grafana 8.x.
    |||),
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=cfg.datasource,
    panel_width=6,
    max=1,
    min=0,
  ).addValueMapping(
    1, 'yellow', 'busy'
  ).addValueMapping(
    0, 'green', 'not busy'
  ).addRangeMapping(
    0.001, 0.999, '-'
  ).addTarget(
    common.target(cfg, 'tnt_synchro_queue_busy')
  ),
}
