local grafana = import 'grafonnet/grafana.libsonnet';

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
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name=null,
    format=null,
    labelY1=null,
    max=null,
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format=format,
    min=0,
    max=max,
    labelY1=labelY1,
    legend_avg=false,
    legend_max=false,
  ).addTarget(common.default_metric_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  local used_ratio(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    labels,
  ) = used_panel(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    format='percent',
    labelY1='used ratio',
    max=100,
    labels=labels,
  ),

  quota_used_ratio(
    title='Used by slab allocator (quota_used_ratio)',
    description=|||
      `quota_used_ratio` = `quota_used` / `quota_size`.

      `quota_used` – used by slab allocator (for both tuple and index slabs).

      `quota_size` – memory limit for slab allocator (as configured in the *memtx_memory* parameter).
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_quota_used_ratio',
    labels=labels,
  ),

  arena_used_ratio(
    title='Used for tuples and indexes (arena_used_ratio)',
    description=|||
      `arena_used_ratio` = `arena_used` / `arena_size`.

      `arena_used` – used for both tuples and indexes.

      `arena_size` – allocated for both tuples and indexes.
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_arena_used_ratio',
    labels=labels,
  ),

  items_used_ratio(
    title='Used for tuples (items_used_ratio)',
    description=|||
      `items_used_ratio` = `items_used` / `items_size`.

      `items_used` – used only for tuples.

      `items_size` – allocated only for tuples.
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_items_used_ratio',
    labels=labels,
  ),

  local used_memory(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    labels,
  ) = used_panel(
    title,
    description,
    datasource_type,
    datasource,
    policy,
    measurement,
    job,
    alias,
    metric_name,
    format='bytes',
    labelY1='in bytes',
    labels=labels,
  ),

  quota_used(
    title='Used by slab allocator (quota_used)',
    description=|||
      Memory used by slab allocator (for both tuple and index slabs).
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_quota_used',
    labels=labels,
  ),

  quota_size(
    title='Slab allocator memory limit (quota_size)',
    description=|||
      Memory limit for slab allocator (as configured in the *memtx_memory* parameter).
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_quota_size',
    labels=labels,
  ),

  arena_used(
    title='Used for tuples and indexes (arena_used)',
    description=|||
      Memory used for both tuples and indexes.
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_arena_used',
    labels=labels,
  ),

  arena_size(
    title='Allocated for tuples and indexes (arena_size)',
    description=|||
      Memory allocated for both tuples and indexes by slab allocator.
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_arena_size',
    labels=labels,
  ),

  items_used(
    title='Used for tuples (items_used)',
    description=|||
      Memory used for only tuples.
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_items_used',
    labels=labels,
  ),

  items_size(
    title='Allocated for tuples (items_size)',
    description=|||
      Memory allocated for only tuples by slab allocator.
    |||,

    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_slab_items_size',
    labels=labels,
  ),
}
