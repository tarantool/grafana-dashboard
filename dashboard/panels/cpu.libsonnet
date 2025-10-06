local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local common_utils = import 'dashboard/panels/common.libsonnet';
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
    panel_width=8,
  ).addTarget(
    common.target(cfg, metric_name, rate=true)
  ),

  getrusage_cpu_instance_user_time(
    cfg,
    title='CPU user time per instance',
    description=|||
      This is the average share of time
      spent by instance process executing in user mode.
      Metrics obtained using `getrusage()` call.

      Panel minimal requirements: metrics 0.8.0.
    |||,
  ):: getrusage_cpu_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    metric_name='tnt_cpu_user_time',
  ),

  getrusage_cpu_instance_system_time(
    cfg,
    title='CPU system time per instance',
    description=|||
      This is the average share of time
      spent by instance process executing in kernel mode.
      Metrics obtained using `getrusage()` call.

      Panel minimal requirements: metrics 0.8.0.
    |||,
  ):: getrusage_cpu_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    metric_name='tnt_cpu_system_time',
  ),

  // --------------------------------------------------------------------------
  local getrusage_cpu_total_percentage_graph(
    cfg, title, description,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='percentunit',
    decimalsY1=0,
    min=0,
    panel_width=8,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            rate(%(metrics_prefix)stnt_cpu_user_time{%(filters)s}[$__rate_interval]) +
            rate(%(metrics_prefix)stnt_cpu_system_time{%(filters)s}[$__rate_interval])
          |||,
          {
            metrics_prefix: cfg.metrics_prefix,
            filters: common.prometheus_query_filters(cfg.filters),
          }
        ),
        legendFormat='{{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT non_negative_derivative(SUM("value"), 1s)
          FROM %(measurement_with_policy)s
          WHERE (("metric_name" = '%(metric_user_time)s' OR "metric_name" = '%(metric_system_time)s') AND %(filters)s)
          AND $timeFilter
          GROUP BY time($__interval), "label_pairs_alias" fill(none)
        |||, {
          measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
            policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
            measurement: cfg.measurement,
          }),
          metric_user_time: cfg.metrics_prefix + 'tnt_cpu_user_time',
          metric_system_time: cfg.metrics_prefix + 'tnt_cpu_system_time',
          filters: common.influxdb_query_filters(cfg.filters),
        }),
        alias='$tag_label_pairs_alias',
      )
  ),

  getrusage_cpu_instance_total_time(
    cfg,
    title='CPU total time per instance',
    description=|||
      This is the average share of time spent
      by instance process executing.

      Panel minimal requirements: metrics 0.8.0.
    |||,
  ):: getrusage_cpu_total_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
  ),

  // --------------------------------------------------------------------------
  local getrusage_cpu_common_percentage_graph(
    cfg,
    title,
    description,
    prometheus_expr,
    prometheus_legend,
    influx_query,
    influx_alias,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='percentunit',
    decimalsY1=0,
    min=0,
    panel_width=8,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=prometheus_expr,
        legendFormat=prometheus_legend,
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=influx_query,
        alias=influx_alias,
      )
  ),

  getrusage_cpu_total_time(
    cfg,
    title='CPU total time per cluster',
    description=|||
      This is the total share of time spent
      by each cluster process executing.

      Panel minimal requirements: metrics 0.8.0.
    |||,
  ):: getrusage_cpu_common_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    prometheus_expr=std.format(
      |||
        sum(rate(%(metrics_prefix)stnt_cpu_user_time{%(filters)s}[$__rate_interval])) +
        sum(rate(%(metrics_prefix)stnt_cpu_system_time{%(filters)s}[$__rate_interval]))
      |||,
      {
        metrics_prefix: cfg.metrics_prefix,
        filters: common.prometheus_query_filters(common.remove_field(cfg.filters, 'alias')),
      }
    ),
    prometheus_legend=title,
    influx_query=std.format(|||
      SELECT non_negative_derivative(SUM("value"), 1s)
      FROM %(measurement_with_policy)s
      WHERE (("metric_name" = '%(metric_user_time)s' OR "metric_name" = '%(metric_system_time)s') AND %(filters)s)
      AND $timeFilter
      GROUP BY time($__interval)
    |||, {
      measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
        policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
        measurement: cfg.measurement,
      }),
      metric_user_time: cfg.metrics_prefix + 'tnt_cpu_user_time',
      metric_system_time: cfg.metrics_prefix + 'tnt_cpu_system_time',
      filters: if common.influxdb_query_filters(common.remove_field(cfg.filters, 'label_pairs_alias')) != ''
      then common.influxdb_query_filters(common.remove_field(cfg.filters, 'label_pairs_alias'))
      else 'true',
    }),
    influx_alias=title
  ),

  getrusage_cpu_total_user_time(
    cfg,
    title='CPU total user time per cluster',
    description=|||
      This is the total share of time
      spent in user mode per cluster.

      Panel minimal requirements: metrics 0.8.0.
    |||,
  ):: getrusage_cpu_common_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    prometheus_expr=std.format(
      |||
        sum(rate(%(metrics_prefix)stnt_cpu_user_time{%(filters)s}[$__rate_interval]))
      |||,
      {
        metrics_prefix: cfg.metrics_prefix,
        filters: common.prometheus_query_filters(common.remove_field(cfg.filters, 'alias')),
      }
    ),
    prometheus_legend=title,
    influx_query=std.format(|||
      SELECT non_negative_derivative(SUM("value"), 1s)
      FROM %(measurement_with_policy)s
      WHERE "metric_name" = '%(metric_user_time)s' AND %(filters)s
      AND $timeFilter
      GROUP BY time($__interval)
    |||, {
      measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
        policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
        measurement: cfg.measurement,
      }),
      metric_user_time: cfg.metrics_prefix + 'tnt_cpu_user_time',
      filters: common.influxdb_query_filters(cfg.filters),
    }),
    influx_alias=title
  ),

  getrusage_cpu_total_system_time(
    cfg,
    title='CPU total system time per cluster',
    description=|||
      This is the total share of time
      spent in system mode per cluster.

      Panel minimal requirements: metrics 0.8.0.
    |||,
  ):: getrusage_cpu_common_percentage_graph(
    cfg=cfg,
    title=title,
    description=description,
    prometheus_expr=std.format(
      |||
        sum(rate(%(metrics_prefix)stnt_cpu_system_time{%(filters)s}[$__rate_interval]))
      |||,
      {
        metrics_prefix: cfg.metrics_prefix,
        filters: common.prometheus_query_filters(common.remove_field(cfg.filters, 'alias')),
      }
    ),
    prometheus_legend=title,
    influx_query=std.format(|||
      SELECT non_negative_derivative(SUM("value"), 1s)
      FROM %(measurement_with_policy)s
      WHERE "metric_name" = '%(metric_system_time)s' AND %(filters)s
      AND $timeFilter
      GROUP BY time($__interval)
    |||, {
      measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
        policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
        measurement: cfg.measurement,
      }),
      metric_system_time: cfg.metrics_prefix + 'tnt_cpu_system_time',
      filters: common.influxdb_query_filters(cfg.filters),
    }),
    influx_alias=title
  ),

  // --------------------------------------------------------------------------
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
    panel_width=12,
  ).addTarget(
    common.target(
      cfg,
      'tnt_cpu_thread',
      additional_filters={
        [variable.datasource_type.prometheus]: { kind: ['=', kind] },
        [variable.datasource_type.influxdb]: { label_pairs_kind: ['=', kind] },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} — {{thread_name}}',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias — $tag_label_pairs_thread_name',
      },
      group_tags=['label_pairs_alias', 'label_pairs_thread_name'],
      rate=true,
    ),
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
