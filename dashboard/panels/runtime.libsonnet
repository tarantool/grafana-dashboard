local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('Tarantool runtime overview'),

  lua_memory(
    title='Lua memory',
    description=|||
      Memory used for objects allocated with Lua
      by using its internal mechanisms.
      Lua memory is bounded by 2 GB per instance. 
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_info_memory_lua',
    job,
    policy,
    measurement,
    alias,
  )),

  runtime_memory(
    title='Runtime arena memory',
    description=|||
      Memory used by runtime arena.
      Runtime arena stores network buffers, tuples
      created with box.tuple.new and other objects
      allocated by application not covered by basic
      Lua mechanisms (spaces data and indexes
      are not included here, see memtx/vinyl arena).
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_runtime_used',
    job,
    policy,
    measurement,
    alias,
  )),

  memory_tx(
    title='Transactions memory',
    description=|||
      Memory in use by active transactions.
      For the vinyl storage engine, this is the total size of
      all allocated objects (struct txv, struct vy_tx, struct vy_read_interval)
      and tuples pinned for those objects. 
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_info_memory_tx',
    job,
    policy,
    measurement,
    alias,
  )),

  fiber_count(
    title='Number of fibers',
    description=|||
      Current number of fibers in tx thread. 

      Panel works with `metrics >= 0.13.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    legend_avg=false,
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_fiber_amount',
    job,
    policy,
    measurement,
    alias,
    'last'
  )),

  fiber_csw(
    title='Fiber context switches',
    description=|||
      Number of fiber context switches.
      Context switches are counted over all current fibers.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='switches',
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_fiber_csw',
    job,
    policy,
    measurement,
    alias,
  )),

  local fiber_memory(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
  )),

  fiber_memused(
    title='Memory used by fibers',
    description=|||
      Amount of memory used by current fibers.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: fiber_memory(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    'tnt_fiber_memused'
  ),

  fiber_memalloc(
    title='Memory reserved for fibers',
    description=|||
      Amount of memory reserved for current fibers.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: fiber_memory(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    'tnt_fiber_memalloc'
  ),

  event_loop_time(
    title='Event loop time',
    description=|||
      Duration of last event loop iteration (tx thread).
      High duration results in longer responses,
      possible bad health signals and may be the
      reason of "Too long WAL write" errors.

      Panel works with `metrics >= 0.13.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    labelY1='cycle duration',
    decimals=2,
    decimalsY1=2,
    format='ms',
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_ev_loop_time',
    job,
    policy,
    measurement,
    alias,
    converter='last'
  )),
}
