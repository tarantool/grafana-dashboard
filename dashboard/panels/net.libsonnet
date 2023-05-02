local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';
local utils = import 'dashboard/utils.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

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
    alias=null,
    labels=null,
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
    measurement,
    alias,
    labels=labels,
  )),

  local bytes_per_second_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    labelY1,
    labels,
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
    measurement,
    alias,
    labels,
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
    alias=null,
    labels=null,
  ):: bytes_per_second_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_received_total',
    labelY1='received',
    labels=labels,
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
    alias=null,
    labels=null,
  ):: bytes_per_second_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_sent_total',
    labelY1='sent',
    labels=labels,
  ),

  net_rps(
    title='Network requests handled',
    description=|||
      Number of network requests this instance has handled.
      Graph shows mean rps.
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
    labelY1='requests per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_net_requests_total',
    job,
    policy,
    measurement,
    alias,
    labels
  )),

  net_pending(
    title='Network requests pending',
    description=|||
      Number of pending network requests.
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
    decimals=0,
    labelY1='pending',
    min=0,
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_net_requests_current',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
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
    alias=null,
    labels=null,
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
    alias,
    labels,
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
    alias=null,
    labels=null,
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
    alias,
    'last',
    labels=labels,
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
    alias=null,
    labels=null,
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
    alias,
    labels,
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
    alias=null,
    labels=null,
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
    alias,
    'last',
    labels=labels,
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
    alias=null,
    labels=null,
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
    alias,
    labels,
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
    alias=null,
    labels=null,
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
    alias,
    'last',
    labels=labels,
  )),

  local per_thread_warning(description) = std.join(
    '\n',
    [description, |||
      Panel works with metrics 0.15.0 or newer, Tarantool 2.10 or newer.
    |||]
  ),

  local per_thread_rate_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    format,
    labelY1,
    panel_width,
    labels,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format=format,
    labelY1=labelY1,
    panel_width=panel_width,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s",%s}[$__rate_interval])',
                        [metric_name, job, alias, utils.generate_labels_string(labels)]),
        legendFormat='{{alias}} (thread {{thread}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_thread'],
        alias='$tag_label_pairs_alias (thread $tag_label_pairs_thread)',
        fill='null',
      ).where('metric_name', '=', metric_name).where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local per_thread_current_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    format,
    labelY1,
    panel_width,
    labels,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format=format,
    labelY1=labelY1,
    decimals=0,
    panel_width=panel_width,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",%s}',
                        [metric_name, job, alias, utils.generate_labels_string(labels)]),
        legendFormat='{{alias}} (thread {{thread}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_thread'],
        alias='$tag_label_pairs_alias (thread $tag_label_pairs_thread)',
        fill='null',
      ).where('metric_name', '=', metric_name).where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('last'),
  ),

  bytes_sent_per_thread_per_second(
    title='Data sent (per thread)',
    description=per_thread_warning(|||
      Data sent by instance with binary protocol connections,
      separated per thread.
      Graph shows average bytes per second.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_rate_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_sent_total',
    format='Bps',
    labelY1='sent',
    panel_width=12,
    labels=labels,
  ),

  bytes_received_per_thread_per_second(
    title='Data received (per thread)',
    description=per_thread_warning(|||
      Data received by instance from binary protocol connections,
      separated per thread.
      Graph shows average bytes per second.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_rate_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_received_total',
    format='Bps',
    labelY1='received',
    panel_width=12,
    labels=labels,
  ),

  connections_per_thread_per_second(
    title='New binary connections (per thread)',
    description=per_thread_warning(|||
      Average number of new binary protocol connections per second,
      separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_rate_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_connections_total',
    format='none',
    labelY1='new per second',
    panel_width=12,
    labels=labels,
  ),

  current_connections_per_thread(
    title='Current binary connections (per thread)',
    description=per_thread_warning(|||
      Number of current active binary protocol connections,
      separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_current_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_connections_current',
    format='none',
    labelY1='current',
    panel_width=12,
    labels=labels,
  ),

  net_rps_per_thread(
    title='Network requests handled (per thread)',
    description=per_thread_warning(|||
      Number of network requests this instance has handled,
      separated per thread.
      Graph shows mean rps.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_rate_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_requests_total',
    format='none',
    labelY1='requests per second',
    panel_width=8,
    labels=labels,
  ),

  requests_in_progress_per_thread_per_second(
    title='Processed requests (per thread)',
    description=per_thread_warning(|||
      Average number of requests processed per second,
      separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_rate_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_requests_in_progress_total',
    format='none',
    labelY1='requests per second',
    panel_width=8,
    labels=labels,
  ),

  requests_in_queue_per_thread_per_second(
    title='Requests in queue (overall per thread)',
    description=per_thread_warning(|||
      Average number of requests which was placed in queues
      of streams per second, separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_rate_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_requests_in_stream_queue_total',
    format='none',
    labelY1='requests per second',
    panel_width=8,
    labels=labels,
  ),

  net_pending_per_thread(
    title='Network requests pending (per thread)',
    description=per_thread_warning(|||
      Number of pending network requests,
      separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_current_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_requests_current',
    format='none',
    labelY1='pending',
    panel_width=8,
    labels=labels,
  ),

  requests_in_progress_current_per_thread(
    title='Requests in progress (per thread)',
    description=per_thread_warning(|||
      Number of requests currently being processed,
      separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_current_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_requests_in_progress_current',
    format='none',
    labelY1='pending',
    panel_width=8,
    labels=labels,
  ),

  requests_in_queue_current_per_thread(
    title='Requests in queue (current per thread)',
    description=per_thread_warning(|||
      Number of requests currently waiting in queues of streams,
      separated per thread.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: per_thread_current_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_net_per_thread_requests_in_stream_queue_current',
    format='none',
    labelY1='pending',
    panel_width=8,
    labels=labels,
  ),
}
