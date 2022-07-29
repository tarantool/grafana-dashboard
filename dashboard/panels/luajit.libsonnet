local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('Tarantool LuaJit statistics'),

  local version_warning(description) =
    std.join('\n\n', [description, 'Panel works with `metrics >= 0.6.0` and `Tarantool >= 2.6`.']),

  snap_restores(
    title='Snap restores',
    description=|||
      Average number of snap restores (guard assertions
      leading to stopping trace executions) per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    labelY1='restores per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_jit_snap_restore',
    job,
    policy,
    measurement
  )),

  jit_traces(
    title='JIT traces written',
    description=|||
      Average number of new JIT traces per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    labelY1='new per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_jit_trace_num',
    job,
    policy,
    measurement
  )),

  jit_traces_aborts(
    title='JIT traces aborted',
    description=|||
      Average number of JIT trace aborts per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    labelY1='aborts per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_jit_trace_abort',
    job,
    policy,
    measurement
  )),

  machine_code_areas(
    title='Machine code areas',
    description=|||
      Total size of allocated machine code areas.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'lj_jit_mcode_size',
    job,
    policy,
    measurement
  )),

  strhash_hit(
    title='Strings interned',
    description=|||
      Average number of strings being extracted from hash instead of allocating per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    labelY1='interned per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_strhash_hit',
    job,
    policy,
    measurement
  )),

  strhash_miss(
    title='Strings allocated',
    description=|||
      Average number of strings being allocated due to hash miss per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    labelY1='allocated per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_strhash_miss',
    job,
    policy,
    measurement
  )),

  local gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    state
  ) = common.default_graph(
    title=(if title != null then title else std.format('GC steps (%s)', state)),
    description=(
      if description != null then
        description
      else version_warning(std.format(|||
        Average count of incremental GC steps (%s state) per second.
      |||, state))
    ),
    datasource=datasource,
    labelY1='steps per second',
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    std.format('lj_gc_steps_%s', state),
    job,
    policy,
    measurement
  )),

  gc_steps_atomic(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'atomic'
  ),

  gc_steps_sweepstring(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'sweepstring'
  ),

  gc_steps_finalize(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'finalize'
  ),

  gc_steps_sweep(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'sweep'
  ),

  gc_steps_propagate(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'propagate'
  ),

  gc_steps_pause(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'pause'
  ),

  local allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    metric_name
  ) = common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    decimals=0,
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement
  )),

  strings_allocated(
    title='String objects allocated',
    description=|||
      Number of allocated string objects.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'lj_gc_strnum'
  ),

  tables_allocated(
    title='Table objects allocated',
    description=|||
      Number of allocated table objects.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'lj_gc_tabnum'
  ),

  cdata_allocated(
    title='cdata objects allocated',
    description=|||
      Number of allocated cdata objects.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'lj_gc_cdatanum'
  ),

  userdata_allocated(
    title='userdata objects allocated',
    description=|||
      Number of allocated userdata objects.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    'lj_gc_udatanum'
  ),

  gc_memory_current(
    title='Current Lua memory',
    description=|||
      Current allocated Lua memory.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'lj_gc_memory',
    job,
    policy,
    measurement
  )),

  gc_memory_freed(
    title='Freed Lua memory',
    description=|||
      Average amount of freed Lua memory per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    format='bytes',
    labelY1='bytes per second',
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_gc_freed',
    job,
    policy,
    measurement
  )),

  gc_memory_allocated(
    title='Allocated Lua memory',
    description=|||
      Average amount of allocated Lua memory per second.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=version_warning(description),
    datasource=datasource,
    format='bytes',
    labelY1='bytes per second',
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_gc_allocated',
    job,
    policy,
    measurement
  )),
}
