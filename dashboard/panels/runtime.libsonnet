local common = import 'common.libsonnet';

{
  row:: common.row('Tarantool runtime overview'),

  lua_memory(
    title='Lua runtime memory',
    description=|||
      Memory used for the Lua runtime.
      Lua memory is bounded by 2 GB per instance. 
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=24,
  ).addTarget(common.default_metric_target(
    datasource,
    'tnt_info_memory_lua',
    job,
    policy,
    measurement
  )),

  fiber_count(
    title='Number of fibers',
    description=|||
      Current number of fibers in tx thread. 
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    decimals=0,
    legend_avg=false,
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource,
    'tnt_fiber_count',
    job,
    policy,
    measurement,
    'last'
  )),

  fiber_csw_rps(
    title='Fiber context switches',
    description=|||
      Average rate of fiber context switches.
      Context switches are counted over all current fibers.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common.default_graph(
    title=title,
    description=common.rate_warning(description, datasource),
    datasource=datasource,
    labelY1='switches per second',
    panel_width=12,
  ).addTarget(common.default_rps_target(
    datasource,
    'tnt_fiber_csw',
    job,
    rate_time_range,
    policy,
    measurement
  )),

  local fiber_memory(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    metric_name,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource,
    metric_name,
    job,
    policy,
    measurement
  )),

  fiber_memused(
    title='Memory used by fibers',
    description=|||
      Amount of memory used by current fibers.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null
  ):: fiber_memory(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    'tnt_fiber_memused'
  ),

  fiber_memalloc(
    title='Memory reserved for fibers',
    description=|||
      Amount of memory reserved for current fibers.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null
  ):: fiber_memory(
    title,
    description,
    datasource,
    policy,
    measurement,
    job,
    'tnt_fiber_memalloc'
  ),
}
