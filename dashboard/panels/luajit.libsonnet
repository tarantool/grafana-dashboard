local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('Tarantool LuaJit statistics'),

  local version_warning(description) =
    std.join('\n\n', [description, 'Panel works with `metrics >= 0.6.0` and `Tarantool >= 2.6`.']),

  local version_warning_renamed(description) =
    std.join('\n\n', [description, 'Panel works with `metrics >= 0.15.0` and `Tarantool >= 2.6`.']),

  snap_restores(
    cfg,
    title='Snap restores',
    description=|||
      Average number of snap restores (guard assertions
      leading to stopping trace executions) per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning_renamed(description),
    labelY1='restores per second',
    panel_width=6,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_jit_snap_restore_total')
  ),

  jit_traces(
    cfg,
    title='JIT traces written',
    description=|||
      Average number of new JIT traces per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning(description),
    labelY1='new per second',
    panel_width=6,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_jit_trace_num')
  ),

  jit_traces_aborts(
    cfg,
    title='JIT traces aborted',
    description=|||
      Average number of JIT trace aborts per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning_renamed(description),
    labelY1='aborts per second',
    panel_width=6,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_jit_trace_abort_total')
  ),

  machine_code_areas(
    cfg,
    title='Machine code areas',
    description=|||
      Total size of allocated machine code areas.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning(description),
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    common.default_metric_target(cfg, 'lj_jit_mcode_size')
  ),

  strhash_hit(
    cfg,
    title='Strings interned',
    description=|||
      Average number of strings being extracted from hash instead of allocating per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning_renamed(description),
    labelY1='interned per second',
    panel_width=12,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_strhash_hit_total')
  ),

  strhash_miss(
    cfg,
    title='Strings allocated',
    description=|||
      Average number of strings being allocated due to hash miss per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning_renamed(description),
    labelY1='allocated per second',
    panel_width=12,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_strhash_miss_total')
  ),

  local gc_steps(
    cfg,
    title,
    description,
    state,
  ) = common.default_graph(
    cfg,
    title=(if title != null then title else std.format('GC steps (%s)', state)),
    description=(
      if description != null then
        description
      else version_warning_renamed(std.format(|||
        Average count of incremental GC steps (%s state) per second.
      |||, state))
    ),
    labelY1='steps per second',
    panel_width=8,
  ).addTarget(
    common.default_rps_target(cfg, std.format('lj_gc_steps_%s_total', state))
  ),

  gc_steps_atomic(
    cfg,
    title=null,
    description=null,
  ):: gc_steps(
    cfg,
    title,
    description,
    'atomic'
  ),

  gc_steps_sweepstring(
    cfg,
    title=null,
    description=null,
  ):: gc_steps(
    cfg,
    title,
    description,
    'sweepstring'
  ),

  gc_steps_finalize(
    cfg,
    title=null,
    description=null,
  ):: gc_steps(
    cfg,
    title,
    description,
    'finalize'
  ),

  gc_steps_sweep(
    cfg,
    title=null,
    description=null,
  ):: gc_steps(
    cfg,
    title,
    description,
    'sweep'
  ),

  gc_steps_propagate(
    cfg,
    title=null,
    description=null,
  ):: gc_steps(
    cfg,
    title,
    description,
    'propagate'
  ),

  gc_steps_pause(
    cfg,
    title=null,
    description=null,
  ):: gc_steps(
    cfg,
    title,
    description,
    'pause'
  ),

  local allocated(
    cfg,
    title,
    description,
    metric_name
  ) = common.default_graph(
    cfg,
    title=title,
    description=version_warning(description),
    decimals=0,
    panel_width=6,
  ).addTarget(
    common.default_metric_target(cfg, metric_name)
  ),

  strings_allocated(
    cfg,
    title='String objects allocated',
    description=|||
      Number of allocated string objects.
    |||,
  ):: allocated(
    cfg,
    title,
    description,
    'lj_gc_strnum'
  ),

  tables_allocated(
    cfg,
    title='Table objects allocated',
    description=|||
      Number of allocated table objects.
    |||,
  ):: allocated(
    cfg,
    title,
    description,
    'lj_gc_tabnum'
  ),

  cdata_allocated(
    cfg,
    title='cdata objects allocated',
    description=|||
      Number of allocated cdata objects.
    |||,
  ):: allocated(
    cfg,
    title,
    description,
    'lj_gc_cdatanum'
  ),

  userdata_allocated(
    cfg,
    title='userdata objects allocated',
    description=|||
      Number of allocated userdata objects.
    |||,
  ):: allocated(
    cfg,
    title,
    description,
    'lj_gc_udatanum'
  ),

  gc_memory_current(
    cfg,
    title='Current Lua memory',
    description=|||
      Current allocated Lua memory.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning(description),
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.default_metric_target(cfg, 'lj_gc_memory')
  ),

  gc_memory_freed(
    cfg,
    title='Freed Lua memory',
    description=|||
      Average amount of freed Lua memory per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning_renamed(description),
    format='bytes',
    labelY1='bytes per second',
    panel_width=8,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_gc_freed_total')
  ),

  gc_memory_allocated(
    cfg,
    title='Allocated Lua memory',
    description=|||
      Average amount of allocated Lua memory per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=version_warning_renamed(description),
    format='bytes',
    labelY1='bytes per second',
    panel_width=8,
  ).addTarget(
    common.default_rps_target(cfg, 'lj_gc_allocated_total')
  ),
}
