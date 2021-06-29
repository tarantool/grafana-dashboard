local common = import 'common.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';

{
  row:: grafana.row.new(title='Tarantool CPU statistics'),

  local getrusage_cpu_time_graph(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    rate_time_range,
    metric_name,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='s',
    labelY1='time per minute',
    decimalsY1=3,
    min=0,
  ).addTarget(common.default_rps_target(
    datasource,
    metric_name,
    job,
    rate_time_range,
    policy,
    measurement
  )),

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
