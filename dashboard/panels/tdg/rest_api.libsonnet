local common_utils = import 'dashboard/panels/common.libsonnet';

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
    common_utils.target(
      cfg,
      metric_name,
      additional_filters={
        prometheus: {
          method: [get_condition, 'GET'],
          status_code: ['=~', std.strReplace(status_regex, '\\', '\\\\')],
        },
        influxdb: {
          label_pairs_method: [get_condition, 'GET'],
          label_pairs_status_code: ['=~', std.format('/%s/', status_regex)],
        },
      },
      legend={
        prometheus: '{{type}} (code {{status_code}}) — {{alias}}',
        influxdb: '$tag_label_pairs_method $tag_label_pairs_type (code $tag_label_pairs_status_code) — $tag_label_pairs_alias',
      },
      group_tags=[
        'label_pairs_alias',
        'label_pairs_type',
        'label_pairs_status_code',
        'label_pairs_method',
      ],
      rate=true,
    ),
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
    common_utils.target(
      cfg,
      metric_name,
      additional_filters={
        prometheus: {
          method: [get_condition, 'GET'],
          status_code: ['=~', std.strReplace(status_regex, '\\', '\\\\')],
          quantile: ['=', '0.99'],
        },
        influxdb: {
          label_pairs_method: [get_condition, 'GET'],
          label_pairs_status_code: ['=~', std.format('/%s/', status_regex)],
          label_pairs_quantile: ['=', '0.99'],
        },
      },
      legend={
        prometheus: '{{type}} (code {{status_code}}) — {{alias}}',
        influxdb: '$tag_label_pairs_method $tag_label_pairs_type (code $tag_label_pairs_status_code) — $tag_label_pairs_alias',
      },
      group_tags=[
        'label_pairs_alias',
        'label_pairs_type',
        'label_pairs_status_code',
        'label_pairs_method',
      ],
    ),
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
