local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG REST API requests'),

  local rps_panel(
    cfg,
    title,
    description,
    metric_name,
    status_regex,
    get_condition,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='request per second',
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s",method%s"GET",status_code=~"%s"}[$__rate_interval])', [
          metric_name,
          cfg.filters.job[1],
          cfg.filters.alias[1],
          get_condition,
          std.strReplace(status_regex, '\\', '\\\\'),
        ]),
        legendFormat='{{type}} (code {{status_code}}) — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
          'label_pairs_status_code',
          'label_pairs_method',
        ],
        alias='$tag_label_pairs_method $tag_label_pairs_type (code $tag_label_pairs_status_code) — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias[1])
      .where('label_pairs_method', get_condition, 'GET')
      .where('label_pairs_status_code', '=~', std.format('/%s/', status_regex))
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local latency_panel(
    cfg,
    title,
    description,
    metric_name,
    status_regex,
    get_condition,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='99th percentile',
    format='ms',
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",method%s"GET",status_code=~"%s",quantile="0.99"}', [
          metric_name,
          cfg.filters.job[1],
          cfg.filters.alias[1],
          get_condition,
          std.strReplace(status_regex, '\\', '\\\\'),
        ]),
        legendFormat='{{type}} (code {{status_code}}) — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
          'label_pairs_status_code',
          'label_pairs_method',
        ],
        alias='$tag_label_pairs_method $tag_label_pairs_type (code $tag_label_pairs_status_code) — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias[1])
      .where('label_pairs_method', get_condition, 'GET')
      .where('label_pairs_status_code', '=~', std.format('/%s/', status_regex))
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('mean'),
  ),

  read_success_rps(
    cfg,
    title='Success read requests',
    description=|||
      Number of TDG REST API GET requests processed with code 2xx.
      Graph shows mean requests per second.
    |||,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^2\\d{2}$',
    get_condition='=',
  ),

  read_error_4xx_rps(
    cfg,
    title='Error read requests (code 4xx)',
    description=|||
      Number of TDG REST API GET requests processed with code 4xx.
      Graph shows mean requests per second.
    |||,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^4\\d{2}$',
    get_condition='=',
  ),

  read_error_5xx_rps(
    cfg,
    title='Error read requests (code 5xx)',
    description=|||
      Number of TDG REST API GET requests processed with code 5xx.
      Graph shows mean requests per second.
    |||,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^5\\d{2}$',
    get_condition='=',
  ),

  read_success_latency(
    cfg,
    title='Success read request latency',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only GET requests processed with code 2xx are displayed.
    |||,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time',
    status_regex='^2\\d{2}$',
    get_condition='=',
  ),

  read_error_4xx_latency(
    cfg,
    title='Error read request latency (code 4xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only GET requests processed with code 4xx are displayed.
    |||,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time',
    status_regex='^4\\d{2}$',
    get_condition='=',
  ),

  read_error_5xx_latency(
    cfg,
    title='Error read request latency (code 5xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only GET requests processed with code 5xx are displayed.
    |||,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time',
    status_regex='^5\\d{2}$',
    get_condition='=',
  ),

  write_success_rps(
    cfg,
    title='Success write requests',
    description=|||
      Number of TDG REST API POST/PUT/DELETE requests
      processed with code 2xx.
      Graph shows mean requests per second.
    |||,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^2\\d{2}$',
    get_condition='!=',
  ),

  write_error_4xx_rps(
    cfg,
    title='Error write requests (code 4xx)',
    description=|||
      Number of TDG REST API POST/PUT/DELETE requests
      processed with code 4xx.
      Graph shows mean requests per second.
    |||,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^4\\d{2}$',
    get_condition='!=',
  ),

  write_error_5xx_rps(
    cfg,
    title='Error write requests (code 5xx)',
    description=|||
      Number of TDG REST API POST/PUT/DELETE requests
      processed with code 5xx.
      Graph shows mean requests per second.
    |||,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time_count',
    status_regex='^5\\d{2}$',
    get_condition='!=',
  ),

  write_success_latency(
    cfg,
    title='Success write request latency',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only POST/PUT/DELETE requests processed with code 2xx
      are displayed.
    |||,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time',
    status_regex='^2\\d{2}$',
    get_condition='!=',
  ),

  write_error_4xx_latency(
    cfg,
    title='Error write request latency (code 4xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only POST/PUT/DELETE requests processed with code 4xx
      are displayed.
    |||,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time',
    status_regex='^4\\d{2}$',
    get_condition='!=',
  ),

  write_error_5xx_latency(
    cfg,
    title='Error read request latency (code 5xx)',
    description=|||
      99th percentile of TDG REST API request execution time.
      Only POST/PUT/DELETE requests processed with code 5xx
      are displayed.
    |||,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_rest_exec_time',
    status_regex='^5\\d{2}$',
    get_condition='!=',
  ),
}
