local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG IProto requests'),

  local rps_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    method_tail,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
    panel_width=6,
  ) = common_utils.default_graph(
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
    datasource=datasource,
    labelY1='request per second',
    panel_width=panel_width,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s",method="repository.%s"}[$__rate_interval])',
                        [metric_name, job, alias, method_tail]),
        legendFormat='{{type}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
        ],
        alias='$tag_label_pairs_type — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_method', '=', std.format('repository.%s', method_tail))
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local latency_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    method_tail,
    job=null,
    policy=null,
    measurement=null,
    alias=null,
    panel_width=6,
  ) = common_utils.default_graph(
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
    datasource=datasource,
    labelY1='99th percentile',
    format='µs',
    panel_width=panel_width,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",method="repository.%s",quantile="0.99"}',
                        [metric_name, job, alias, method_tail]),
        legendFormat='{{type}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
        ],
        alias='$tag_label_pairs_type — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_method', '=', std.format('repository.%s', method_tail))
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('mean'),
  ),

  put_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='put',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  put_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='put',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  put_batch_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='put_batch',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  put_batch_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='put_batch',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  find_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='find',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
    panel_width=12,
  ),

  find_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='find',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
    panel_width=12,
  ),

  update_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='update',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  update_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='update',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  get_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='get',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  get_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='get',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  delete_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='delete',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  delete_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='delete',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  count_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='count',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  count_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='count',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  map_reduce_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='map_reduce',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  map_reduce_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='map_reduce',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  call_on_storage_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='call_on_storage',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),

  call_on_storage_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='call_on_storage',
    job=job,
    policy=policy,
    measurement=measurement,
    alias=alias,
  ),
}
