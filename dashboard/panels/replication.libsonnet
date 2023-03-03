local grafana = import 'grafonnet/grafana.libsonnet';

local timeseries = import 'dashboard/grafana/timeseries.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Replication overview'),

  replication_status(
    title='Tarantool replication status',
    description=|||
      `follows` status means replication is running.
      Otherwise, `not running` is displayed.

      Panel works with `metrics >= 0.13.0` and Grafana 8.x.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=datasource,
    panel_width=8,
    max=1,
    min=0,
  ).addValueMapping(
    1, 'green', 'follows'
  ).addValueMapping(
    0, 'red', 'not running'
  ).addRangeMapping(
    0.001, 0.999, '-'
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_replication_status{job=~"%s",alias=~"%s"}', [job, alias]),
        legendFormat='{{alias}} {{stream}} ({{id}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_stream', 'label_pairs_id'],
        alias='$tag_label_pairs_alias $tag_label_pairs_stream ($tag_label_pairs_id)',
        fill='null',
      ).where('metric_name', '=', 'tnt_replication_status').where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('last')
  ),

  replication_lag(
    title='Tarantool replication lag',
    description=|||
      Replication lag value for Tarantool instance.

      Panel works with `metrics >= 0.13.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    decimals=null,
    decimalsY1=null,
    legend_avg=false,
    min=0,
    panel_width=8,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_replication_lag{job=~"%s",alias=~"%s"}', [job, alias]),
        legendFormat='{{alias}} ({{id}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_id'],
        alias='$tag_label_pairs_alias ($tag_label_pairs_id)',
        fill='null',
      ).where('metric_name', '=', 'tnt_replication_lag').where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('mean')
  ),

  clock_delta(
    title='Instances clock delta',
    description=|||
      Clock drift across the cluster.
      max shows difference with the fastest clock (always positive),
      min shows difference with the slowest clock (always negative).

      Panel works with `metrics >= 0.10.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    decimals=null,
    decimalsY1=null,
    fill=1,
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_clock_delta{job=~"%s",alias=~"%s"}', [job, alias]),
        legendFormat='{{alias}} ({{delta}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_delta'],
        alias='$tag_label_pairs_alias ($tag_label_pairs_delta)',
        fill='null',
      ).where('metric_name', '=', 'tnt_clock_delta').where('label_pairs_alias', '=~', alias)
      .selectField('value').addConverter('last')
  ),
}
