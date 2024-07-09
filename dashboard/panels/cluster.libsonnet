local grafana = import 'grafonnet/grafana.libsonnet';

local timeseries = import 'dashboard/grafana/timeseries.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local statPanel = grafana.statPanel;
local tablePanel = grafana.tablePanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Cluster overview'),

  health_overview_table(
    cfg,
    title='Cluster status overview',
    description=common.prometheus_metrics_pull_note(|||
      Overview of Tarantool instances observed by Prometheus job.

      If instance row is *red*, it means Prometheus can't reach
      URI specified in targets or ran into error.
      If instance row is *green*, it means instance is up and running and
      Prometheus is successfully extracting metrics from it.
      "Uptime" column shows time since instant start.

      Instance alias filtering is disabled here.

      If Prometheus job filter is not specified, displays running instances
      and ignores unreachable instances (we have no specific source to fetch)
    |||),
  ):: tablePanel.new(
    title=title,
    description=description,
    datasource=cfg.datasource,

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
  ).hideColumn('job').hideColumn('/.*/').addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=if std.objectHas(cfg.filters, 'job') then
          std.format(
            |||
              up{%(up_filters)s} * on(instance) group_left(alias) %(metrics_prefix)stnt_info_uptime{%(tnt_filters)s} or
              on(instance) label_replace(up{%(up_filters)s}, "alias", "Not available", "instance", ".*")
            |||,
            {
              up_filters: common.prometheus_query_filters({ job: cfg.filters.job }),
              tnt_filters: common.prometheus_query_filters(common.remove_field(cfg.filters, 'alias')),
              metrics_prefix: cfg.metrics_prefix,
            }
          ) else std.format(
          '%stnt_info_uptime{%s}',
          [
            cfg.metrics_prefix,
            common.prometheus_query_filters(common.remove_field(cfg.filters, 'alias')),
          ],
        ),
        format='table',
        instant=true,
      )
    else if cfg.type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet'
  ) { gridPos: { w: 12, h: 8 } },

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
    cfg,
    title,
    description,
    stat_title=null,
    decimals=null,
    unit=null,
    expr=null,
  ) = title_workaround(
    statPanel.new(
      title=(if title != null then title else ''),
      description=description,

      datasource=cfg.datasource,
      colorMode='value',
      decimals=decimals,
      unit=unit,
      reducerFunction='last',
      pluginVersion='6.6.0',
    ).addThreshold(
      { color: 'green', value: null }
    ).addTarget(
      if cfg.type == variable.datasource_type.prometheus then
        prometheus.target(expr=expr)
      else if cfg.type == variable.datasource_type.influxdb then
        error 'InfluxDB target is not supported yet'
    ),
    stat_title
  ),

  local aggregate_expr(cfg, metric_name, aggregate='sum', rate=false) =
    local inner_expr = std.format(
      '%s%s{%s}',
      [
        cfg.metrics_prefix,
        metric_name,
        common.prometheus_query_filters(common.remove_field(cfg.filters, 'alias')),
      ]
    );
    std.format(
      '%s(%s)',
      [
        aggregate,
        if rate then std.format('rate(%s[$__rate_interval])', inner_expr) else inner_expr,
      ]
    ),

  health_overview_stat(
    cfg,
    title='',
    description=common.prometheus_metrics_pull_note(|||
      Count of running Tarantool instances observed by Prometheus job.
      If Prometheus can't reach URI specified in targets
      or ran into error, instance is not counted.

      Instance alias filtering is disabled here.
    |||),
  ):: if cfg.type == variable.datasource_type.prometheus then
    overview_stat(
      cfg,
      title=title,
      description=description,
      stat_title='Total instances running:',
      decimals=0,
      unit='none',
      expr=
      if std.objectHas(cfg.filters, 'job') then
        std.format(
          'sum(up{%s})',
          common.prometheus_query_filters({ job: cfg.filters.job }),
        )
      else
        aggregate_expr(cfg, 'tnt_info_uptime', 'count'),
    ) { gridPos: { w: 6, h: 3 } }
  else if cfg.type == variable.datasource_type.influxdb then
    error 'InfluxDB target is not supported yet',

  memory_used_stat(
    cfg,
    title='',
    description=|||
      Overall value of memory used by Tarantool
      items and indexes (*arena_used* value).
      If Tarantool instance is not available
      for Prometheus metrics extraction now,
      its contribution is not counted.

      Instance alias filtering is disabled here.
    |||,
  ):: if cfg.type == variable.datasource_type.prometheus then
    overview_stat(
      cfg,
      title=title,
      description=description,
      stat_title='Overall memory used:',
      decimals=2,
      unit='bytes',
      expr=aggregate_expr(cfg, 'tnt_slab_arena_used'),
    ) { gridPos: { w: 3, h: 3 } }
  else if cfg.type == variable.datasource_type.influxdb then
    error 'InfluxDB target is not supported yet',

  memory_reserved_stat(
    cfg,
    title='',
    description=|||
      Overall value of memory available for Tarantool items
      and indexes allocation (*memtx_memory* or *quota_size* values).
      If Tarantool instance is not available for Prometheus metrics
      extraction now, its contribution is not counted.

      Instance alias filtering is disabled here.
    |||,
  ):: if cfg.type == variable.datasource_type.prometheus then
    overview_stat(
      cfg,
      title=title,
      description=description,
      stat_title='Overall memory reserved:',
      decimals=2,
      unit='bytes',
      expr=aggregate_expr(cfg, 'tnt_slab_quota_size'),
    ) { gridPos: { w: 3, h: 3 } }
  else if cfg.type == variable.datasource_type.influxdb then
    error 'InfluxDB target is not supported yet',

  space_ops_stat(
    cfg,
    title='',
    description=|||
      Overall rate of operations performed on Tarantool spaces
      (*select*, *insert*, *update* etc.).
      If Tarantool instance is not available for Prometheus metrics
      extraction now, its contribution is not counted.

      Instance alias filtering is disabled here.
    |||
  ):: if cfg.type == variable.datasource_type.prometheus then
    overview_stat(
      cfg,
      title=title,
      description=description,
      stat_title='Overall space load:',
      decimals=2,
      unit='ops',
      expr=aggregate_expr(cfg, 'tnt_stats_op_total', rate=true),
    ) { gridPos: { w: 4, h: 5 } }
  else if cfg.type == variable.datasource_type.influxdb then
    error 'InfluxDB target is not supported yet',

  http_rps_stat(
    cfg,
    title='',
    description=|||
      Overall rate of HTTP requests processed
      on Tarantool instances (all methods and response codes).
      If Tarantool instance is not available for Prometheus metrics
      extraction now, its contribution is not counted.

      Instance alias filtering is disabled here.
    |||,
  ):: if cfg.type == variable.datasource_type.prometheus then
    overview_stat(
      cfg,
      title=title,
      description=description,
      stat_title='Overall HTTP load:',
      decimals=2,
      unit='reqps',
      expr=aggregate_expr(cfg, 'http_server_request_latency_count', rate=true),
    ) { gridPos: { w: 4, h: 5 } }
  else if cfg.type == variable.datasource_type.influxdb then
    error 'InfluxDB target is not supported yet',

  net_rps_stat(
    cfg,
    title='',
    description=|||
      Overall rate of network requests processed on Tarantool instances.
      If Tarantool instance is not available for Prometheus metrics
      extraction now, its contribution is not counted.

      Instance alias filtering is disabled here.
    |||,
  ):: if cfg.type == variable.datasource_type.prometheus then
    overview_stat(
      cfg,
      title=title,
      description=description,
      stat_title='Overall net load:',
      decimals=2,
      unit='reqps',
      expr=aggregate_expr(cfg, 'tnt_net_requests_total', rate=true),
    ) { gridPos: { w: 4, h: 5 } }
  else if cfg.type == variable.datasource_type.influxdb then
    error 'InfluxDB target is not supported yet',

  local cartridge_issues(
    cfg,
    title,
    description,
    level,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    min=0,
    legend_avg=false,
    legend_max=false,
    panel_height=6,
    panel_width=12,
  ).addTarget(
    common.target(
      cfg,
      'tnt_cartridge_issues',
      additional_filters={
        [variable.datasource_type.prometheus]: { level: ['=', level] },
        [variable.datasource_type.influxdb]: { label_pairs_level: ['=', level] },
      },
      converter='last',
    ),
  ),

  cartridge_warning_issues(
    cfg,
    title='Cartridge warning issues',
    description=|||
      Number of "warning" issues on each cluster instance.
      "warning" issues includes high replication lag, replication long idle,
      failover and switchover issues, clock issues, memory fragmentation,
      configuration issues and alien members warnings.

      Panel minimal requirements: cartridge 2.0.2, metrics 0.6.0;
      at least metrics 0.9.0 is recommended for per instance display.
    |||,
  ):: cartridge_issues(
    cfg,
    title=title,
    description=description,
    level='warning',
  ),

  cartridge_critical_issues(
    cfg,
    title='Cartridge critical issues',
    description=|||
      Number of "critical" issues on each cluster instance.
      "critical" issues includes replication process critical fails and
      running out of available memory.

      Panel minimal requirements: cartridge 2.0.2, metrics 0.6.0;
      at least metrics 0.9.0 is recommended for per instance display.
    |||,
  ):: cartridge_issues(
    cfg,
    title=title,
    description=description,
    level='critical',
  ),

  local tarantool3_config_description_note(description) = std.join('\n', [description, |||
    Panel minimal requirements: metrics 1.2.0, Tarantool 3.
  |||]),

  tarantool3_config_status(
    cfg,
    title='Tarantool configuration status',
    description=tarantool3_config_description_note(|||
      Current Tarantool 3 configuration apply status for a cluster instance.
      `uninitialized` decribes uninitialized instance,
      `check_errors` decribes instance with at least one apply error,
      `check_warnings` decribes instance with at least one apply warning,
      `startup_in_progress` decribes instance doing initial configuration apply,
      `reload_in_progress` decribes instance doing configuration apply over existing configuration,
      `ready` describes a healthy instance.

      Panel minimal requirements: Grafana 8.
    |||),
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=cfg.datasource,
    panel_width=12,
    max=6,
    min=1,
  ).addValueMapping(
    1, 'dark-red', 'uninitialized'
  ).addRangeMapping(
    1.001, 1.999, '-'
  ).addValueMapping(
    2, 'red', 'check_errors'
  ).addRangeMapping(
    2.001, 2.999, '-'
  ).addValueMapping(
    3, 'yellow', 'startup_in_progress'
  ).addRangeMapping(
    3.001, 3.999, '-'
  ).addValueMapping(
    4, 'dark-yellow', 'reload_in_progress'
  ).addRangeMapping(
    4.001, 4.999, '-'
  ).addValueMapping(
    5, 'dark-orange', 'check_warnings'
  ).addRangeMapping(
    5.001, 5.999, '-'
  ).addValueMapping(
    6, 'green', 'ready'
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      local expr = std.format(
        |||
          1 * %(metric_full_name)s{%(uninitialized_filters)s} + on(alias)
          2 * %(metric_full_name)s{%(check_errors_filters)s} + on(alias)
          3 * %(metric_full_name)s{%(startup_in_progress_filters)s} + on(alias)
          4 * %(metric_full_name)s{%(reload_in_progress_filters)s} + on(alias)
          5 * %(metric_full_name)s{%(check_warnings_filters)s} + on(alias)
          6 * %(metric_full_name)s{%(ready_filters)s}
        |||, {
          metric_full_name: cfg.metrics_prefix + 'tnt_config_status',
          uninitialized_filters: common.prometheus_query_filters(cfg.filters { status: ['=', 'uninitialized'] }),
          check_errors_filters: common.prometheus_query_filters(cfg.filters { status: ['=', 'check_errors'] }),
          startup_in_progress_filters: common.prometheus_query_filters(cfg.filters { status: ['=', 'startup_in_progress'] }),
          reload_in_progress_filters: common.prometheus_query_filters(cfg.filters { status: ['=', 'reload_in_progress'] }),
          check_warnings_filters: common.prometheus_query_filters(cfg.filters { status: ['=', 'check_warnings'] }),
          ready_filters: common.prometheus_query_filters(cfg.filters { status: ['=', 'ready'] }),
        }
      );
      prometheus.target(expr=expr, legendFormat='{{alias}}')
    else if cfg.type == variable.datasource_type.influxdb then
      local query = std.format(|||
        SELECT (1 * last("uninitialized") + 2 * last("check_errors") + 3 * last("startup_in_progress") +
                4 * last("reload_in_progress") + 5 * last("check_warnings") + 6 * last("ready")) as "status" FROM
        (
          SELECT "value" as "uninitialized" FROM %(measurement_with_policy)s
          WHERE ("metric_name" = '%(metric_full_name)s' AND %(uninitialized_filters)s) AND $timeFilter
        ),
        (
          SELECT "value" as "check_errors" FROM %(measurement_with_policy)s
          WHERE ("metric_name" = '%(metric_full_name)s' AND %(check_errors_filters)s) AND $timeFilter
        ),
        (
          SELECT "value" as "startup_in_progress" FROM %(measurement_with_policy)s
          WHERE ("metric_name" = '%(metric_full_name)s' AND %(startup_in_progress_filters)s) AND $timeFilter
        ),
        (
          SELECT "value" as "reload_in_progress" FROM %(measurement_with_policy)s
          WHERE ("metric_name" = '%(metric_full_name)s' AND %(reload_in_progress_filters)s) AND $timeFilter
        ),
        (
          SELECT "value" as "check_warnings" FROM %(measurement_with_policy)s
          WHERE ("metric_name" = '%(metric_full_name)s' AND %(check_warnings_filters)s) AND $timeFilter
        ),
        (
          SELECT "value" as "ready" FROM %(measurement_with_policy)s
          WHERE ("metric_name" = '%(metric_full_name)s' AND %(ready_filters)s) AND $timeFilter
        )
        GROUP BY time($__interval), "label_pairs_alias" fill(none)
      |||, {
        metric_full_name: cfg.metrics_prefix + 'tnt_config_status',
        measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
          policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
          measurement: cfg.measurement,
        }),
        uninitialized_filters: common.influxdb_query_filters(cfg.filters { label_pairs_status: ['=', 'uninitialized'] }),
        check_errors_filters: common.influxdb_query_filters(cfg.filters { label_pairs_status: ['=', 'check_errors'] }),
        startup_in_progress_filters: common.influxdb_query_filters(cfg.filters { label_pairs_status: ['=', 'startup_in_progress'] }),
        reload_in_progress_filters: common.influxdb_query_filters(cfg.filters { label_pairs_status: ['=', 'reload_in_progress'] }),
        check_warnings_filters: common.influxdb_query_filters(cfg.filters { label_pairs_status: ['=', 'check_warnings'] }),
        ready_filters: common.influxdb_query_filters(cfg.filters { label_pairs_status: ['=', 'ready'] }),
      });
      influxdb.target(
        rawQuery=true,
        query=query,
        alias='$tag_label_pairs_alias',
      )
  ),

  local tarantool3_config_alerts(
    cfg,
    title,
    description,
    level,
  ) = common.default_graph(
    cfg,
    title=title,
    description=tarantool3_config_description_note(description),
    min=0,
    legend_avg=false,
    legend_max=false,
    panel_height=8,
    panel_width=6,
  ).addTarget(
    common.target(
      cfg,
      'tnt_config_alerts',
      additional_filters={
        [variable.datasource_type.prometheus]: { level: ['=', level] },
        [variable.datasource_type.influxdb]: { label_pairs_level: ['=', level] },
      },
      converter='last',
    ),
  ),

  tarantool3_config_warning_alerts(
    cfg,
    title='Tarantool configuration warnings',
    description=|||
      Number of "warn" alerts on Tarantool 3 configuration apply on a cluster instance.
      "warn" alerts cover non-critical issues which do not result in apply failure,
      like missing a role to grant for a user.
    |||,
  ):: tarantool3_config_alerts(
    cfg,
    title=title,
    description=description,
    level='warn',
  ),

  tarantool3_config_error_alerts(
    cfg,
    title='Tarantool configuration errors',
    description=|||
      Number of "error" alerts on Tarantool 3 configuration apply on a cluster instance.
      "error" alerts cover critical issues which results in apply failure,
      like instance missing itself in configuration.
    |||,
  ):: tarantool3_config_alerts(
    cfg,
    title=title,
    description=description,
    level='error',
  ),

  failovers_per_second(
    cfg,
    title='Failovers triggered',
    description=|||
      Displays the count of failover triggers in a replicaset.
      Graph shows average per second.

      Panel minimal requirements: metrics 0.15.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='failovers per second',
    panel_width=12,
  ).addTarget(
    common.target(cfg, 'tnt_cartridge_failover_trigger_total', rate=true)
  ),

  read_only_status(
    cfg,
    title='Tarantool instance status',
    description=|||
      `master` status means instance is available for read and
      write operations. `replica` status means instance is
      available only for read operations.

      Panel minimal requirements: metrics 0.11.0, Grafana 8.
    |||,
    panel_width=12,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=cfg.datasource,
    panel_width=panel_width,
    max=1,
    min=0,
  ).addValueMapping(
    0, 'green', 'master'
  ).addValueMapping(
    1, 'yellow', 'replica'
  ).addRangeMapping(
    0.001, 0.999, '-'
  ).addTarget(
    common.target(cfg, 'tnt_read_only', converter='last')
  ),

  local election_warning(description) = std.join(
    '\n',
    [description, |||
      Panel minimal requirements: metrics 0.15.0, Tarantool 2.6.1.
    |||]
  ),

  election_state(
    cfg,
    title='Instance election state',
    description=election_warning(|||
      Election state (mode) of the node.
      When election is enabled, the node is writable only in the leader state.

      All the non-leader nodes are called `follower`s.
      `candidate`s are nodes that start a new election round.
      `leader` is a node that collected a quorum of votes.

      Panel minimal requirements: Grafana 8.
    |||),
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=cfg.datasource,
    panel_width=6,
    max=2,
    min=0,
  ).addValueMapping(
    0, 'green', 'follower'
  ).addValueMapping(
    1, 'yellow', 'candidate'
  ).addValueMapping(
    2, 'green', 'leader'
  ).addRangeMapping(
    0.001, 0.999, '-'
  ).addRangeMapping(
    1.001, 1.999, '-'
  ).addTarget(
    common.target(cfg, 'tnt_election_state', converter='last')
  ),

  election_vote(
    cfg,
    title='Instance election vote',
    description=election_warning(|||
      ID of a node the current node votes for.
      If the value is 0, it means the node hasn’t
      voted in the current term yet.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='id',
    decimals=0,
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_election_vote')
  ),

  election_leader(
    cfg,
    title='Instance election leader',
    description=election_warning(|||
      Leader node ID in the current term.
      If the value is 0, it means the node doesn’t know which
      node is the leader in the current term.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='id',
    decimals=0,
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_election_leader')
  ),

  election_term(
    cfg,
    title='Election term',
    description=election_warning(|||
      Current election term.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='term',
    decimals=0,
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_election_term')
  ),
}
