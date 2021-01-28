local grafana = import 'grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  local rps_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    rate_time_range,
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
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",status=~"%s"}[%s])',
                        [metric_name, job, std.strReplace(status_regex, '\\', '\\\\'), rate_time_range]),
        legendFormat='{{alias}} — {{method}} {{path}} (code {{status}})',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
      ).where('metric_name', '=', metric_name).where('label_pairs_status', '=~', std.format('/%s/', status_regex))
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
    job=null,
    rate_time_range=null,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name=metric_name,
    status_regex='^2\\d{2}$',
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
    job=null,
    rate_time_range=null,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name=metric_name,
    status_regex='^4\\d{2}$',
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
    job=null,
    rate_time_range=null,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name=metric_name,
    status_regex='^5\\d{2}$',
  ),

  local latency_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    metric_name,
    quantile,
    label,
    status_regex,
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='s',
    labelY1=label,
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
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s",quantile="%s",status=~"%s"}', [metric_name, job, quantile, std.strReplace(status_regex, '\\', '\\\\')]),
        legendFormat='{{alias}} — {{method}} {{path}} (code {{status}})',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
      ).where('metric_name', '=', metric_name).where('label_pairs_quantile', '=', quantile)
      .where('label_pairs_status', '=~', std.format('/%s/', status_regex)).selectField('value').addConverter('mean')
  ),

  latency_success(
    title='Success requests latency (code 2xx)',
    description=|||
      99th percentile of requests latency. Includes only requests processed with success (code 2xx) on Tarantool's side.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
  ):: latency_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^2\\d{2}$',
  ),

  latency_error_4xx(
    title='Error requests latency (code 4xx)',
    description=|||
      99th percentile of requests latency. Includes only requests processed with 4xx error on Tarantool's side.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
  ):: latency_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^4\\d{2}$',
  ),

  latency_error_5xx(
    title='Error requests latency (code 5xx)',
    description=|||
      99th percentile of requests latency. Includes only requests processed with 5xx error on Tarantool's side.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
  ):: latency_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^5\\d{2}$',
  ),
}
