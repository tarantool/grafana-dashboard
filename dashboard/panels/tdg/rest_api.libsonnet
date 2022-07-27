local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG REST API requests'),

  local rps_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    status_regex,
    get_condition,
    job=null,
    rate_time_range=null,
    policy=null,
    measurement=null,
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='request per second',
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",method%s"GET",status_code=~"%s"}[%s])', [
          metric_name,
          job,
          get_condition,
          std.strReplace(status_regex, '\\', '\\\\'),
          rate_time_range,
        ]),
        legendFormat='{{type}} (code {{status_code}}) — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
          'label_pairs_status_code',
          'label_pairs_method',
        ],
        alias='$tag_label_pairs_method $tag_label_pairs_type (code $tag_label_pairs_status_code) — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_method', get_condition, 'GET')
      .where('label_pairs_status_code', '=~', std.format('/%s/', status_regex))
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local latency_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    status_regex,
    get_condition,
    job=null,
    rate_time_range=null,
    policy=null,
    measurement=null,
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='99th percentile',
    format='µs',
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",method%s"GET",status_code=~"%s",quantile="0.99"}', [
          metric_name,
          job,
          get_condition,
          std.strReplace(status_regex, '\\', '\\\\'),
        ]),
        legendFormat='{{type}} (code {{status_code}}) — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
          'label_pairs_status_code',
          'label_pairs_method',
        ],
        alias='$tag_label_pairs_method $tag_label_pairs_type (code $tag_label_pairs_status_code) — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_method', get_condition, 'GET')
      .where('label_pairs_status_code', '=~', std.format('/%s/', status_regex))
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('mean'),
  ),

  read_success_rps(
    title='Success read requests',
    description=common_utils.rate_warning(|||
      Number of TDG REST API GET requests processed with code 2xx.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^2\\d{2}$',
    get_condition='=',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  read_error_4xx_rps(
    title='Error read requests (code 4xx)',
    description=common_utils.rate_warning(|||
      Number of TDG REST API GET requests processed with code 4xx.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^4\\d{2}$',
    get_condition='=',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  read_error_5xx_rps(
    title='Error read requests (code 5xx)',
    description=common_utils.rate_warning(|||
      Number of TDG REST API GET requests processed with code 5xx.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^5\\d{2}$',
    get_condition='=',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  read_success_latency(
    title='Success read request latency',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only GET requests processed with code 2xx are displayed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time',
    status_regex='^2\\d{2}$',
    get_condition='=',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  read_error_4xx_latency(
    title='Error read request latency (code 4xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only GET requests processed with code 4xx are displayed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time',
    status_regex='^4\\d{2}$',
    get_condition='=',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  read_error_5xx_latency(
    title='Error read request latency (code 5xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only GET requests processed with code 5xx are displayed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time',
    status_regex='^5\\d{2}$',
    get_condition='=',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  write_success_rps(
    title='Success write requests',
    description=common_utils.rate_warning(|||
      Number of TDG REST API POST/PUT/DELETE requests
      processed with code 2xx.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^2\\d{2}$',
    get_condition='!=',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  write_error_4xx_rps(
    title='Error write requests (code 4xx)',
    description=common_utils.rate_warning(|||
      Number of TDG REST API POST/PUT/DELETE requests
      processed with code 4xx.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^4\\d{2}$',
    get_condition='!=',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  write_error_5xx_rps(
    title='Error write requests (code 5xx)',
    description=common_utils.rate_warning(|||
      Number of TDG REST API POST/PUT/DELETE requests
      processed with code 5xx.
      Graph shows mean requests per second.
    |||, datasource_type),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^5\\d{2}$',
    get_condition='!=',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  write_success_latency(
    title='Success write request latency',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only POST/PUT/DELETE requests processed with code 2xx
      are displayed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time',
    status_regex='^2\\d{2}$',
    get_condition='!=',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  write_error_4xx_latency(
    title='Error write request latency (code 4xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only POST/PUT/DELETE requests processed with code 4xx
      are displayed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time',
    status_regex='^4\\d{2}$',
    get_condition='!=',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  write_error_5xx_latency(
    title='Error read request latency (code 5xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only POST/PUT/DELETE requests processed with code 5xx
      are displayed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_rest_exec_time',
    status_regex='^5\\d{2}$',
    get_condition='!=',
    job=job,
    policy=policy,
    measurement=measurement,
  ),
}
