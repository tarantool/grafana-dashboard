local common = import 'common.libsonnet';

{
  row:: common.row('Tarantool memory miscellaneous'),

  lua_memory(
    title='Lua runtime',
    description=|||
      Memory used for the Lua runtime. Lua memory is bounded by 2 GB per instance. 
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
}
