local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG IProto requests'),

  local rps_panel(
    cfg,
    title,
    description,
    metric_name,
    method_tail,
    panel_width=6,
  ) = common_utils.default_graph(
    cfg,
    title=
    if title != null then
      title
    else
      std.format('%s requests', method_tail),
    description=
    if description != null then
      description
    else
      std.format(|||
        Number of repository.%s method calls through IProto.
        Graph shows mean requests per second.
      |||, method_tail),
    labelY1='request per second',
    panel_width=panel_width,
  ).addTarget(
    common_utils.target(
      cfg,
      metric_name,
      additional_filters={
        [variable.datasource_type.prometheus]: { method: ['=', 'repository.' + method_tail] },
        [variable.datasource_type.influxdb]: { label_pairs_method: ['=', 'repository.' + method_tail] },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{type}} — {{alias}}',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_type — $tag_label_pairs_alias',
      },
      group_tags=[
        'label_pairs_alias',
        'label_pairs_type',
      ],
      rate=true,
    ),
  ),

  local latency_panel(
    cfg,
    title,
    description,
    metric_name,
    method_tail,
    panel_width=6,
  ) = common_utils.default_graph(
    cfg,
    title=
    if title != null then
      title
    else
      std.format('%s request latency', method_tail),
    description=
    if description != null then
      description
    else
      std.format(|||
        99th percentile of repository.%s IProto call execution time.
      |||, method_tail),
    labelY1='99th percentile',
    format='ms',
    panel_width=panel_width,
  ).addTarget(
    common_utils.target(
      cfg,
      metric_name,
      additional_filters={
        [variable.datasource_type.prometheus]: {
          method: ['=', 'repository.' + method_tail],
          quantile: ['=', '0.99'],
        },
        [variable.datasource_type.influxdb]: {
          label_pairs_method: ['=', 'repository.' + method_tail],
          label_pairs_quantile: ['=', '0.99'],
        },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{type}} — {{alias}}',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_type — $tag_label_pairs_alias',
      },
      group_tags=[
        'label_pairs_alias',
        'label_pairs_type',
      ],
    ),
  ),

  put_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='put',
  ),

  put_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='put',
  ),

  put_batch_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='put_batch',
  ),

  put_batch_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='put_batch',
  ),

  find_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='find',
    panel_width=12,
  ),

  find_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='find',
    panel_width=12,
  ),

  update_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='update',
  ),

  update_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='update',
  ),

  get_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='get',
  ),

  get_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='get',
  ),

  delete_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='delete',
  ),

  delete_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='delete',
  ),

  count_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='count',
  ),

  count_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='count',
  ),

  map_reduce_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='map_reduce',
  ),

  map_reduce_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='map_reduce',
  ),

  call_on_storage_rps(
    cfg,
    title=null,
    description=null,
  ):: rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='call_on_storage',
  ),

  call_on_storage_latency(
    cfg,
    title=null,
    description=null,
  ):: latency_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='call_on_storage',
  ),
}
