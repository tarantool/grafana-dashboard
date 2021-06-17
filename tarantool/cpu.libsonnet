local grafana = import 'grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  local getrusage_cpu_time_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    rate_time_range,
    metric_name,
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='s',
    labelY1='time per minute',
    fill=0,
    decimals=3,
    decimalsY1=3,
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
        expr=std.format('rate(%s{job=~"%s"}[%s])',
                        [metric_name, job, rate_time_range]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  getrusage_cpu_user_time(
    title='CPU user time',
    description=|||
      Panel works with `metrics >= 0.8.0`.
      This is the average amount of time per minute
      spent by instance process executing in user mode.
      Metrics obtained using `getrusage()` call.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: getrusage_cpu_time_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name='tnt_cpu_user_time',
  ),

  getrusage_cpu_system_time(
    title='CPU system time',
    description=|||
      Panel works with `metrics >= 0.8.0`.
      This is the average amount of time per minute
      spent by instance process executing in kernel mode.
      Metrics obtained using `getrusage()` call.
      If `No data` displayed for Prometheus panel,
      check up your 'rate_time_range' variable.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: getrusage_cpu_time_graph(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name='tnt_cpu_system_time',
  ),
}
