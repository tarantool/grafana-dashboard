local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool HTTP statistics'),

  local rps_graph(
    cfg,
    title,
    description,
    metric_name,
    status_regex,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='requests per second',
  ).addTarget(
    common.target(
      cfg,
      metric_name,
      additional_filters={
        [variable.datasource_type.prometheus]: { status: ['=~', std.strReplace(status_regex, '\\', '\\\\')] },
        [variable.datasource_type.influxdb]: { label_pairs_status: ['=~', std.format('/%s/', status_regex)] },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} — {{method}} {{path}} (code {{status}})',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
      },
      group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
      rate=true,
    ),
  ),

  rps_success(
    cfg,
    title='Success requests (code 2xx)',
    description=|||
      Requests, processed with success (code 2xx) on Tarantool's side.
      Graph shows mean count per second.
    |||,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    cfg,
    title=title,
    description=description,
    metric_name=metric_name,
    status_regex='^2\\d{2}$',
  ),

  rps_error_4xx(
    cfg,
    title='Error requests (code 4xx)',
    description=|||
      Requests, processed with 4xx error on Tarantool's side.
      Graph shows mean count per second.
    |||,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    cfg,
    title=title,
    description=description,
    metric_name=metric_name,
    status_regex='^4\\d{2}$',
  ),

  rps_error_5xx(
    cfg,
    title='Error requests (code 5xx)',
    description=|||
      Requests, processed with 5xx error on Tarantool's side.
      Graph shows mean count per second.
    |||,
    metric_name='http_server_request_latency_count',
  ):: rps_graph(
    cfg,
    title=title,
    description=description,
    metric_name=metric_name,
    status_regex='^5\\d{2}$',
  ),

  local latency_graph(
    cfg,
    title,
    description,
    metric_name,
    quantile,
    label,
    status_regex,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='s',
    labelY1=label,
    decimalsY1=null,
  ).addTarget(
    common.target(
      cfg,
      metric_name,
      additional_filters={
        [variable.datasource_type.prometheus]: {
          status: ['=~', std.strReplace(status_regex, '\\', '\\\\')],
          quantile: ['=', '0.99'],
        },
        [variable.datasource_type.influxdb]: {
          label_pairs_status: ['=~', std.format('/%s/', status_regex)],
          label_pairs_quantile: ['=', '0.99'],
        },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} — {{method}} {{path}} (code {{status}})',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias — $tag_label_pairs_method $tag_label_pairs_path (code $tag_label_pairs_status)',
      },
      group_tags=['label_pairs_alias', 'label_pairs_path', 'label_pairs_method', 'label_pairs_status'],
    ),
  ),

  latency_success(
    cfg,
    title='Success requests latency (code 2xx)',
    description=|||
      99th percentile of requests latency.
      Includes only requests processed with success
      (code 2xx) on Tarantool's side.
    |||,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
  ):: latency_graph(
    cfg,
    title=title,
    description=description,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^2\\d{2}$',
  ),

  latency_error_4xx(
    cfg,
    title='Error requests latency (code 4xx)',
    description=|||
      99th percentile of requests latency.
      Includes only requests processed with
      4xx error on Tarantool's side.
    |||,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
  ):: latency_graph(
    cfg,
    title=title,
    description=description,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^4\\d{2}$',
  ),

  latency_error_5xx(
    cfg,
    title='Error requests latency (code 5xx)',
    description=|||
      99th percentile of requests latency.
      Includes only requests processed with
      5xx error on Tarantool's side.
    |||,
    metric_name='http_server_request_latency',
    quantile='0.99',
    label='99th percentile',
  ):: latency_graph(
    cfg,
    title=title,
    description=description,
    metric_name=metric_name,
    quantile=quantile,
    label=label,
    status_regex='^5\\d{2}$',
  ),
}
