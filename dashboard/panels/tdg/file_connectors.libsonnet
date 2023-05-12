local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG file connector statistics'),

  local target(
    cfg,
    metric_name,
  ) =
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.filters.job, cfg.filters.alias]),
        legendFormat='{{connector_name}} — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_connector_name',
        ],
        alias='$tag_label_pairs_connector_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),

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
