local common_utils = import 'dashboard/panels/common.libsonnet';

{
  row:: common_utils.row('TDG file connector statistics'),

  local target(
    cfg,
    metric_name,
  ) = common_utils.target(
    cfg,
    metric_name,
    legend={
      prometheus: '{{connector_name}} — {{alias}}',
      influxdb: '$tag_label_pairs_connector_name — $tag_label_pairs_alias',
    },
    group_tags=[
      'label_pairs_alias',
      'label_pairs_connector_name',
    ],
  ),

  files_processed(
    cfg,
    title='Total files processed',
    description=|||
      A number of files processed.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='files',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    target(cfg, 'tdg_connector_input_file_processed_count')
  ),

  objects_processed(
    cfg,
    title='Total objects processed',
    description=|||
      A number of objects processed over all files.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='objects per second',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    target(cfg, 'tdg_connector_input_file_processed_objects_count')
  ),

  files_process_errors(
    cfg,
    title='Files failed to processed',
    description=|||
      A number of files failed to process.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='files',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    target(cfg, 'tdg_connector_input_file_failed_count')
  ),

  file_size(
    cfg,
    title='Current file size',
    description=|||
      Current file size.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    target(cfg, 'tdg_connector_input_file_size')
  ),

  current_bytes_processed(
    cfg,
    title='Current file bytes processed',
    description=|||
      Processed bytes count from the current file.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    target(cfg, 'tdg_connector_input_file_current_bytes_processed')
  ),

  current_objects_processed(
    cfg,
    title='Current file objects processed',
    description=|||
      Processed objects count from the current file.
    |||,
  ):: common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='objects',
    decimals=0,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    target(cfg, 'tdg_connector_input_file_current_processed_objects')
  ),
}
