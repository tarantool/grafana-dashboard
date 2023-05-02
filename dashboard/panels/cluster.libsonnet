local grafana = import 'grafonnet/grafana.libsonnet';

local timeseries = import 'dashboard/grafana/timeseries.libsonnet';
local common = import 'dashboard/panels/common.libsonnet';
local utils = import 'dashboard/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local statPanel = grafana.statPanel;
local tablePanel = grafana.tablePanel;
local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Cluster overview'),

  health_overview_table(
    title='Cluster status overview',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Overview of Tarantool instances observed by Prometheus job.

        If instance row is *red*, it means Prometheus can't reach
        URI specified in targets or ran into error.
        If instance row is *green*, it means instance is up and running and
        Prometheus is successfully extracting metrics from it.
        "Uptime" column shows time since instant start.
      |||
    else if datasource == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: tablePanel.new(
    title=title,
    description=description,
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
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            up{job=~"%s", %s} * on(instance) group_left(alias) tnt_info_uptime{job=~"%s", %s} or
            on(instance) label_replace(up{job=~"%s", %s}, "alias", "Not available", "instance", ".*")
          |||,
          [job, utils.generate_labels_string(labels), job, utils.generate_labels_string(labels), job, utils.generate_labels_string(labels)]
        ),
        format='table',
        instant=true,
      )
    else if datasource_type == variable.datasource_type.influxdb then
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
    title,
    description,
    datasource_type,
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
      { color: 'green', value: null }
    ).addTarget(
      if datasource_type == variable.datasource_type.prometheus then
        prometheus.target(expr=expr)
      else if datasource_type == variable.datasource_type.influxdb then
        error 'InfluxDB target is not supported yet'
    ),
    stat_title
  ),

  health_overview_stat(
    title='',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Count of running Tarantool instances observed by Prometheus job.
        If Prometheus can't reach URI specified in targets
        or ran into error, instance is not counted.
      |||
    else if datasource_type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: overview_stat(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Total instances running:',
    decimals=0,
    unit='none',
    expr=std.format('sum(up{job=~"%s", %s})', [job, utils.generate_labels_string(labels)]),
  ) { gridPos: { w: 6, h: 3 } },

  memory_used_stat(
    title='',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Overall value of memory used by Tarantool
        items and indexes (*arena_used* value).
        If Tarantool instance is not available
        for Prometheus metrics extraction now,
        its contribution is not counted.
      |||
    else if datasource_type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: overview_stat(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall memory used:',
    decimals=2,
    unit='bytes',
    expr=std.format('sum(tnt_slab_arena_used{job=~"%s", %s})', [job, utils.generate_labels_string(labels)]),
  ) { gridPos: { w: 3, h: 3 } },

  memory_reserved_stat(
    title='',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Overall value of memory available for Tarantool items
        and indexes allocation (*memtx_memory* or *quota_size* values).
        If Tarantool instance is not available for Prometheus metrics
        extraction now, its contribution is not counted.
      |||
    else if datasource_type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: overview_stat(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall memory reserved:',
    decimals=2,
    unit='bytes',
    expr=std.format('sum(tnt_slab_quota_size{job=~"%s", %s})',[job, utils.generate_labels_string(labels)]),
  ) { gridPos: { w: 3, h: 3 } },

  space_ops_stat(
    title='',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Overall rate of operations performed on Tarantool spaces
        (*select*, *insert*, *update* etc.).
        If Tarantool instance is not available for Prometheus metrics
        extraction now, its contribution is not counted.
      |||
    else if datasource_type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: overview_stat(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall space load:',
    decimals=3,
    unit='ops',
    expr=std.format('sum(rate(tnt_stats_op_total{job=~"%s", %s}[$__rate_interval]))', [job, utils.generate_labels_string(labels)]),
  ) { gridPos: { w: 4, h: 5 } },

  http_rps_stat(
    title='',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Overall rate of HTTP requests processed
        on Tarantool instances (all methods and response codes).
        If Tarantool instance is not available for Prometheus metrics
        extraction now, its contribution is not counted.
      |||
    else if datasource_type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: overview_stat(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall HTTP load:',
    decimals=3,
    unit='reqps',
    expr=std.format('sum(rate(http_server_request_latency_count{job=~"%s",%s}[$__rate_interval]))', [job, utils.generate_labels_string(labels)]),
  ) { gridPos: { w: 4, h: 5 } },

  net_rps_stat(
    title='',
    description=
    if datasource_type == variable.datasource_type.prometheus then
      |||
        Overall rate of network requests processed on Tarantool instances.
        If Tarantool instance is not available for Prometheus metrics
        extraction now, its contribution is not counted.
      |||
    else if datasource_type == variable.datasource_type.influxdb then
      error 'InfluxDB target is not supported yet',
    datasource_type=null,
    datasource=null,
    measurement=null,
    job=null,
    labels=null,
  ):: overview_stat(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    measurement=measurement,
    job=job,
    stat_title='Overall net load:',
    decimals=3,
    unit='reqps',
    expr=std.format('sum(rate(tnt_net_requests_total{job=~"%s", %s}[$__rate_interval]))', [job, utils.generate_labels_string(labels)]),
  ) { gridPos: { w: 4, h: 5 } },

  local cartridge_issues(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    level,
    labels,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    min=0,
    decimals=0,
    legend_avg=false,
    legend_max=false,
    panel_height=6,
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_cartridge_issues{job=~"%s",alias=~"%s",level="%s",%s}', [job, alias, level, utils.generate_labels_string(labels)]),
        legendFormat='{{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', 'tnt_cartridge_issues').where('label_pairs_alias', '=~', alias)
      .where('label_pairs_level', '=', level)
      .selectField('value').addConverter('last')
  ),

  cartridge_warning_issues(
    title='Cartridge warning issues',
    description=|||
      Number of "warning" issues on each cluster instance.
      "warning" issues includes high replication lag, replication long idle,
      failover and switchover issues, clock issues, memory fragmentation,
      configuration issues and alien members warnings.

      Panel works with `cartridge >= 2.0.2`, `metrics >= 0.6.0`,
      while `metrics >= 0.9.0` is recommended for per instance display.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: cartridge_issues(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    level='warning',
    labels=labels,
  ),

  cartridge_critical_issues(
    title='Cartridge critical issues',
    description=|||
      Number of "critical" issues on each cluster instance.
      "critical" issues includes replication process critical fails and
      running out of available memory.

      Panel works with `cartridge >= 2.0.2`, `metrics >= 0.6.0`,
      while `metrics >= 0.9.0` is recommended for per instance display.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: cartridge_issues(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    level='critical',
    labels=labels,
  ),

  failovers_per_second(
    title='Failovers triggered',
    description=|||
      Displays the count of failover triggers in a replicaset.
      Graph shows average per second.

      Panel works with `metrics >= 0.15.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='failovers per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_cartridge_failover_trigger_total',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  read_only_status(
    title='Tarantool instance status',
    description=|||
      `master` status means instance is available for read and
      write operations. `replica` status means instance is
      available only for read operations.

      Panel works with `metrics >= 0.11.0` and Grafana 8.x.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=datasource,
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
    common.default_metric_target(
      datasource_type,
      'tnt_read_only',
      job,
      policy,
      measurement,
      alias,
      'last',
      labels,
    )
  ),

  local election_warning(description) = std.join(
    '\n',
    [description, |||
      Panel works with metrics 0.15.0 or newer, Tarantool 2.6.1 or newer.
    |||]
  ),

  election_state(
    title='Instance election state',
    description=election_warning(|||
      Election state (mode) of the node.
      When election is enabled, the node is writable only in the leader state.

      All the non-leader nodes are called `follower`s.
      `candidate`s are nodes that start a new election round.
      `leader` is a node that collected a quorum of votes.

      Panel works with Grafana 8.x.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: timeseries.new(
    title=title,
    description=description,
    datasource=datasource,
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
    common.default_metric_target(
      datasource_type,
      'tnt_election_state',
      job,
      policy,
      measurement,
      alias,
      'last',
      labels
    )
  ),

  election_vote(
    title='Instance election vote',
    description=election_warning(|||
      ID of a node the current node votes for.
      If the value is 0, it means the node hasn’t
      voted in the current term yet.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='id',
    decimals=0,
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_election_vote',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  election_leader(
    title='Instance election leader',
    description=election_warning(|||
      Leader node ID in the current term.
      If the value is 0, it means the node doesn’t know which
      node is the leader in the current term.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='id',
    decimals=0,
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_election_leader',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  election_term(
    title='Election term',
    description=election_warning(|||
      Current election term.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='term',
    decimals=0,
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_election_term',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),
}
