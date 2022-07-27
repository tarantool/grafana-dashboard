local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import '../common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG file connector statistics'),

  local target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) =
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{connector_name}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_connector_name',
        ],
        alias='$tag_label_pairs_connector_name — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),

  files_processed(
    title='Total files processed',
    description=|||
      A number of files processed.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='files',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(target(
    datasource_type,
    'tdg_connector_input_file_processed_count',
    job,
    policy,
    measurement,
  )),

  objects_processed(
    title='Total objects processed',
    description=|||
      A number of objects processed over all files.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='objects per second',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(target(
    datasource_type,
    'tdg_connector_input_file_processed_objects_count',
    job,
    policy,
    measurement,
  )),

  files_process_errors(
    title='Files failed to processed',
    description=|||
      A number of files failed to process.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='files',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(target(
    datasource_type,
    'tdg_connector_input_file_failed_count',
    job,
    policy,
    measurement,
  )),

  file_size(
    title='Current file size',
    description=|||
      Current file size.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(target(
    datasource_type,
    'tdg_connector_input_file_size',
    job,
    policy,
    measurement,
  )),

  current_bytes_processed(
    title='Current file bytes processed',
    description=|||
      Processed bytes count from the current file.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(target(
    datasource_type,
    'tdg_connector_input_file_current_bytes_processed',
    job,
    policy,
    measurement,
  )),

  current_objects_processed(
    title='Current file objects processed',
    description=|||
      Processed objects count from the current file.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='objects',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(target(
    datasource_type,
    'tdg_connector_input_file_current_processed_objects',
    job,
    policy,
    measurement,
  )),
}
