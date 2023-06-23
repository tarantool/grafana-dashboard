local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('Tarantool memtx allocation overview'),

  monitor_info(
  ):: grafana.text.new(
    title='Slab allocator monitoring information',
    content=|||
      `quota_used_ratio` > 90%, `arena_used_ratio` > 90%, 50% < `items_used_ratio` < 90% – your memory is highly fragmented. See [docs](https://www.tarantool.io/en/doc/1.10/reference/reference_lua/box_slab/#lua-function.box.slab.info) for more info.

      `quota_used_ratio` > 90%, `arena_used_ratio` > 90%, `items_used_ratio` > 90% – you are running out of memory. You should consider increasing Tarantool’s memory limit (*box.cfg.memtx_memory*).
    |||,
  ) { gridPos: { w: 24, h: 3 } },

  local used_panel(
    cfg,
    title=null,
    description=null,
    metric_name=null,
    format=null,
    labelY1=null,
    max=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format=format,
    min=0,
    max=max,
    labelY1=labelY1,
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    common.target(cfg, metric_name)
  ),

  local used_ratio(
    cfg,
    title,
    description,
    metric_name,
  ) = used_panel(
    cfg,
    title,
    description,
    metric_name,
    format='percent',
    labelY1='used ratio',
    max=100
  ),

  quota_used_ratio(
    cfg,
    title='Used by slab allocator (quota_used_ratio)',
    description=|||
      `quota_used_ratio` = `quota_used` / `quota_size`.

      `quota_used` – used by slab allocator (for both tuple and index slabs).

      `quota_size` – memory limit for slab allocator (as configured in the *memtx_memory* parameter).
    |||,
  ):: used_ratio(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_quota_used_ratio',
  ),

  arena_used_ratio(
    cfg,
    title='Used for tuples and indexes (arena_used_ratio)',
    description=|||
      `arena_used_ratio` = `arena_used` / `arena_size`.

      `arena_used` – used for both tuples and indexes.

      `arena_size` – allocated for both tuples and indexes.
    |||,
  ):: used_ratio(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_arena_used_ratio',
  ),

  items_used_ratio(
    cfg,
    title='Used for tuples (items_used_ratio)',
    description=|||
      `items_used_ratio` = `items_used` / `items_size`.

      `items_used` – used only for tuples.

      `items_size` – allocated only for tuples.
    |||,
  ):: used_ratio(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_items_used_ratio',
  ),

  local used_memory(
    cfg,
    title,
    description,
    metric_name,
  ) = used_panel(
    cfg,
    title,
    description,
    metric_name,
    format='bytes',
    labelY1='in bytes',
  ),

  quota_used(
    cfg,
    title='Used by slab allocator (quota_used)',
    description=|||
      Memory used by slab allocator (for both tuple and index slabs).
    |||,
  ):: used_memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_quota_used',
  ),

  quota_size(
    cfg,
    title='Slab allocator memory limit (quota_size)',
    description=|||
      Memory limit for slab allocator (as configured in the *memtx_memory* parameter).
    |||,
  ):: used_memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_quota_size',
  ),

  arena_used(
    cfg,
    title='Used for tuples and indexes (arena_used)',
    description=|||
      Memory used for both tuples and indexes.
    |||,
  ):: used_memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_arena_used',
  ),

  arena_size(
    cfg,
    title='Allocated for tuples and indexes (arena_size)',
    description=|||
      Memory allocated for both tuples and indexes by slab allocator.
    |||,
  ):: used_memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_arena_size',
  ),

  items_used(
    cfg,
    title='Used for tuples (items_used)',
    description=|||
      Memory used for only tuples.
    |||,
  ):: used_memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_items_used',
  ),

  items_size(
    cfg,
    title='Allocated for tuples (items_size)',
    description=|||
      Memory allocated for only tuples by slab allocator.
    |||,
  ):: used_memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_slab_items_size',
  ),
}
