local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';
local utils = import 'dashboard/utils.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool CPU statistics'),

  local getrusage_cpu_percentage_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    labels,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='percentunit',
    decimalsY1=0,
    min=0,
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
    labels
  )),

  getrusage_cpu_user_time(
    title='CPU user time',
    description=|||
      This is the average share of time
      spent by instance process executing in user mode.
      Metrics obtained using `getrusage()` call.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: getrusage_cpu_percentage_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_cpu_user_time',
    labels=labels,
  ),

  getrusage_cpu_system_time(
    title='CPU system time',
    description=|||
      This is the average share of time
      spent by instance process executing in kernel mode.
      Metrics obtained using `getrusage()` call.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: getrusage_cpu_percentage_graph(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_cpu_system_time',
    labels=labels,
  ),

  local procstat_thread_time_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    kind,
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='ticks per second',
    min=0,
    decimalsY1=3,
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tnt_cpu_thread{job=~"%s",alias=~"%s",kind="%s",%s}[$__rate_interval])',
                        [job, alias, kind, utils.generate_labels_string(labels)]),
        legendFormat='{{alias}} — {{thread_name}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_thread_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_thread_name',
      ).where('metric_name', '=', 'tnt_cpu_thread').where('label_pairs_alias', '=~', alias)
      .where('label_pairs_kind', '=', kind)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  procstat_thread_user_time(
    title='Thread user time',
    description=|||
      Amount of time that each process has been scheduled
      in user mode, measured in clock ticks (divide by
      sysconf(_SC_CLK_TCK)).  This includes guest time,
      guest_time (time spent running a virtual CPU, see
      below), so that applications that are not aware of
      the guest time field do not lose that time from
      their calculations. Average ticks per second is displayed.

      Metrics are obtained by parsing `/proc/self/task/[pid]/stat`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null
  ):: procstat_thread_time_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    'user',
    labels,
  ),

  procstat_thread_system_time(
    title='Thread system time',
    description=|||
      Amount of time that this process has been scheduled
      in kernel mode, measured in clock ticks (divide by
      sysconf(_SC_CLK_TCK)). Average ticks per second is displayed.

      Metrics are obtained by parsing `/proc/self/task/[pid]/stat`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: procstat_thread_time_graph(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    'system',
    labels
  ),
}
