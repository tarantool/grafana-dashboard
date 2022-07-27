local grafana = import 'grafonnet/grafana.libsonnet';

local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  default_graph(
    title=null,
    description=null,
    datasource=null,
    format='none',
    min=null,
    max=null,
    labelY1=null,
    fill=0,
    decimals=3,
    decimalsY1=0,
    legend_avg=true,
    legend_max=true,
    legend_rightSide=false,
    panel_height=8,
    panel_width=8,
  ):: grafana.graphPanel.new(
    title=title,
    description=description,
    datasource=datasource,

    format=format,
    min=min,
    max=max,
    labelY1=labelY1,
    fill=fill,
    decimals=decimals,
    decimalsY1=decimalsY1,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=legend_avg,
    legend_current=true,
    legend_max=legend_max,
    legend_rightSide=legend_rightSide,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ) { gridPos: { w: panel_width, h: panel_height } },

  row(title):: grafana.row.new(title, collapse=true) { gridPos: { w: 24, h: 1 } },

  default_metric_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    converter='mean'
  )::
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter(converter),

  default_rps_target(
    datasource_type,
    metric_name,
    job=null,
    rate_time_range=null,
    policy=null,
    measurement=null,
  )::
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[%s])',
                        [metric_name, job, rate_time_range]),
        legendFormat='{{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),

  rate_warning(
    description,
    datasource_type=variable.datasource_type.prometheus,
  )::
    if datasource_type == variable.datasource_type.prometheus then
      std.join('\n\n', [description, "If `No data` displayed, check up your 'rate_time_range' variable."])
    else
      description,

  group_by_fill_0_warning(
    description,
    datasource_type=variable.datasource_type.influxdb,
  )::
    if datasource_type == variable.datasource_type.influxdb then
      std.join('\n', [description, |||
        Current value may be 0 from time to time due to fill(0)
        and GROUP BY including partial intervals.
        Refer to https://github.com/influxdata/influxdb/issues/8244
        for updates.
      |||])
    else
      description,
}
