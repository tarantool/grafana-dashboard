local grafana = import 'grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
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
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='Bps',
    labelY1=labelY1,
    fill=0,
    decimals=2,
    decimalsY1=0,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[%s])',
                        [metric_name, job, rate_time_range]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

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
    description=description,
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
    description=description,
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
  ):: graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='none',
    labelY1='requests per second',
    fill=0,
    decimals=2,
    decimalsY1=0,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(tnt_net_requests_total{job=~"%s"}[%s])', [job, rate_time_range]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', 'tnt_net_requests_total')
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  net_pending(
    title='Network requests pending',
    description=|||
      Number of pending network requests.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='none',
    labelY1='pending',
    fill=0,
    decimals=2,
    decimalsY1=0,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('tnt_net_requests_current{job=~"%s"}', [job]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', 'tnt_net_requests_current')
      .selectField('value').addConverter('mean')
  ),

  current_connections(
    title='Binary protocol connections',
    description=|||
      Number of current active network connections.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='none',
    labelY1='current',
    fill=0,
    decimals=0,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('tnt_net_connections_current{job=~"%s"}', [job]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', 'tnt_net_connections_current')
      .selectField('value').addConverter('last')
  ),
}
