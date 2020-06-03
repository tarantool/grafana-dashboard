local grafana = import 'grafonnet/grafana.libsonnet';
local influxdb = import 'grafonnet/influxdb.libsonnet';

local text = grafana.text;
local graph = grafana.graphPanel;
local influxdb = grafana.influxdb;

{
  monitor_info(
  ):: text.new(
    title='Инструкции по мониторингу slab',
    content=|||
      `quota_used_ratio` > 90%, `arena_used_ratio` > 90%, 50% < `items_used_ratio` < 90% – высокая фрагментация памяти.

      `quota_used_ratio` > 90%, `arena_used_ratio` > 90%, `items_used_ratio` > 90% – заканчиваются резервы памяти, необходимо увеличить параметр *memtx_memory*.
    |||,
  ),

  local used_ratio(
    title,
    description,
    datasource,
  ) = graph.new(
    title=title,
    description=description,
    datasource=datasource,

    format='percent',
    labelY1='used ratio',
    fill=0,
    decimals=2,
    legend_alignAsTable=true,
    legend_current=true,
    legend_values=true,
    legend_sortDesc=true
  ),

  quota_used_ratio(
    title='Выделено памяти для распределения slab (quota_used_ratio)',
    description=|||
      `quota_used_ratio` – отношение `quota_used` к `quota_size`.

      `quota_used` – это объем памяти, уже выделенный для распределения slab.

      `quota_size` – максимальный объем памяти, который механизм распределения slab может использовать как для кортежей,
      так и для индексов (равно значению параметра *memtx_memory*).
    |||,

    datasource=null
  ):: used_ratio(
    title=title,
    description=description,
    datasource=datasource,
  ).addTarget(
    influxdb.target(
      measurement='$measurement'
    ).where('metric_name', '=', 'tnt_slab_quota_used_ratio').selectField('value').addConverter('mean')
  ),

  arena_used_ratio(
    title='Утилизация памяти, выделенной под кортежи и индексы (arena_used_ratio)',
    description=|||
      `arena_used_ratio` – отношение `arena_used` к `arena_size`.

      `arena_used` – это эффективный объем памяти, используемый для кортежей и индексов
      (не включая выделенные, но в данный момент свободные slab’ы).

      `arena_size` – это общий объем памяти, используемый для кортежей и индексов
      (включая выделенные, но в данный момент свободные slab’ы).
    |||,

    datasource=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource=datasource,
  ).addTarget(
    influxdb.target(
      measurement='$measurement'
    ).where('metric_name', '=', 'tnt_slab_arena_used_ratio').selectField('value').addConverter('mean')
  ),

  items_used_ratio(
    title='Утилизация памяти, выделенной под кортежи (items_used_ratio)',
    description=|||
      `items_used_ratio` – отношение `items_used` к `items_size`.

      `items_used` – это эффективный объем памяти (не включая выделенные, но в данный момент свободные slab’ы),
      который используется только для кортежей, а не для индексов.

      `items_size` – это общий объем памяти (включая выделенные, но в данный момент свободные slab’ы),
      который используется только для кортежей, а не для индексов.
    |||,

    datasource=null,
  ):: used_ratio(
    title=title,
    description=description,
    datasource=datasource,
  ).addTarget(
    influxdb.target(
      measurement='$measurement'
    ).where('metric_name', '=', 'tnt_slab_items_used_ratio').selectField('value').addConverter('mean')
  ),
}
