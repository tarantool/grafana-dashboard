local grafana = import 'grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  local memory_panel(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    metric_name,
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='bytes',
    labelY1='in bytes',
    fill=0,
    decimals=2,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=true,
    legend_current=true,
    legend_max=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name).selectField('value').addConverter('mean')
  ),

  lua_memory(
    title='Lua runtime',
    description=|||
      Memory used for the Lua runtime. Lua memory is bounded by 2 GB per instance. 
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: memory_panel(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_info_memory_lua',
  ),
}
