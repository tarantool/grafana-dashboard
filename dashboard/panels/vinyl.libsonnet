local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool vinyl statistics'),

  local disk_size(
    cfg,
    title=null,
    description=null,
    metric_name=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    common.target(cfg, metric_name)
  ),

  local vinyl_description_note(description) = std.join('\n', [description, |||
    Panel minimal requirements: metrics 0.8.0.
  |||]),

  disk_data(
    cfg,
    title='Vinyl disk data',
    description=vinyl_description_note(|||
      The amount of data stored in the `.run` files located in the `vinyl_dir` directory.
    |||),
  ):: disk_size(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_disk_data_size',
  ),

  index_data(
    cfg,
    title='Vinyl disk index',
    description=vinyl_description_note(|||
      The amount of data stored in the `.index` files located in the `vinyl_dir` directory.
    |||),
  ):: disk_size(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_disk_index_size',
  ),

  tuples_cache_memory(
    cfg,
    title='Tuples cache memory',
    description=vinyl_description_note(|||
      Amount of memory in bytes currently used to store tuples (data).
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_memory_tuple_cache')
  ),

  index_memory(
    cfg,
    title='Index memory',
    description=vinyl_description_note(|||
      Amount of memory in bytes currently used to store indexes.
      If the metric value is close to box.cfg.vinyl_memory, this
      indicates that vinyl_page_size was chosen incorrectly.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_memory_page_index')
  ),

  bloom_filter_memory(
    cfg,
    title='Bloom filter memory',
    description=vinyl_description_note(|||
      Amount of memory in bytes used by bloom filters.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_memory_bloom_filter')
  ),

  local regulator_bps(
    cfg,
    title=null,
    description=null,
    metric_name=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='Bps',
    panel_width=8,
  ).addTarget(
    common.target(cfg, metric_name)
  ),

  regulator_dump_bandwidth(
    cfg,
    title='Vinyl regulator dump bandwidth',
    description=vinyl_description_note(|||
      The estimated average rate of taking dumps, bytes per second.
      Initially, the rate value is 10 megabytes per second
      and being recalculated depending on the the actual rate.
      Only significant dumps that are larger than one megabyte
      are used for the estimate.
    |||),
  ):: regulator_bps(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_regulator_dump_bandwidth',
  ),

  regulator_write_rate(
    cfg,
    title='Vinyl regulator write rate',
    description=vinyl_description_note(|||
      The actual average rate of performing the write operations, bytes per second.
      The rate is calculated as a 5-second moving average.
      If the metric value is gradually going down, this can indicate some disk issues.
    |||),
  ):: regulator_bps(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_regulator_write_rate',
  ),

  regulator_rate_limit(
    cfg,
    title='Vinyl regulator rate limit',
    description=vinyl_description_note(|||
      The write rate limit, bytes per second.
      The regulator imposes the limit on transactions based on the observed dump/compaction performance.
      If the metric value is down to approximately 100 Kbps,
      this indicates issues with the disk or the scheduler.
    |||),
  ):: regulator_bps(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_regulator_rate_limit',
  ),

  memory_level0(
    cfg,
    title='Level 0 memory',
    description=vinyl_description_note(|||
      «Level 0» (L0) memory area in bytes. L0 is the area that
      vinyl can use for in-memory storage of an LSM tree.
      By monitoring this metric, you can see when L0 is getting
      close to its maximum (tnt_vinyl_regulator_dump_watermark),
      at which time a dump will occur. You can expect L0 = 0
      immediately after the dump operation is completed.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_memory_level0')
  ),

  regulator_dump_watermark(
    cfg,
    title='Vinyl regulator dump watermark',
    description=vinyl_description_note(|||
      The maximum amount of memory used for in-memory storing of a vinyl LSM tree.
      When accessing this maximum, the dumping must occur.
      For details, see https://www.tarantool.io/en/doc/latest/book/box/engines/#engines-algorithm-filling-lsm.
      The value is slightly smaller than the amount of memory allocated for vinyl trees,
      which is the `vinyl_memory` parameter.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_regulator_dump_watermark')
  ),

  regulator_blocked_writers(
    cfg,
    title='Vinyl regulator blocked writers',
    description=|||
      The number of fibers that are blocked waiting for Vinyl level0 memory quota.

      Panel minimal requirements: metrics 0.13.0, Tarantool 2.8.3.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    legend_avg=false,
    legend_max=false,
    labelY1='fibers',
    panel_width=8,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_regulator_blocked_writers')
  ),

  local tx_rate(
    cfg,
    title=null,
    description=null,
    metric_name=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='transactions per second',
    panel_width=6,
  ).addTarget(
    common.target(cfg, metric_name, rate=true)
  ),

  tx_commit_rate(
    cfg,
    title='Vinyl tx commit rate',
    description=vinyl_description_note(|||
      Average per second rate of commits (successful transaction ends).
      It includes implicit commits: for example, any insert operation causes a commit
      unless it is within a `box.begin()`–`box.commit()` block.
    |||),
  ):: tx_rate(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_tx_commit',
  ),

  tx_rollback_rate(
    cfg,
    title='Vinyl tx rollback rate',
    description=vinyl_description_note(|||
      Average per second rate of rollbacks (unsuccessful transaction ends).
      This is not merely a count of explicit `box.rollback()` requests — it includes requests
      that ended with errors.
    |||),
  ):: tx_rate(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_tx_rollback',
  ),

  tx_conflicts_rate(
    cfg,
    title='Vinyl tx conflict rate',
    description=vinyl_description_note(|||
      Average per second rate of conflicts that caused transactions to roll back.
      The ratio `tx conflicts` / `tx commits` above 5% indicates that vinyl is not healthy.
      At this moment you’ll probably see a lot of other problems with vinyl.
    |||),
  ):: tx_rate(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_tx_conflict',
  ),

  tx_read_views(
    cfg,
    title='Vinyl read views',
    description=vinyl_description_note(|||
      Number of current read views, that is, transactions entered a read-only state
      to avoid conflict temporarily.
      If the value stays non-zero for a long time, it indicates of a memory leak.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    labelY1='current',
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_tx_read_views', converter='last')
  ),

  local memory(
    cfg,
    title=null,
    description=null,
    metric_name=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    panel_width=6,
  ).addTarget(
    common.target(cfg, metric_name)
  ),

  memory_page_index(
    cfg,
    title='Vinyl index memory',
    description=vinyl_description_note(|||
      The amount of memory that is being used for storing indexes.
      If the metric value is close to `vinyl_memory`,
      this indicates the incorrectly chosen `vinyl_page_size`.
    |||),
  ):: memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_memory_page_index',
  ),

  memory_bloom_filter(
    cfg,
    title='Vinyl bloom filter memory',
    description=vinyl_description_note(|||
      The amount of memory used by bloom filters.
      See more here: https://www.tarantool.io/en/doc/latest/book/box/engines/#vinyl-lsm-disadvantages-compression-bloom-filters
    |||),
  ):: memory(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_memory_bloom_filter',
  ),

  scheduler_tasks_inprogress(
    cfg,
    title='Vinyl scheduler tasks in progress',
    description=vinyl_description_note(|||
      The number of the scheduler dump/compaction tasks in progress now.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    legend_avg=false,
    panel_width=6,
  ).addTarget(
    common.target(
      cfg,
      'tnt_vinyl_scheduler_tasks',
      additional_filters={
        [variable.datasource_type.prometheus]: { status: ['=', 'inprogress'] },
        [variable.datasource_type.influxdb]: { label_pairs_status: ['=', 'inprogress'] },
      },
      converter='last',
    ),
  ),

  scheduler_tasks_failed_rate(
    cfg,
    title='Vinyl scheduler failed tasks rate',
    description=vinyl_description_note(|||
      Scheduler dump/compaction tasks failed.
      Average per second rate is shown.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='per second rate',
    legend_avg=false,
    panel_width=6,
  ).addTarget(
    common.target(
      cfg,
      'tnt_vinyl_scheduler_tasks',
      additional_filters={
        [variable.datasource_type.prometheus]: { status: ['=', 'failed'] },
        [variable.datasource_type.influxdb]: { label_pairs_status: ['=', 'failed'] },
      },
      rate=true,
    ),
  ),

  scheduler_dump_time_rate(
    cfg,
    title='Vinyl scheduler dump time rate',
    description=vinyl_description_note(|||
      Time spent by all worker threads performing dumps.
      Average per second rate is shown.
    |||),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='s',
    labelY1='per second rate',
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_scheduler_dump_time', rate=true)
  ),

  scheduler_dump_count_rate(
    cfg,
    title='Vinyl scheduler dump count rate',
    description=|||
      Scheduler dumps completed average per second rate.

      Panel minimal requirements: metrics 0.13.0.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='per second rate',
    panel_width=6,
  ).addTarget(
    common.target(cfg, 'tnt_vinyl_scheduler_dump_total', rate=true)
  ),
}
