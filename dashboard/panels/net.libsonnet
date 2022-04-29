local common = import 'common.libsonnet';

{
  row:: common.row('Tarantool network activity'),

  net_memory(
    title='Net memory',
    description=|||
      Memory used for network input/output buffers.
    |||,
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
    datasource,
    'tnt_info_memory_net',
    job,
    policy,
    measurement
  )),

  local bytes_per_second_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    rate_time_range,
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
    datasource,
    metric_name,
    job,
    rate_time_range,
    policy,
    measurement
  )),

  bytes_received_per_second(
    title='Data received',
    description=|||
      Data received by instance from binary protocol connections.
      Graph shows average bytes per second.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: bytes_per_second_graph(
    title=title,
    description=common.rate_warning(description, datasource),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name='tnt_net_received_total',
    labelY1='received'
  ),

  bytes_sent_per_second(
    title='Data sent',
    description=|||
      Data sent by instance with binary protocol connections.
      Graph shows average bytes per second.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: bytes_per_second_graph(
    title=title,
    description=common.rate_warning(description, datasource),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name='tnt_net_sent_total',
    labelY1='sent'
  ),

  net_rps(
    title='Network requests handled',
    description=|||
      Number of network requests this instance has handled.
      Graph shows mean rps.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common.default_graph(
    title=title,
    description=common.rate_warning(description, datasource),
    datasource=datasource,
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource,
    'tnt_net_requests_total',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  net_pending(
    title='Network requests pending',
    description=|||
      Number of pending network requests.
    |||,
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
    datasource,
    'tnt_net_requests_current',
    job,
    policy,
    measurement
  )),

  connections_per_second(
    title='New binary connections',
    description=|||
      Average number of new binary protocol connections per second.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='new per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource,
    'tnt_net_connections_total',
    job,
    rate_time_range,
    policy,
    measurement,
  )),

  current_connections(
    title='Current binary connections',
    description=|||
      Number of current active binary protocol connections.
    |||,
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
    datasource,
    'tnt_net_connections_current',
    job,
    policy,
    measurement,
    'last',
  )),
}
