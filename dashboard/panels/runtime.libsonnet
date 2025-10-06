local grafana = import 'grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local influxdb = grafana.influxdb;

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

{
  row:: common.row('Tarantool runtime overview'),

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

  total_memory_per_instance(
    cfg,
    title='Total memory per instance',
    description=|||
      Total memory used by Tarantool.

      Panel minimal requirements: metrics 1.6.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          |||
            (%(metrics_prefix)stnt_memory{%(filters)s}) +
            (%(metrics_prefix)stnt_memory_virt{%(filters)s})
          |||,
          {
            metrics_prefix: cfg.metrics_prefix,
            filters: common.prometheus_query_filters(cfg.filters),
          }
        ),
        legendFormat='{{alias}}',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT SUM("value")
          FROM %(measurement_with_policy)s
          WHERE (("metric_name" = '%(tnt_memory)s' OR "metric_name" = '%(tnt_memory_virt)s') AND %(filters)s)
          AND $timeFilter
          GROUP BY time($__interval), "label_pairs_alias" fill(none)
        |||, {
          measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
            policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
            measurement: cfg.measurement,
          }),
          tnt_memory: cfg.metrics_prefix + 'tnt_memory',
          tnt_memory_virt: cfg.metrics_prefix + 'tnt_memory_virt',
          filters: common.influxdb_query_filters(cfg.filters),
        }),
        alias='$tag_label_pairs_alias',
      )
  ),

  resident_memory_per_instance(
    cfg,
    title='Resident memory per instance',
    description=|||
      Resident memory used by Tarantool instance.

      Panel minimal requirements: metrics 1.6.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_memory')
  ),

  virtual_memory_per_instance(
    cfg,
    title='Virtual memory per instance',
    description=|||
      Virtual memory used by Tarantool instance.

      Panel minimal requirements: metrics 1.6.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_memory_virt')
  ),


  total_memory(
    cfg,
    title='Total memory per cluster',
    description=|||
      Total memory used by Tarantool.

      Panel minimal requirements: metrics 1.6.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          '%s + %s',
          [
            aggregate_expr(cfg, 'tnt_memory'),
            aggregate_expr(cfg, 'tnt_memory_virt'),
          ]
        ),
        legendFormat=title,
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT SUM("value")
          FROM %(measurement_with_policy)s
          WHERE (("metric_name" = '%(metric_memory)s' OR "metric_name" = '%(metric_memory_virt)s') AND %(filters)s)
          AND $timeFilter
          GROUP BY time($__interval) fill(previous)
        |||, {
          measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
            policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
            measurement: cfg.measurement,
          }),
          metric_memory: cfg.metrics_prefix + 'tnt_memory',
          metric_memory_virt: cfg.metrics_prefix + 'tnt_memory_virt',
          filters: if common.influxdb_query_filters(common.remove_field(cfg.filters, 'label_pairs_alias')) != ''
          then common.influxdb_query_filters(common.remove_field(cfg.filters, 'label_pairs_alias'))
          else 'true',
        }),
        alias=title,
      )
  ),

  total_resident_memory(
    cfg,
    title='Total resident memory per cluster',
    description=|||
      Resident memory used by Tarantool instance.

      Panel minimal requirements: metrics 1.6.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(expr=aggregate_expr(cfg, 'tnt_memory'), legendFormat=title)
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT SUM("value")
          FROM %(measurement_with_policy)s
          WHERE "metric_name" = '%(metric_memory)s' AND %(filters)s
          AND $timeFilter
          GROUP BY time($__interval) fill(previous)
        |||, {
          measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
            policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
            measurement: cfg.measurement,
          }),
          metric_memory: cfg.metrics_prefix + 'tnt_memory',
          filters: common.influxdb_query_filters(common.remove_field(cfg.filters, 'alias')),
        }),
        alias=title,
      )
  ),

  total_virtual_memory(
    cfg,
    title='Total virtual memory per cluster',
    description=|||
      Virtual memory used by Tarantool instance.

      Panel minimal requirements: metrics 1.6.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(expr=aggregate_expr(cfg, 'tnt_memory_virt'), legendFormat=title)
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT SUM("value")
          FROM %(measurement_with_policy)s
          WHERE "metric_name" = '%(metric_memory_virt)s' AND %(filters)s
          AND $timeFilter
          GROUP BY time($__interval) fill(previous)
        |||, {
          measurement_with_policy: std.format('%(policy_prefix)s"%(measurement)s"', {
            policy_prefix: if cfg.policy == 'default' then '' else std.format('"%(policy)s".', cfg.policy),
            measurement: cfg.measurement,
          }),
          metric_memory_virt: cfg.metrics_prefix + 'tnt_memory_virt',
          filters: common.influxdb_query_filters(common.remove_field(cfg.filters, 'alias')),
        }),
        alias=title,
      )
  ),

  lua_memory(
    cfg,
    title='Lua memory',
    description=|||
      Memory used for objects allocated with Lua
      by using its internal mechanisms.
      Lua memory is bounded by 2 GB per instance.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_info_memory_lua')
  ),

  runtime_memory(
    cfg,
    title='Runtime arena memory',
    description=|||
      Memory used by runtime arena.
      Runtime arena stores network buffers, tuples
      created with box.tuple.new and other objects
      allocated by application not covered by basic
      Lua mechanisms (spaces data and indexes
      are not included here, see memtx/vinyl arena).
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_runtime_used')
  ),

  memory_tx(
    cfg,
    title='Transactions memory',
    description=|||
      Memory in use by active transactions.
      For the vinyl storage engine, this is the total size of
      all allocated objects (struct txv, struct vy_tx, struct vy_read_interval)
      and tuples pinned for those objects. 
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_info_memory_tx')
  ),

  fiber_count(
    cfg,
    title='Number of fibers',
    description=|||
      Current number of fibers in tx thread.

      Panel minimal requirements: metrics 0.13.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    legend_avg=false,
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_fiber_amount', converter='last')
  ),

  fiber_csw(
    cfg,
    title='Fiber context switches',
    description=|||
      Number of fiber context switches.
      Context switches are counted over all current fibers.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='switches',
    panel_width=12,
  ).addTarget(
    common.target(cfg, 'tnt_fiber_csw')
  ),

  local fiber_memory(
    cfg,
    title,
    description,
    metric_name,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, metric_name)
  ),

  fiber_memused(
    cfg,
    title='Memory used by fibers',
    description=|||
      Amount of memory used by current fibers.
    |||,
  ):: fiber_memory(
    cfg,
    title,
    description,
    'tnt_fiber_memused'
  ),

  fiber_memalloc(
    cfg,
    title='Memory reserved for fibers',
    description=|||
      Amount of memory reserved for current fibers.
    |||,
  ):: fiber_memory(
    cfg,
    title,
    description,
    'tnt_fiber_memalloc'
  ),

  event_loop_time(
    cfg,
    title='Event loop time',
    description=|||
      Duration of last event loop iteration (tx thread).
      High duration results in longer responses,
      possible bad health signals and may be the
      reason of "Too long WAL write" errors.

      Panel minimal requirements: metrics 0.13.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='cycle duration',
    format='ms',
    panel_width=12,
  ).addTarget(
    common.target(cfg, 'tnt_ev_loop_time', converter='last')
  ),
}
