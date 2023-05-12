local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool network activity'),

  net_memory(
    cfg,
    title='Net memory',
    description=|||
      Memory used for network input/output buffers.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.default_metric_target(cfg, 'tnt_info_memory_net')
  ),

  local bytes_per_second_graph(
    cfg,
    title,
    description,
    metric_name,
    labelY1,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='Bps',
    labelY1=labelY1,
    panel_width=8,
  ).addTarget(
    common.default_rps_target(cfg, metric_name)
  ),

  bytes_received_per_second(
    cfg,
    title='Data received',
    description=|||
      Data received by instance from binary protocol connections.
      Graph shows average bytes per second.
    |||,
  ):: bytes_per_second_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_received_total',
    labelY1='received'
  ),

  bytes_sent_per_second(
    cfg,
    title='Data sent',
    description=|||
      Data sent by instance with binary protocol connections.
      Graph shows average bytes per second.
    |||,
  ):: bytes_per_second_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_sent_total',
    labelY1='sent'
  ),

  net_rps(
    cfg,
    title='Network requests handled',
    description=|||
      Number of network requests this instance has handled.
      Graph shows mean rps.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(
    common.default_rps_target(cfg, 'tnt_net_requests_total')
  ),

  net_pending(
    cfg,
    title='Network requests pending',
    description=|||
      Number of pending network requests.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    labelY1='pending',
    min=0,
    panel_width=12,
  ).addTarget(
    common.default_metric_target(cfg, 'tnt_net_requests_current')
  ),

  requests_in_progress_per_second(
    cfg,
    title='Processed requests',
    description=|||
      Average number of requests processed by tx thread per second.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    panel_width=6,
  ).addTarget(
    common.default_rps_target(cfg, 'tnt_net_requests_in_progress_total')
  ),

  requests_in_progress_current(
    cfg,
    title='Requests in progress',
    description=|||
      Number of requests currently being processed in the tx thread.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    labelY1='current',
    panel_width=6,
  ).addTarget(
    common.default_metric_target(cfg, 'tnt_net_requests_in_progress_current', 'last')
  ),

  requests_in_queue_per_second(
    cfg,
    title='Requests in queue (overall)',
    description=|||
      Average number of requests which was placed in queues
      of streams per second.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
    panel_width=6,
  ).addTarget(
    common.default_rps_target(cfg, 'tnt_net_requests_in_stream_queue_total')
  ),

  requests_in_queue_current(
    cfg,
    title='Requests in queue (current)',
    description=|||
      Number of requests currently waiting in queues of streams.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    labelY1='current',
    panel_width=6,
  ).addTarget(
    common.default_metric_target(cfg, 'tnt_net_requests_in_stream_queue_current', 'last')
  ),

  connections_per_second(
    cfg,
    title='New binary connections',
    description=|||
      Average number of new binary protocol connections per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='new per second',
    panel_width=12,
  ).addTarget(
    common.default_rps_target(cfg, 'tnt_net_connections_total')
  ),

  current_connections(
    cfg,
    title='Current binary connections',
    description=|||
      Number of current active binary protocol connections.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    labelY1='current',
    panel_width=12,
  ).addTarget(
    common.default_metric_target(cfg, 'tnt_net_connections_current', 'last')
  ),

  local per_thread_warning(description) = std.join(
    '\n',
    [description, |||
      Panel works with metrics 0.15.0 or newer, Tarantool 2.10 or newer.
    |||]
  ),

  local per_thread_rate_graph(
    cfg,
    title,
    description,
    metric_name,
    format,
    labelY1,
    panel_width,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format=format,
    labelY1=labelY1,
    panel_width=panel_width,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{alias}} (thread {{thread}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=['label_pairs_alias', 'label_pairs_thread'],
        alias='$tag_label_pairs_alias (thread $tag_label_pairs_thread)',
        fill='null',
      ).where('metric_name', '=', metric_name).where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local per_thread_current_graph(
    cfg,
    title,
    description,
    metric_name,
    format,
    labelY1,
    panel_width,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format=format,
    labelY1=labelY1,
    decimals=0,
    panel_width=panel_width,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}',
                        [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{alias}} (thread {{thread}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=['label_pairs_alias', 'label_pairs_thread'],
        alias='$tag_label_pairs_alias (thread $tag_label_pairs_thread)',
        fill='null',
      ).where('metric_name', '=', metric_name).where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('last'),
  ),

  bytes_sent_per_thread_per_second(
    cfg,
    title='Data sent (per thread)',
    description=per_thread_warning(|||
      Data sent by instance with binary protocol connections,
      separated per thread.
      Graph shows average bytes per second.
    |||),
  ):: per_thread_rate_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_sent_total',
    format='Bps',
    labelY1='sent',
    panel_width=12,
  ),

  bytes_received_per_thread_per_second(
    cfg,
    title='Data received (per thread)',
    description=per_thread_warning(|||
      Data received by instance from binary protocol connections,
      separated per thread.
      Graph shows average bytes per second.
    |||),
  ):: per_thread_rate_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_received_total',
    format='Bps',
    labelY1='received',
    panel_width=12,
  ),

  connections_per_thread_per_second(
    cfg,
    title='New binary connections (per thread)',
    description=per_thread_warning(|||
      Average number of new binary protocol connections per second,
      separated per thread.
    |||),
  ):: per_thread_rate_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_connections_total',
    format='none',
    labelY1='new per second',
    panel_width=12,
  ),

  current_connections_per_thread(
    cfg,
    title='Current binary connections (per thread)',
    description=per_thread_warning(|||
      Number of current active binary protocol connections,
      separated per thread.
    |||),
  ):: per_thread_current_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_connections_current',
    format='none',
    labelY1='current',
    panel_width=12,
  ),

  net_rps_per_thread(
    cfg,
    title='Network requests handled (per thread)',
    description=per_thread_warning(|||
      Number of network requests this instance has handled,
      separated per thread.
      Graph shows mean rps.
    |||),
  ):: per_thread_rate_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_requests_total',
    format='none',
    labelY1='requests per second',
    panel_width=8,
  ),

  requests_in_progress_per_thread_per_second(
    cfg,
    title='Processed requests (per thread)',
    description=per_thread_warning(|||
      Average number of requests processed per second,
      separated per thread.
    |||),
  ):: per_thread_rate_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_requests_in_progress_total',
    format='none',
    labelY1='requests per second',
    panel_width=8,
  ),

  requests_in_queue_per_thread_per_second(
    cfg,
    title='Requests in queue (overall per thread)',
    description=per_thread_warning(|||
      Average number of requests which was placed in queues
      of streams per second, separated per thread.
    |||),
  ):: per_thread_rate_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_requests_in_stream_queue_total',
    format='none',
    labelY1='requests per second',
    panel_width=8,
  ),

  net_pending_per_thread(
    cfg,
    title='Network requests pending (per thread)',
    description=per_thread_warning(|||
      Number of pending network requests,
      separated per thread.
    |||),
  ):: per_thread_current_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_requests_current',
    format='none',
    labelY1='pending',
    panel_width=8,
  ),

  requests_in_progress_current_per_thread(
    cfg,
    title='Requests in progress (per thread)',
    description=per_thread_warning(|||
      Number of requests currently being processed,
      separated per thread.
    |||),
  ):: per_thread_current_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_requests_in_progress_current',
    format='none',
    labelY1='pending',
    panel_width=8,
  ),

  requests_in_queue_current_per_thread(
    cfg,
    title='Requests in queue (current per thread)',
    description=per_thread_warning(|||
      Number of requests currently waiting in queues of streams,
      separated per thread.
    |||),
  ):: per_thread_current_graph(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_net_per_thread_requests_in_stream_queue_current',
    format='none',
    labelY1='pending',
    panel_width=8,
  ),
}
