local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('Tarantool runtime overview'),

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

      Panel works with `metrics >= 0.13.0`.
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

      Panel works with `metrics >= 0.13.0`.
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
