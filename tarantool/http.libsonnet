local grafana = import 'grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;

{
  local rps_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
    status_regex,
  ) = graph.new(
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
    influxdb.target(
      policy=policy,
      measurement=measurement,
      group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
      alias='$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
    ).where('metric_name', '=', metric_name).where('label_pairs_status', '=~', status_regex)
    .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  rps_success(
    title='Success requests (code 2xx)',
    description=|||
      Requests, processed with success (code 2xx) on Tarantool's side.
      Graph shows mean count per second.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name=metric_name,
    status_regex='/^2\\d{2}$/',
  ),

  rps_error_4xx(
    title='Error requests (code 4xx)',
    description=|||
      Requests, processed with 4xx error on Tarantool's side.
      Graph shows mean count per second.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name=metric_name,
    status_regex='/^4\\d{2}$/',
  ),

  rps_error_5xx(
    title='Error requests (code 5xx)',
    description=|||
      Requests, processed with 5xx error on Tarantool's side.
      Graph shows mean count per second.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name=metric_name,
    status_regex='/^5\\d{2}$/',
  ),

  local latency_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
    status_regex,
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='s',
    labelY1='average',
    fill=0,
    decimals=3,
    decimalsY1=2,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    influxdb.target(
      policy=policy,
      measurement=measurement,
      group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
      alias='$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
    ).where('metric_name', '=', metric_name).where('label_pairs_status', '=~', status_regex)
    .selectField('value').addConverter('mean')
  ),

  latency_success(
    title='Success requests latency (code 2xx)',
    description=|||
      Latency of requests, processed with success (code 2xx) on Tarantool's side.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    metric_name='http_server_request_latency_avg',
  ):: latency_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name=metric_name,
    status_regex='/^2\\d{2}$/',
  ),

  latency_error_4xx(
    title='Error requests latency (code 4xx)',
    description=|||
      Latency of requests, processed with 4xx error on Tarantool's side.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    metric_name='http_server_request_latency_avg',
  ):: latency_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name=metric_name,
    status_regex='/^4\\d{2}$/',
  ),

  latency_error_5xx(
    title='Error requests latency (code 5xx)',
    description=|||
      Latency of requests, processed with 5xx error on Tarantool's side.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    metric_name='http_server_request_latency_avg',
  ):: latency_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name=metric_name,
    status_regex='/^5\\d{2}$/',
  ),
}
