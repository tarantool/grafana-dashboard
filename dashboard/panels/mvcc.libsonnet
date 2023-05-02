local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local utils = import 'dashboard/utils.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool MVCC overview'),

  local mvcc_warning(description) = std.join(
    '\n',
    [description, |||
      Panel works with metrics 0.15.1 or newer, Tarantool 2.10 or newer.
    |||]
  ),

  local mvcc_target(
    datasource_type,
    metric_name,
    job,
    policy,
    measurement,
    alias,
    kind,
    labels,
  ) = (
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s",kind="%s",%s}', [metric_name, job, alias, kind, utils.generate_labels_string(labels)]),
        legendFormat='{{alias}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias'],
        alias='$tag_label_pairs_alias',
        fill='null',
      ).where('metric_name', '=', metric_name).where('label_pairs_alias', '=~', alias)
      .where('label_pairs_kind', '=', kind).selectField('value').addConverter('last')
  ),

  local txn_statements_desc(description) = std.join(
    '\n',
    [|||
      Each operation like `space:replace{}` turns into ``statement``
      for the current transaction.
    |||, description]
  ),

  memtx_tnx_statements_total(
    title='Transaction statements size (total)',
    description=mvcc_warning(txn_statements_desc(|||
      Graph shows the number of bytes that are allocated
      for the statements of all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_statements',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_tnx_statements_average(
    title='Transaction statements size (average)',
    description=mvcc_warning(txn_statements_desc(|||
      Graph shows average bytes used by transactions for statements
      (`txn.statements.total` bytes / number of open transactions).
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_statements',
    job,
    policy,
    measurement,
    alias,
    'average',
    labels,
  )),

  memtx_tnx_statements_max(
    title='Transaction statements size (max)',
    description=mvcc_warning(txn_statements_desc(|||
      Graph shows the maximum number of bytes used by one
      the current transaction for statements.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_statements',
    job,
    policy,
    measurement,
    alias,
    'max',
    labels,
  )),

  local txn_user_desc(description) = std.join(
    '\n',
    [|||
      User may allocate memory for the current transaction with
      Tarantool C APIfunction `box_txn_alloc()`.
    |||, description]
  ),

  memtx_tnx_user_total(
    title='Transaction user size (total)',
    description=mvcc_warning(txn_user_desc(|||
      Graph shows memory allocated for all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_user',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_tnx_user_average(
    title='Transaction user size (average)',
    description=mvcc_warning(txn_user_desc(|||
      Graph shows transaction average
      (total allocated bytes / number of all current transactions).
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_user',
    job,
    policy,
    measurement,
    alias,
    'average',
    labels,
  )),

  memtx_tnx_user_max(
    title='Transaction user size (max)',
    description=mvcc_warning(txn_user_desc(|||
      Graph shows the maximum number of bytes allocated over all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_user',
    job,
    policy,
    measurement,
    alias,
    'max',
    labels,
  )),

  local txn_system_desc(description) = std.join(
    '\n',
    [|||
      System may store utility things like logs and savepoints
      for each transaction.
    |||, description]
  ),

  memtx_tnx_system_total(
    title='Transaction system size (total)',
    description=mvcc_warning(txn_system_desc(|||
      Graph shows memory allocated for all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_system',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_tnx_system_average(
    title='Transaction system size (average)',
    description=mvcc_warning(txn_system_desc(|||
      Graph shows transaction average
      (total allocated bytes / number of all current transactions).
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_system',
    job,
    policy,
    measurement,
    alias,
    'average',
    labels,
  )),

  memtx_tnx_system_max(
    title='Transaction system size (max)',
    description=mvcc_warning(txn_system_desc(|||
      Graph shows the maximum number of bytes allocated over all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_tnx_system',
    job,
    policy,
    measurement,
    alias,
    'max',
    labels,
  )),

  local mvcc_trackers_desc(description) = std.join(
    '\n',
    [|||
      Tarantool allocates memory for trackers
      that keep track of transaction reads.
    |||, description]
  ),

  memtx_mvcc_trackers_total(
    title='Trackers size (total)',
    description=mvcc_warning(mvcc_trackers_desc(|||
      Graph shows memory allocated for trackers of all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_trackers',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_trackers_average(
    title='Trackers size (average)',
    description=mvcc_warning(mvcc_trackers_desc(|||
      Graph shows transaction tracker average
      (total allocated bytes / number of all current transactions).
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_trackers',
    job,
    policy,
    measurement,
    alias,
    'average',
    labels,
  )),

  memtx_mvcc_trackers_max(
    title='Trackers size (max)',
    description=mvcc_warning(mvcc_trackers_desc(|||
      Graph shows the maximum number of bytes allocated for a tracker
      over all current transactions.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_trackers',
    job,
    policy,
    measurement,
    alias,
    'max',
    labels,
  )),

  local mvcc_conflicts_desc(description) = std.join(
    '\n',
    [|||
      Tarantool allocates memory in case of conflicts.
    |||, description]
  ),

  memtx_mvcc_conflicts_total(
    title='Conflicts size (total)',
    description=mvcc_warning(mvcc_conflicts_desc(|||
      Graph shows memory allocated for all current conflicts.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_conflicts',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_conflicts_average(
    title='Conflicts size (average)',
    description=mvcc_warning(mvcc_conflicts_desc(|||
      Graph shows transaction conflict average
      (total allocated bytes / number of all current conflict).
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_conflicts',
    job,
    policy,
    measurement,
    alias,
    'average',
    labels,
  )),

  memtx_mvcc_conflicts_max(
    title='Conflicts size (max)',
    description=mvcc_warning(mvcc_conflicts_desc(|||
      Graph shows the maximum number of bytes allocated for a transaction conflict.
    |||)),
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
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_conflicts',
    job,
    policy,
    measurement,
    alias,
    'max',
    labels,
  )),

  local mvcc_retained_desc(description) = std.join(
    '\n',
    [|||
      Retained tuples are no longer in the index,
      but MVCC does not allow them to be removed.
    |||, description]
  ),

  local mvcc_stories_desc(description) = std.join(
    '\n',
    [|||
      MVCC is based on the tuple story mechanism.
    |||, description]
  ),

  local mvcc_used_desc(description) = std.join(
    '\n',
    [|||
      This graph shows tuples that are used by active read-write transactions.
    |||, description]
  ),

  local mvcc_read_view_desc(description) = std.join(
    '\n',
    [|||
      This graph shows tuples that are used by read-only transactions (i.e. in read view).
    |||, description]
  ),

  local mvcc_tracking_desc(description) = std.join(
    '\n',
    [|||
      This graph shows tuples that are not used by current transactions,
      but are used by MVCC to track reads.
    |||, description]
  ),

  local count_desc = 'Graph shows the number of tuples.',

  local total_desc = 'Graph shows total size of tuples.',

  memtx_mvcc_tuples_used_stories_count(
    title='Stories tuples used',
    description=mvcc_warning(mvcc_stories_desc(mvcc_used_desc(count_desc))),
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
    labelY1='tuples',
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_used_stories',
    job,
    policy,
    measurement,
    alias,
    'count',
    labels,
  )),

  memtx_mvcc_tuples_used_stories_total(
    title='Stories tuples used size',
    description=mvcc_warning(mvcc_stories_desc(mvcc_used_desc(total_desc))),
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
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_used_stories',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_tuples_used_retained_count(
    title='Retained tuples used',
    description=mvcc_warning(mvcc_retained_desc(mvcc_used_desc(count_desc))),
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
    labelY1='tuples',
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_used_retained',
    job,
    policy,
    measurement,
    alias,
    'count',
    labels,
  )),

  memtx_mvcc_tuples_used_retained_total(
    title='Retained tuples used size',
    description=mvcc_warning(mvcc_retained_desc(mvcc_used_desc(total_desc))),
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
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_used_retained',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_tuples_read_view_stories_count(
    title='Stories tuples in read views',
    description=mvcc_warning(mvcc_stories_desc(mvcc_read_view_desc(count_desc))),
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
    labelY1='tuples',
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_read_view_stories',
    job,
    policy,
    measurement,
    alias,
    'count',
    labels,
  )),

  memtx_mvcc_tuples_read_view_stories_total(
    title='Stories tuples in read views size',
    description=mvcc_warning(mvcc_stories_desc(mvcc_read_view_desc(total_desc))),
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
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_read_view_stories',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_tuples_read_view_retained_count(
    title='Retained tuples in read views',
    description=mvcc_warning(mvcc_retained_desc(mvcc_read_view_desc(count_desc))),
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
    labelY1='tuples',
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_read_view_retained',
    job,
    policy,
    measurement,
    alias,
    'count',
    labels,
  )),

  memtx_mvcc_tuples_read_view_retained_total(
    title='Retained tuples in read views size',
    description=mvcc_warning(mvcc_retained_desc(mvcc_read_view_desc(total_desc))),
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
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_read_view_retained',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_tuples_tracking_stories_count(
    title='Stories tuples tracked',
    description=mvcc_warning(mvcc_stories_desc(mvcc_tracking_desc(count_desc))),
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
    labelY1='tuples',
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_tracking_stories',
    job,
    policy,
    measurement,
    alias,
    'count',
    labels,
  )),

  memtx_mvcc_tuples_tracking_stories_total(
    title='Stories tuples tracked size',
    description=mvcc_warning(mvcc_stories_desc(mvcc_tracking_desc(total_desc))),
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
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_tracking_stories',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),

  memtx_mvcc_tuples_tracking_retained_count(
    title='Retained tuples tracked',
    description=mvcc_warning(mvcc_retained_desc(mvcc_tracking_desc(count_desc))),
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
    labelY1='tuples',
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_tracking_retained',
    job,
    policy,
    measurement,
    alias,
    'count',
    labels,
  )),

  memtx_mvcc_tuples_tracking_retained_total(
    title='Retained tuples tracked size',
    description=mvcc_warning(mvcc_retained_desc(mvcc_tracking_desc(total_desc))),
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
    panel_width=6,
  ).addTarget(mvcc_target(
    datasource_type,
    'tnt_memtx_mvcc_tuples_tracking_retained',
    job,
    policy,
    measurement,
    alias,
    'total',
    labels,
  )),
}
