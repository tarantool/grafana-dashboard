local grafana = import 'grafonnet/grafana.libsonnet';

local graph = grafana.graphPanel;
local statPanel = grafana.statPanel;
local tablePanel = grafana.tablePanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  health_overview_table(
    title='Cluster status overview',
    description=null,

    datasource=null,
    measurement=null,
    job=null,
  ):: tablePanel.new(
    title=title,
    description=(
      if description != null then
        description
      else (
        if datasource == '${DS_PROMETHEUS}' then
          |||
            Overview of Tarantool instances, observed by Prometheus job.

            If instance row is *red*, it means Prometheus can't reach URI specified in targets or ran into error.
            If instance row is *green*, it means instance is up and running and
            Prometheus is successfully extracting metrics from it.
            "Uptime" column shows time since instant start.
          |||
        else
          null
      )
    ),
    datasource=datasource,

    styles=[
      {
        alias: 'Instance alias',
        pattern: 'alias',
        thresholds: [],
        type: 'string',
        mappingType: 1,
      },
      {
        alias: 'Instance URI',
        pattern: 'instance',
        thresholds: [],
        type: 'string',
        mappingType: 1,
      },
      {
        alias: 'Uptime',
        colorMode: 'row',
        colors: [
          'rgba(245, 54, 54, 0.9)',
          'rgba(237, 129, 40, 0.89)',
          'rgba(50, 172, 45, 0.97)',
        ],
        decimals: 0,
        mappingType: 1,
        pattern: 'Value',
        thresholds: ['0.1', '0.1'],
        type: 'number',
        unit: 's',
      },
    ],
    sort={
      col: 2,
      desc: false,
    },
    transform='table',
  ).hideColumn('job').hideColumn('__name__').hideColumn('Time').addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format(
          |||
            up{job="%s"} * on(instance) group_left(alias) tnt_info_uptime{job="%s"} or
            on(instance) label_replace(up{job="%s"}, "alias", "Not available", "instance", ".*")
          |||,
          [job, job, job]
        ),
        format='table',
        instant=true,
      )
    else if datasource == '${DS_INFLUXDB}' then
      error 'InfluxDB target not supported yet'
  ),

  local title_workaround(  // Workaround for missing options.fieldOptions.defaults.title https://github.com/grafana/grafonnet-lib/pull/260
    stat_panel,
    title
  ) = (
    stat_panel {
      options: stat_panel.options {
        fieldOptions: stat_panel.options.fieldOptions {
          defaults: stat_panel.options.fieldOptions.defaults {
            title: title,
          },
        },
      },
    }
  ),

  local overview_stat(
    title,
    description,
    datasource,
    measurement=null,
    job=null,
    stat_title=null,
    decimals=null,
    unit=null,
    expr=null,
  ) = title_workaround(
    statPanel.new(
      title=(if title != null then title else ''),
      description=description,

      datasource=datasource,
      colorMode='value',
      decimals=decimals,
      unit=unit,
      reducerFunction='last',
      pluginVersion='6.6.0',
    ).addThreshold(
      { color: 'red', value: null }
    ).addThreshold(
      { color: 'green', value: 0.1 }
    ).addTarget(prometheus.target(expr=expr)),
    stat_title
  ),

  health_overview_stat(
    title='',
    description=null,

    datasource=null,
    measurement=null,
    job=null,
  ):: overview_stat(
    title=title,
    description=(
      if description != null then
        description
      else (
        if datasource == '${DS_PROMETHEUS}' then
          |||
            Count of running Tarantool instances, observed by Prometheus job.
            If Prometheus can't reach URI specified in targets or ran into error, instance is not counted.
          |||
        else
          null
      )
    ),
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Total instances running:',
    decimals=0,
    unit='none',
    expr=std.format('sum(up{job=~"%s"})', job),
  ),

  memory_used_stat(
    title='',
    description=null,

    datasource=null,
    measurement=null,
    job=null,
  ):: overview_stat(
    title=title,
    description=(
      if description != null then
        description
      else (
        if datasource == '${DS_PROMETHEUS}' then
          |||
            Overall value of memory used by Tarantool items and indexes (*arena_used* value).
            If Tarantool instance is not available for Prometheus metrics extraction now, its contribution is not counted.
          |||
        else
          null
      )
    ),
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall memory used:',
    decimals=2,
    unit='bytes',
    expr=std.format('sum(tnt_slab_arena_used{job=~"%s"})', job),
  ),

  memory_reserved_stat(
    title='',
    description=null,

    datasource=null,
    measurement=null,
    job=null,
  ):: overview_stat(
    title=title,
    description=(
      if description != null then
        description
      else (
        if datasource == '${DS_PROMETHEUS}' then
          |||
            Overall value of memory available for Tarantool items and indexes allocation (*memtx_memory* or *quota_size* values).
            If Tarantool instance is not available for Prometheus metrics extraction now, its contribution is not counted.
          |||
        else
          null
      )
    ),
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall memory reserved:',
    decimals=2,
    unit='bytes',
    expr=std.format('sum(tnt_slab_quota_size{job=~"%s"})', job),
  ),

  space_ops_stat(
    title='',
    description=null,

    datasource=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: overview_stat(
    title=title,
    description=(
      if description != null then
        description
      else (
        if datasource == '${DS_PROMETHEUS}' then
          |||
            Overall rate of operations performed on Tarantool spaces (*select*, *insert*, *update* etc.).
            If Tarantool instance is not available for Prometheus metrics extraction now, its contribution is not counted.
          |||
        else
          null
      )
    ),
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall space load:',
    decimals=2,
    unit='ops',
    expr=std.format('sum(rate(tnt_stats_op_total{job=~"%s"}[%s]))', [job, rate_time_range]),
  ),

  http_rps_stat(
    title='',
    description=null,

    datasource=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: overview_stat(
    title=title,
    description=(
      if description != null then
        description
      else (
        if datasource == '${DS_PROMETHEUS}' then
          |||
            Overall rate of requests processed on Tarantool instances (all methods and response codes).
            If Tarantool instance is not available for Prometheus metrics extraction now, its contribution is not counted.
          |||
        else
          null
      )
    ),
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall HTTP load:',
    decimals=2,
    unit='reqps',
    expr=std.format('sum(rate(http_server_request_latency_count{job=~"%s"}[%s]))', [job, rate_time_range]),
  ),

  local cartridge_issues(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    level,
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='none',
    fill=0,
    decimals=0,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_current=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format('tnt_cartridge_issues{job=~"%s",level="%s"}', [job, level]),
        legendFormat='{{alias}}',
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
      ).where('metric_name', '=', 'tnt_cartridge_issues').where('label_pairs_level', '=', level)
      .selectField('value').addConverter('last')
  ),

  cartridge_warning_issues(
    title='Cartridge warning issues',
    description=|||
      Number of "warning" issues on each cluster instance.
      "warning" issues includes high replication lag, replication long idle,
      failover and switchover issues, clock issues, memory fragmentation,
      configuration issues and alien members warnings.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: cartridge_issues(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    level='warning',
  ),

  cartridge_critical_issues(
    title='Cartridge critical issues',
    description=|||
      Number of "critical" issues on each cluster instance.
      "critical" issues includes replication process critical fails and
      running out of available memory.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: cartridge_issues(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    level='critical',
  ),

}
