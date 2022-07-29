local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

{
  row:: common.row('Tarantool network activity'),

  net_memory(
    title='Net memory',
    description=|||
      Memory used for network input/output buffers.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_info_memory_net',
    job,
    policy,
    measurement
  )),

  local bytes_per_second_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    metric_name,
    labelY1,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='Bps',
    labelY1=labelY1,
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement
  )),

  bytes_received_per_second(
    title='Data received',
    description=|||
      Data received by instance from binary protocol connections.
      Graph shows average bytes per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: bytes_per_second_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_net_received_total',
    labelY1='received'
  ),

  bytes_sent_per_second(
    title='Data sent',
    description=|||
      Data sent by instance with binary protocol connections.
      Graph shows average bytes per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: bytes_per_second_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_net_sent_total',
    labelY1='sent'
  ),

  net_rps(
    title='Network requests handled',
    description=|||
      Number of network requests this instance has handled.
      Graph shows mean rps.

      Panel will be removed in favor of "Processed requests"
      and "Requests in queue (overall)" panels.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_net_requests_total',
    job,
    policy,
    measurement
  )),

  net_pending(
    title='Network requests pending',
    description=|||
      Number of pending network requests.

      Panel will be removed in favor of "Requests in progress"
      and "Requests in queue (current)" panels.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    labelY1='pending',
    min=0,
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_net_requests_current',
    job,
    policy,
    measurement
  )),

  requests_in_progress_per_second(
    title='Processed requests',
    description=|||
      Average number of requests processed by tx thread per second.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_net_requests_in_progress_total',
    job,
    policy,
    measurement,
  )),

  requests_in_progress_current(
    title='Requests in progress',
    description=|||
      Number of requests currently being processed in the tx thread.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    labelY1='current',
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_net_requests_in_progress_current',
    job,
    policy,
    measurement,
    'last'
  )),

  requests_in_queue_per_second(
    title='Requests in queue (overall)',
    description=|||
      Average number of requests which was placed in queues
      of streams per second.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_net_requests_in_stream_queue_total',
    job,
    policy,
    measurement,
  )),

  requests_in_queue_current(
    title='Requests in queue (current)',
    description=|||
      Number of requests currently waiting in queues of streams.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.10-beta2`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    labelY1='current',
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_net_requests_in_stream_queue_current',
    job,
    policy,
    measurement,
    'last'
  )),

  connections_per_second(
    title='New binary connections',
    description=|||
      Average number of new binary protocol connections per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='new per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_net_connections_total',
    job,
    policy,
    measurement,
  )),

  current_connections(
    title='Current binary connections',
    description=|||
      Number of current active binary protocol connections.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    labelY1='current',
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_net_connections_current',
    job,
    policy,
    measurement,
    'last',
  )),
}
