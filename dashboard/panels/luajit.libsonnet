local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('Tarantool LuaJit statistics'),

  local version_warning(description) =
    std.join('\n\n', [description, 'Panel works with `metrics >= 0.6.0` and `Tarantool >= 2.6`.']),

  local version_warning_renamed(description) =
    std.join('\n\n', [description, 'Panel works with `metrics >= 0.15.0` and `Tarantool >= 2.6`.']),

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
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=version_warning_renamed(description),
    datasource=datasource,
    labelY1='restores per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_jit_snap_restore_total',
    job,
    policy,
    measurement,
    alias,
    labels,
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
    alias=null,
    labels=null,
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
    measurement,
    alias,
    labels,
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
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=version_warning_renamed(description),
    datasource=datasource,
    labelY1='aborts per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_jit_trace_abort_total',
    job,
    policy,
    measurement,
    alias,
    labels,
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
    alias=null,
    labels=null,
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
    measurement,
    alias,
    labels=labels,
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
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=version_warning_renamed(description),
    datasource=datasource,
    labelY1='interned per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_strhash_hit_total',
    job,
    policy,
    measurement,
    alias,
    labels,
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
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=version_warning_renamed(description),
    datasource=datasource,
    labelY1='allocated per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_strhash_miss_total',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  local gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    state,
    labels,
  ) = common.default_graph(
    title=(if title != null then title else std.format('GC steps (%s)', state)),
    description=(
      if description != null then
        description
      else version_warning_renamed(std.format(|||
        Average count of incremental GC steps (%s state) per second.
      |||, state))
    ),
    datasource=datasource,
    labelY1='steps per second',
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    std.format('lj_gc_steps_%s_total', state),
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  gc_steps_atomic(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'atomic',
    labels,
  ),

  gc_steps_sweepstring(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'sweepstring',
    labels,
  ),

  gc_steps_finalize(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'finalize',
    labels,
  ),

  gc_steps_sweep(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'sweep',
    labels,
  ),

  gc_steps_propagate(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'propagate',
    labels,
  ),

  gc_steps_pause(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: gc_steps(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'pause',
    labels,
  ),

  local allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    metric_name,
    labels,
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
    measurement,
    alias,
    labels=labels,
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
    alias=null,
    labels=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'lj_gc_strnum',
    labels,
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
    alias=null,
    labels=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'lj_gc_tabnum',
    labels,
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
    alias=null,
    labels=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'lj_gc_cdatanum',
    labels,
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
    alias=null,
    labels=null,
  ):: allocated(
    title,
    description,
    datasource_type,
    datasource,
    job,
    policy,
    measurement,
    alias,
    'lj_gc_udatanum',
    labels,
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
    alias=null,
    labels=null,
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
    measurement,
    alias,
    labels=labels,
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
    alias=null,
    labels=null,
  ):: common.default_graph(
    title=title,
    description=version_warning_renamed(description),
    datasource=datasource,
    format='bytes',
    labelY1='bytes per second',
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_gc_freed_total',
    job,
    policy,
    measurement,
    alias,
    labels,
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
    alias=null,
    labels=null
  ):: common.default_graph(
    title=title,
    description=version_warning_renamed(description),
    datasource=datasource,
    format='bytes',
    labelY1='bytes per second',
    panel_width=8,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'lj_gc_allocated_total',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),
}
