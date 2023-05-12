local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool CPU statistics'),

  local getrusage_cpu_percentage_graph(
    cfg,
    title,
    description,
    metric_name,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='percentunit',
    decimalsY1=0,
    min=0,
    panel_width=12,
  ).addTarget(common.default_rps_target(
    cfg,
    metric_name,
  )),

  getrusage_cpu_user_time(
    cfg,
    title='CPU user time',
    description=|||
      This is the average share of time
      spent by instance process executing in user mode.
      Metrics obtained using `getrusage()` call.

      Panel works with `metrics >= 0.8.0`.
    |||,
  ):: getrusage_cpu_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    metric_name='tnt_cpu_user_time',
  ),

  getrusage_cpu_system_time(
    cfg,
    title='CPU system time',
    description=|||
      This is the average share of time
      spent by instance process executing in kernel mode.
      Metrics obtained using `getrusage()` call.

      Panel works with `metrics >= 0.8.0`.
    |||,
  ):: getrusage_cpu_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    metric_name='tnt_cpu_system_time',
  ),

  local procstat_thread_time_graph(
    cfg,
    title,
    description,
    kind,
  ) = common.default_graph(
    cfg=cfg,
    title=title,
    description=description,
    labelY1='ticks per second',
    min=0,
    decimalsY1=2,
    panel_width=12,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tnt_cpu_thread{job=~"%s",alias=~"%s",kind="%s"}[$__rate_interval])',
                        [cfg.job, cfg.filters.alias, kind]),
        legendFormat='{{alias}} — {{thread_name}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=['label_pairs_alias', 'label_pairs_thread_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_thread_name',
        fill='null',
      ).where('metric_name', '=', 'tnt_cpu_thread').where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .where('label_pairs_kind', '=', kind)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  procstat_thread_user_time(
    cfg,
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
  ):: procstat_thread_time_graph(
    cfg,
    title,
    description,
    'user',
  ),

  procstat_thread_system_time(
    cfg,
    title='Thread system time',
    description=|||
      Amount of time that this process has been scheduled
      in kernel mode, measured in clock ticks (divide by
      sysconf(_SC_CLK_TCK)). Average ticks per second is displayed.

      Metrics are obtained by parsing `/proc/self/task/[pid]/stat`.
    |||,
  ):: procstat_thread_time_graph(
    cfg,
    title,
    description,
    'system',
  ),
}
