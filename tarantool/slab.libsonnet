local grafana = import 'grafonnet/grafana.libsonnet';
local influxdb = import 'grafonnet/influxdb.libsonnet';

local text = grafana.text;
local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;

{
  monitor_info(
  ):: text.new(
    title='Slab allocator monitoring information',
    content=|||
      `quota_used_ratio` > 90%, `arena_used_ratio` > 90%, 50% < `items_used_ratio` < 90% – your memory is highly fragmented. See [docs](https://www.tarantool.io/en/doc/1.10/reference/reference_lua/box_slab/#lua-function.box.slab.info) for more info.

      `quota_used_ratio` > 90%, `arena_used_ratio` > 90%, `items_used_ratio` > 90% – you are running out of memory. You should consider increasing Tarantool’s memory limit (*box.cfg.memtx_memory*).
    |||,
  ),

  local used_panel(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
    format,
    labelY1
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format=format,
    labelY1=labelY1,
    fill=0,
    decimals=2,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_current=true,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ).addTarget(
    influxdb.target(
      policy=policy,
      measurement=measurement,
      group_tags=['label_pairs_alias'],
      alias='$tag_label_pairs_alias',
    ).where('metric_name', '=', metric_name).selectField('value').addConverter('mean')
  ),

  local used_ratio(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
  ) = used_panel(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
    format='percent',
    labelY1='used ratio'
  ),

  quota_used_ratio(
    title='Used by slab allocator (quota_used_ratio)',
    description=|||
      `quota_used_ratio` = `quota_used` / `quota_size`.

      `quota_used` – used by slab allocator (for both tuple and index slabs).

      `quota_size` – memory limit for slab allocator (as configured in the *memtx_memory* parameter).
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_quota_used_ratio',
  ),

  arena_used_ratio(
    title='Used for tuples and indexes (arena_used_ratio)',
    description=|||
      `arena_used_ratio` = `arena_used` / `arena_size`.

      `arena_used` – used for both tuples and indexes.

      `arena_size` – allocated for both tuples and indexes.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_arena_used_ratio',
  ),

  items_used_ratio(
    title='Used for tuples (items_used_ratio)',
    description=|||
      `items_used_ratio` = `items_used` / `items_size`.

      `items_used` – used only for tuples.

      `items_size` – allocated only for tuples.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_items_used_ratio',
  ),

  local used_memory(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
  ) = used_panel(
    title,
    description,
    datasource,
    policy,
    measurement,
    metric_name,
    format='bytes',
    labelY1='in bytes',
  ),

  quota_used(
    title='Used by slab allocator (quota_used)',
    description=|||
      Memory used by slab allocator (for both tuple and index slabs).
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_quota_used',
  ),

  quota_size(
    title='Slab allocator memory limit (quota_size)',
    description=|||
      Memory limit for slab allocator (as configured in the *memtx_memory* parameter).
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_quota_size',
  ),

  arena_used(
    title='Used for tuples and indexes (arena_used)',
    description=|||
      Memory used for both tuples and indexes.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_arena_used',
  ),

  arena_size(
    title='Allocated for tuples and indexes (arena_size)',
    description=|||
      Memory allocated for both tuples and indexes by slab allocator.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_arena_size',
  ),

  items_used(
    title='Used for tuples (items_used)',
    description=|||
      Memory used for only tuples.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_items_used',
  ),

  items_size(
    title='Allocated for tuples (items_size)',
    description=|||
      Memory allocated for only tuples by slab allocator.
    |||,

    datasource=null,
    policy=null,
    measurement=null,
  ):: used_memory(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    metric_name='tnt_slab_items_size',
  ),
}
