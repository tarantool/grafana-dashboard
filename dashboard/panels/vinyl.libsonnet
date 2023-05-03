local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';

local utils = import 'dashboard/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool vinyl statistics'),

  local disk_size(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name=null,
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(common.default_metric_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  disk_data(
    title='Vinyl disk data',
    description=|||
      The amount of data stored in the `.run` files located in the `vinyl_dir` directory.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: disk_size(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_disk_data_size',
    labels=labels,
  ),

  index_data(
    title='Vinyl disk index',
    description=|||
      The amount of data stored in the `.index` files located in the `vinyl_dir` directory.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: disk_size(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_disk_index_size',
    labels=labels,
  ),

  tuples_cache_memory(
    title='Tuples cache memory',
    description=|||
      Amount of memory in bytes currently used to store tuples (data).

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_memory_tuple_cache',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  index_memory(
    title='Index memory',
    description=|||
      Amount of memory in bytes currently used to store indexes.
      If the metric value is close to box.cfg.vinyl_memory, this
      indicates that vinyl_page_size was chosen incorrectly.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_memory_page_index',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  bloom_filter_memory(
    title='Bloom filter memory',
    description=|||
      Amount of memory in bytes used by bloom filters.
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
    description=description,
    datasource=datasource,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_memory_bloom_filter',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  local regulator_bps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name=null,
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='Bps',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  regulator_dump_bandwidth(
    title='Vinyl regulator dump bandwidth',
    description=|||
      The estimated average rate of taking dumps, bytes per second.
      Initially, the rate value is 10 megabytes per second
      and being recalculated depending on the the actual rate.
      Only significant dumps that are larger than one megabyte
      are used for the estimate.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: regulator_bps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_regulator_dump_bandwidth',
    labels=labels,
  ),

  regulator_write_rate(
    title='Vinyl regulator write rate',
    description=|||
      The actual average rate of performing the write operations, bytes per second.
      The rate is calculated as a 5-second moving average.
      If the metric value is gradually going down, this can indicate some disk issues.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: regulator_bps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_regulator_write_rate',
    labels=labels,
  ),

  regulator_rate_limit(
    title='Vinyl regulator rate limit',
    description=|||
      The write rate limit, bytes per second.
      The regulator imposes the limit on transactions based on the observed dump/compaction performance.
      If the metric value is down to approximately 100 Kbps,
      this indicates issues with the disk or the scheduler.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: regulator_bps(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_regulator_rate_limit',
    labels=labels,
  ),

  memory_level0(
    title='Level 0 memory',
    description=|||
      «Level 0» (L0) memory area in bytes. L0 is the area that
      vinyl can use for in-memory storage of an LSM tree.
      By monitoring this metric, you can see when L0 is getting
      close to its maximum (tnt_vinyl_regulator_dump_watermark),
      at which time a dump will occur. You can expect L0 = 0
      immediately after the dump operation is completed.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_memory_level0',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  regulator_dump_watermark(
    title='Vinyl regulator dump watermark',
    description=|||
      The maximum amount of memory used for in-memory storing of a vinyl LSM tree.
      When accessing this maximum, the dumping must occur.
      For details, see https://www.tarantool.io/en/doc/latest/book/box/engines/#engines-algorithm-filling-lsm.
      The value is slightly smaller than the amount of memory allocated for vinyl trees,
      which is the `vinyl_memory` parameter.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    legend_max=false,
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_regulator_dump_watermark',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  regulator_blocked_writers(
    title='Vinyl regulator blocked writers',
    description=|||
      The number of fibers that are blocked waiting for Vinyl level0 memory quota.

      Panel works with `metrics >= 0.13.0` and `Tarantool >= 2.8.3`.
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
    description=description,
    datasource=datasource,
    legend_avg=false,
    legend_max=false,
    labelY1='fibers',
    panel_width=8,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_regulator_blocked_writers',
    job,
    policy,
    measurement,
    alias,
    labels=labels,
  )),

  local tx_rate(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name=null,
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='none',
    labelY1='transactions per second',
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  tx_commit_rate(
    title='Vinyl tx commit rate',
    description=|||
      Average per second rate of commits (successful transaction ends).
      It includes implicit commits: for example, any insert operation causes a commit
      unless it is within a `box.begin()`–`box.commit()` block.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: tx_rate(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_tx_commit',
    labels=labels,
  ),

  tx_rollback_rate(
    title='Vinyl tx rollback rate',
    description=|||
      Average per second rate of rollbacks (unsuccessful transaction ends).
      This is not merely a count of explicit `box.rollback()` requests — it includes requests
      that ended with errors.
      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: tx_rate(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_tx_rollback',
    labels=labels,
  ),

  tx_conflicts_rate(
    title='Vinyl tx conflict rate',
    description=|||
      Average per second rate of conflicts that caused transactions to roll back.
      The ratio `tx conflicts` / `tx commits` above 5% indicates that vinyl is not healthy.
      At this moment you’ll probably see a lot of other problems with vinyl.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: tx_rate(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_tx_conflict',
    labels=labels,
  ),

  tx_read_views(
    title='Vinyl read views',
    description=|||
      Number of current read views, that is, transactions entered a read-only state
      to avoid conflict temporarily.
      If the value stays non-zero for a long time, it indicates of a memory leak.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    decimals=0,
    labelY1='current',
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    'tnt_vinyl_tx_read_views',
    job,
    policy,
    measurement,
    alias,
    'last',
    labels=labels,
  )),

  local memory(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    metric_name=null,
    labels=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    panel_width=6,
  ).addTarget(common.default_metric_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    labels=labels
  )),

  memory_page_index(
    title='Vinyl index memory',
    description=|||
      The amount of memory that is being used for storing indexes.
      If the metric value is close to `vinyl_memory`,
      this indicates the incorrectly chosen `vinyl_page_size`.

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_memory_page_index',
    labels=labels,
  ),

  memory_bloom_filter(
    title='Vinyl bloom filter memory',
    description=|||
      The amount of memory used by bloom filters.
      See more here: https://www.tarantool.io/en/doc/latest/book/box/engines/#vinyl-lsm-disadvantages-compression-bloom-filters

      Panel works with `metrics >= 0.8.0`.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    alias=null,
    labels=null,
  ):: memory(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    alias=alias,
    metric_name='tnt_vinyl_memory_bloom_filter',
    labels=labels,
  ),

  scheduler_tasks_inprogress(
    title='Vinyl scheduler tasks in progress',
    description=|||
      The number of the scheduler dump/compaction tasks in progress now.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='none',
    legend_avg=false,
    panel_width=6,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_vinyl_scheduler_tasks{job=~"%s", alias=~"%s", status="inprogress"%s}',
                        [job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', 'tnt_vinyl_scheduler_tasks')
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_status', '=', 'inprogress')
      .selectField('value').addConverter('last')
  ),

  scheduler_tasks_failed_rate(
    title='Vinyl scheduler failed tasks rate',
    description=|||
      Scheduler dump/compaction tasks failed.
      Average per second rate is shown.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='none',
    labelY1='per second rate',
    legend_avg=false,
    panel_width=6,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(tnt_vinyl_scheduler_tasks{job=~"%s",alias=~"%s",status="failed"%s}[$__rate_interval])',
                        [job, alias, utils.labels_suffix(labels)]),
        legendFormat='{{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', 'tnt_vinyl_scheduler_tasks')
      .where('label_pairs_alias', '=~', alias)
      .where('label_pairs_status', '=', 'failed')
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  scheduler_dump_time_rate(
    title='Vinyl scheduler dump time rate',
    description=|||
      Time spent by all worker threads performing dumps.
      Average per second rate is shown.

      Panel works with `metrics >= 0.8.0`.
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
    description=description,
    datasource=datasource,
    format='s',
    labelY1='per second rate',
    decimalsY1=null,
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_vinyl_scheduler_dump_time',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),

  scheduler_dump_count_rate(
    title='Vinyl scheduler dump count rate',
    description=|||
      Scheduler dumps completed average per second rate.

      Panel works with `metrics >= 0.13.0`.
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
    description=description,
    datasource=datasource,
    format='none',
    labelY1='per second rate',
    decimalsY1=null,
    panel_width=6,
  ).addTarget(common.default_rps_target(
    datasource_type,
    'tnt_vinyl_scheduler_dump_total',
    job,
    policy,
    measurement,
    alias,
    labels,
  )),
}
