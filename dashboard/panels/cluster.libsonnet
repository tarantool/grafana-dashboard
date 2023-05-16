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
    description=|||
      Overview of Tarantool instances observed by Prometheus job.

      If instance row is *red*, it means Prometheus can't reach
      URI specified in targets or ran into error.
      If instance row is *green*, it means instance is up and running and
      Prometheus is successfully extracting metrics from it.
      "Uptime" column shows time since instant start.

      Instance alias filtering is disabled here.

      If Prometheus job filter is not specified, displays running instances
      and ignores unreachable instances (we have no specific source to fetch)
    |||,
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
  ).hideColumn('job').hideColumn('__name__').hideColumn('Time').addTarget(
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
    description=|||
      Count of running Tarantool instances observed by Prometheus job.
      If Prometheus can't reach URI specified in targets
      or ran into error, instance is not counted.

      Instance alias filtering is disabled here.
    |||,
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
    decimals=0,
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

      Panel works with `cartridge >= 2.0.2`, `metrics >= 0.6.0`,
      while `metrics >= 0.9.0` is recommended for per instance display.
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

      Panel works with `cartridge >= 2.0.2`, `metrics >= 0.6.0`,
      while `metrics >= 0.9.0` is recommended for per instance display.
    |||,
  ):: cartridge_issues(
    cfg,
    title=title,
    description=description,
    level='critical',
  ),

  failovers_per_second(
    cfg,
    title='Failovers triggered',
    description=|||
      Displays the count of failover triggers in a replicaset.
      Graph shows average per second.

      Panel works with `metrics >= 0.15.0`.
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

      Panel works with `metrics >= 0.11.0` and Grafana 8.x.
    |||,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=cfg.datasource,
    panel_width=12,
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
      Panel works with metrics 0.15.0 or newer, Tarantool 2.6.1 or newer.
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

      Panel works with Grafana 8.x.
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
