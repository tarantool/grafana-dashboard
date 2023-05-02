local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';
local utils = import 'dashboard/utils.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool HTTP statistics'),

  local rps_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    status_regex,
    labels,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='requests per second',
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s",status=~"%s",%s}[$__rate_interval])',
                        [metric_name, job, alias, std.strReplace(status_regex, '\\', '\\\\'), utils.generate_labels_string(labels)]),
        legendFormat='{{alias}} — {{method}} {{path}} (code {{status}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_status', '=~', std.format('/%s/', status_regex))
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  rps_success(
    title='Success requests (code 2xx)',
    description=|||
      Requests, processed with success (code 2xx) on Tarantool's side.
      Graph shows mean count per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name='http_server_request_latency_count',
    labels=null
  ):: rps_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name=metric_name,
    status_regex='^2\\d{2}$',
    labels=labels,
  ),

  rps_error_4xx(
    title='Error requests (code 4xx)',
    description=|||
      Requests, processed with 4xx error on Tarantool's side.
      Graph shows mean count per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name='http_server_request_latency_count',
    labels=null,
  ):: rps_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name=metric_name,
    status_regex='^4\\d{2}$',
    labels=labels,
  ),

  rps_error_5xx(
    title='Error requests (code 5xx)',
    description=|||
      Requests, processed with 5xx error on Tarantool's side.
      Graph shows mean count per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name='http_server_request_latency_count',
    labels=null,
  ):: rps_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name=metric_name,
    status_regex='^5\\d{2}$',
    labels=labels,
  ),

  local latency_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    quantile,
    label,
    status_regex,
    labels=null
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    labelY1=label,
    decimalsY1=null,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",quantile="%s",status=~"%s",%s}',
                        [metric_name, job, alias, quantile, std.strReplace(status_regex, '\\', '\\\\'), utils.generate_labels_string(labels)]),
        legendFormat='{{alias}} — {{method}} {{path}} (code {{status}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_quantile', '=', quantile)
      .where('label_pairs_status', '=~', std.format('/%s/', status_regex)).selectField('value').addConverter('mean')
  ),

  latency_success(
    title='Success requests latency (code 2xx)',
    description=|||
      99th percentile of requests latency.
      Includes only requests processed with success
      (code 2xx) on Tarantool's side.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
    labels=null,
  ):: latency_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^2\\d{2}$',
    labels=labels,
  ),

  latency_error_4xx(
    title='Error requests latency (code 4xx)',
    description=|||
      99th percentile of requests latency.
      Includes only requests processed with
      4xx error on Tarantool's side.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
    labels=null,
  ):: latency_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^4\\d{2}$',
    labels=labels,
  ),

  latency_error_5xx(
    title='Error requests latency (code 5xx)',
    description=|||
      99th percentile of requests latency.
      Includes only requests processed with
      5xx error on Tarantool's side.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
    labels=null,
  ):: latency_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^5\\d{2}$',
    labels=labels
  ),
}
