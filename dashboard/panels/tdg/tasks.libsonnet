local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG tasks statistics'),

  local jobs_rps_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    panel_width=8,
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='jobs per second',
    panel_width=panel_width,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[$__rate_interval])', [metric_name, job]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_kind',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local jobs_metric_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='current',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_kind',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),
  ),

  local jobs_average_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='average',
    format='s',
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s"} /
            %(metric_name_count)s{job=~"%(job)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: job,
          }
        ),
        legendFormat='{{name}} — {{alias}}'
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s') AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s') AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_name" fill(none)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if policy == 'default' then '' else std.format('"%(policy)s".', policy),
          measurement: measurement,
        }),
        alias='$tag_label_pairs_name — $tag_label_pairs_alias'
      )
  ),

  local tasks_rps_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
    panel_width=8,
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='tasks per second',
    panel_width=panel_width,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[$__rate_interval])', [metric_name, job]),
        legendFormat='{{name}} ({{kind}}) — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_kind',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_kind) — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local tasks_metric_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='current',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} ({{kind}}) — {{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_kind',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_kind) — $tag_label_pairs_alias',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),
  ),

  local tasks_average_panel(
    title,
    description,
    datasource_type,
    datasource,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  ) = common_utils.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='average',
    format='s',
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s"} /
            %(metric_name_count)s{job=~"%(job)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: job,
          }
        ),
        legendFormat='{{name}} ({{kind}}) — {{alias}}'
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s') AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s') AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_name",
          "label_pairs_kind" fill(none)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if policy == 'default' then '' else std.format('"%(policy)s".', policy),
          measurement: measurement,
        }),
        alias='$tag_label_pairs_name ($tag_label_pairs_kind) — $tag_label_pairs_alias'
      )
  ),

  jobs_started(
    title='Jobs started',
    description=|||
      Number of TDG jobs started.
      Graph shows mean jobs per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: jobs_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_jobs_started',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  jobs_failed(
    title='Jobs failed',
    description=|||
      Number of TDG jobs failed.
      Graph shows mean jobs per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: jobs_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_jobs_failed',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  jobs_succeeded(
    title='Jobs succeeded',
    description=|||
      Number of TDG jobs succeeded.
      Graph shows mean jobs per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: jobs_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_jobs_succeeded',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  jobs_running(
    title='Jobs running',
    description=|||
      Number of TDG jobs running now.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: jobs_metric_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_jobs_running',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  jobs_time(
    title='Jobs execution time',
    description=|||
      Average time of TDG job execution.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: jobs_average_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_jobs_execution_time',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  tasks_started(
    title='Tasks started',
    description=|||
      Number of TDG tasks started.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_tasks_started',
    job=job,
    policy=policy,
    measurement=measurement,
    panel_width=6,
  ),

  tasks_failed(
    title='Tasks failed',
    description=|||
      Number of TDG tasks failed.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_tasks_failed',
    job=job,
    policy=policy,
    measurement=measurement,
    panel_width=6,
  ),

  tasks_succeeded(
    title='Tasks succeeded',
    description=|||
      Number of TDG tasks succeeded.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_tasks_succeeded',
    job=job,
    policy=policy,
    measurement=measurement,
    panel_width=6,
  ),

  tasks_stopped(
    title='Tasks stopped',
    description=|||
      Number of TDG tasks stopped.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_tasks_stopped',
    job=job,
    policy=policy,
    measurement=measurement,
    panel_width=6,
  ),

  tasks_running(
    title='Tasks running',
    description=|||
      Number of TDG tasks running now.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_metric_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_tasks_running',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  tasks_time(
    title='Tasks execution time',
    description=|||
      Average time of TDG task execution.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_average_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_tasks_execution_time',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  system_tasks_started(
    title='System tasks started',
    description=|||
      Number of TDG system tasks started.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_system_tasks_started',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  system_tasks_failed(
    title='System tasks failed',
    description=|||
      Number of TDG system tasks failed.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_system_tasks_failed',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  system_tasks_succeeded(
    title='System tasks succeeded',
    description=|||
      Number of TDG system tasks succeeded.
      Graph shows mean tasks per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_rps_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_system_tasks_succeeded',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  system_tasks_running(
    title='System tasks running',
    description=|||
      Number of TDG system tasks running now.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_metric_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_system_tasks_running',
    job=job,
    policy=policy,
    measurement=measurement,
  ),

  system_tasks_time(
    title='Tasks execution time',
    description=|||
      Average time of TDG system task execution.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tasks_average_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    metric_name='tdg_system_tasks_execution_time',
    job=job,
    policy=policy,
    measurement=measurement,
  ),
}
