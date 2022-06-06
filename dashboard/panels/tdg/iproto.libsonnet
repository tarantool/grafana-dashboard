local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import '../common.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG IProto requests'),

  local rps_panel(
    title,
    description,
    datasource,
    metric_name,
    method_tail,
    job=null,
    rate_time_range=null,
    policy=null,
    measurement=null,
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
      common_utils.rate_warning(std.format(|||
        Number of repository.%s method calls through IProto.
        Graph shows mean requests per second.
      |||, method_tail), datasource),
    datasource=datasource,
    labelY1='request per second',
    panel_width=panel_width,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",method="repository.%s"}[%s])',
                        [metric_name, job, method_tail, rate_time_range]),
        legendFormat='{{type}} — {{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
        ],
        alias='$tag_label_pairs_type — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_method', '=', std.format('repository.%s', method_tail))
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local latency_panel(
    title,
    description,
    datasource,
    metric_name,
    method_tail,
    job=null,
    policy=null,
    measurement=null,
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
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s",method="repository.%s",quantile="0.99"}',
                        [metric_name, job, method_tail]),
        legendFormat='{{type}} — {{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_type',
        ],
        alias='$tag_label_pairs_type — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_method', '=', std.format('repository.%s', method_tail))
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('mean'),
  ),

  put_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='put',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  put_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='put',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  put_batch_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='put_batch',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  put_batch_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='put_batch',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  find_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='find',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
    panel_width=12,
  ),

  find_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='find',
    job=job,
    policy=policy,
    measurement=measurement,
    panel_width=12,
  ),

  update_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='update',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  update_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='update',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  get_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='get',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  get_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='get',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  delete_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='delete',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  delete_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='delete',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  count_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='count',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  count_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='count',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  map_reduce_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='map_reduce',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  map_reduce_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='map_reduce',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  call_on_storage_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: rps_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time_count',
    method_tail='call_on_storage',
    job=job,
    rate_time_range=rate_time_range,
    policy=policy,
    measurement=measurement,
  ),

  call_on_storage_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: latency_panel(
    title=title,
    description=description,
    datasource=datasource,
    metric_name='tdg_iproto_data_query_exec_time',
    method_tail='call_on_storage',
    job=job,
    policy=policy,
    measurement=measurement,
  ),
}
