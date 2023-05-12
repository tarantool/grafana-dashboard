local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common_utils.row('TDG tasks statistics'),

  local jobs_rps_panel(
    cfg,
    title,
    description,
    metric_name,
    panel_width=8,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='jobs per second',
    panel_width=panel_width,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])', [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local jobs_metric_panel(
    cfg,
    title,
    description,
    metric_name,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='current',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
        ],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),
  ),

  local jobs_average_panel(
    cfg,
    title,
    description,
    metric_name,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='average',
    format='s',
    panel_width=12,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s",alias=~"%(alias)s"} /
            %(metric_name_count)s{job=~"%(job)s",alias=~"%(alias)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: cfg.job,
            alias: cfg.filters.alias,
          }
        ),
        legendFormat='{{name}} — {{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s' AND "label_pairs_alias" =~ %(alias)s)
          AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s' AND "label_pairs_alias" =~ %(alias)s)
          AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_name" fill(null)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
          alias: cfg.filters.label_pairs_alias,
        }),
        alias='$tag_label_pairs_name — $tag_label_pairs_alias'
      )
  ),

  local tasks_rps_panel(
    cfg,
    title,
    description,
    metric_name,
    panel_width=8,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tasks per second',
    panel_width=panel_width,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])', [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{kind}}) — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_kind',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_kind) — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
  ),

  local tasks_metric_panel(
    cfg,
    title,
    description,
    metric_name,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='current',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.job, cfg.filters.alias]),
        legendFormat='{{name}} ({{kind}}) — {{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=[
          'label_pairs_alias',
          'label_pairs_name',
          'label_pairs_kind',
        ],
        alias='$tag_label_pairs_name ($tag_label_pairs_kind) — $tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias)
      .selectField('value').addConverter('mean'),
  ),

  local tasks_average_panel(
    cfg,
    title,
    description,
    metric_name,
  ) = common_utils.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='average',
    format='s',
    panel_width=12,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            %(metric_name_sum)s{job=~"%(job)s",alias=~"%(alias)s"} /
            %(metric_name_count)s{job=~"%(job)s",alias=~"%(alias)s"}
          |||,
          {
            metric_name_sum: std.join('_', [metric_name, 'sum']),
            metric_name_count: std.join('_', [metric_name, 'count']),
            job: cfg.job,
            alias: cfg.filters.alias,
          }
        ),
        legendFormat='{{name}} ({{kind}}) — {{alias}}'
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name_sum)s") / mean("%(metric_name_count)s")
          as "average" FROM
          (SELECT "value" as "%(metric_name_sum)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_sum)s' AND "label_pairs_alias" =~ %(alias)s)
          AND $timeFilter),
          (SELECT "value" as "%(metric_name_count)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name_count)s' AND "label_pairs_alias" =~ %(alias)s)
          AND $timeFilter)
          GROUP BY time($__interval), "label_pairs_alias", "label_pairs_name",
          "label_pairs_kind" fill(null)
        |||, {
          metric_name_sum: std.join('_', [metric_name, 'sum']),
          metric_name_count: std.join('_', [metric_name, 'count']),
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
          alias: cfg.filters.label_pairs_alias,
        }),
        alias='$tag_label_pairs_name ($tag_label_pairs_kind) — $tag_label_pairs_alias'
      )
  ),

  jobs_started(
    cfg,
    title='Jobs started',
    description=|||
      Number of TDG jobs started.
      Graph shows mean jobs per second.
    |||,
  ):: jobs_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_jobs_started',
  ),

  jobs_failed(
    cfg,
    title='Jobs failed',
    description=|||
      Number of TDG jobs failed.
      Graph shows mean jobs per second.
    |||,
  ):: jobs_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_jobs_failed',
  ),

  jobs_succeeded(
    cfg,
    title='Jobs succeeded',
    description=|||
      Number of TDG jobs succeeded.
      Graph shows mean jobs per second.
    |||,
  ):: jobs_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_jobs_succeeded',
  ),

  jobs_running(
    cfg,
    title='Jobs running',
    description=|||
      Number of TDG jobs running now.
    |||,
  ):: jobs_metric_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_jobs_running',
  ),

  jobs_time(
    cfg,
    title='Jobs execution time',
    description=|||
      Average time of TDG job execution.
    |||,
  ):: jobs_average_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_jobs_execution_time',
  ),

  tasks_started(
    cfg,
    title='Tasks started',
    description=|||
      Number of TDG tasks started.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_tasks_started',
    panel_width=6,
  ),

  tasks_failed(
    cfg,
    title='Tasks failed',
    description=|||
      Number of TDG tasks failed.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_tasks_failed',
    panel_width=6,
  ),

  tasks_succeeded(
    cfg,
    title='Tasks succeeded',
    description=|||
      Number of TDG tasks succeeded.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_tasks_succeeded',
    panel_width=6,
  ),

  tasks_stopped(
    cfg,
    title='Tasks stopped',
    description=|||
      Number of TDG tasks stopped.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_tasks_stopped',
    panel_width=6,
  ),

  tasks_running(
    cfg,
    title='Tasks running',
    description=|||
      Number of TDG tasks running now.
    |||,
  ):: tasks_metric_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_tasks_running',
  ),

  tasks_time(
    cfg,
    title='Tasks execution time',
    description=|||
      Average time of TDG task execution.
    |||,
  ):: tasks_average_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_tasks_execution_time',
  ),

  system_tasks_started(
    cfg,
    title='System tasks started',
    description=|||
      Number of TDG system tasks started.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_system_tasks_started',
  ),

  system_tasks_failed(
    cfg,
    title='System tasks failed',
    description=|||
      Number of TDG system tasks failed.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_system_tasks_failed',
  ),

  system_tasks_succeeded(
    cfg,
    title='System tasks succeeded',
    description=|||
      Number of TDG system tasks succeeded.
      Graph shows mean tasks per second.
    |||,
  ):: tasks_rps_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_system_tasks_succeeded',
  ),

  system_tasks_running(
    cfg,
    title='System tasks running',
    description=|||
      Number of TDG system tasks running now.
    |||,
  ):: tasks_metric_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_system_tasks_running',
  ),

  system_tasks_time(
    cfg,
    title='Tasks execution time',
    description=|||
      Average time of TDG system task execution.
    |||,
  ):: tasks_average_panel(
    cfg,
    title=title,
    description=description,
    metric_name='tdg_system_tasks_execution_time',
  ),
}
