local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
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
    cfg,
    metric_name,
    kind
  ) = common.target(
    cfg,
    metric_name,
    additional_filters={
      [variable.datasource_type.prometheus]: { kind: ['=', kind] },
      [variable.datasource_type.influxdb]: { label_pairs_kind: ['=', kind] },
    },
    converter='last',
  ),

  local txn_statements_desc(description) = std.join(
    '\n',
    [|||
      Each operation like `space:replace{}` turns into ``statement``
      for the current transaction.
    |||, description]
  ),

  memtx_tnx_statements_total(
    cfg,
    title='Transaction statements size (total)',
    description=mvcc_warning(txn_statements_desc(|||
      Graph shows the number of bytes that are allocated
      for the statements of all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_statements', 'total')
  ),

  memtx_tnx_statements_average(
    cfg,
    title='Transaction statements size (average)',
    description=mvcc_warning(txn_statements_desc(|||
      Graph shows average bytes used by transactions for statements
      (`txn.statements.total` bytes / number of open transactions).
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_statements', 'average')
  ),

  memtx_tnx_statements_max(
    cfg,
    title='Transaction statements size (max)',
    description=mvcc_warning(txn_statements_desc(|||
      Graph shows the maximum number of bytes used by one
      the current transaction for statements.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_statements', 'max')
  ),

  local txn_user_desc(description) = std.join(
    '\n',
    [|||
      User may allocate memory for the current transaction with
      Tarantool C APIfunction `box_txn_alloc()`.
    |||, description]
  ),

  memtx_tnx_user_total(
    cfg,
    title='Transaction user size (total)',
    description=mvcc_warning(txn_user_desc(|||
      Graph shows memory allocated for all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_user', 'total')
  ),

  memtx_tnx_user_average(
    cfg,
    title='Transaction user size (average)',
    description=mvcc_warning(txn_user_desc(|||
      Graph shows transaction average
      (total allocated bytes / number of all current transactions).
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_user', 'average')
  ),

  memtx_tnx_user_max(
    cfg,
    title='Transaction user size (max)',
    description=mvcc_warning(txn_user_desc(|||
      Graph shows the maximum number of bytes allocated over all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_user', 'max')
  ),

  local txn_system_desc(description) = std.join(
    '\n',
    [|||
      System may store utility things like logs and savepoints
      for each transaction.
    |||, description]
  ),

  memtx_tnx_system_total(
    cfg,
    title='Transaction system size (total)',
    description=mvcc_warning(txn_system_desc(|||
      Graph shows memory allocated for all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_system', 'total')
  ),

  memtx_tnx_system_average(
    cfg,
    title='Transaction system size (average)',
    description=mvcc_warning(txn_system_desc(|||
      Graph shows transaction average
      (total allocated bytes / number of all current transactions).
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_system', 'average')
  ),

  memtx_tnx_system_max(
    cfg,
    title='Transaction system size (max)',
    description=mvcc_warning(txn_system_desc(|||
      Graph shows the maximum number of bytes allocated over all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_tnx_system', 'max')
  ),

  local mvcc_trackers_desc(description) = std.join(
    '\n',
    [|||
      Tarantool allocates memory for trackers
      that keep track of transaction reads.
    |||, description]
  ),

  memtx_mvcc_trackers_total(
    cfg,
    title='Trackers size (total)',
    description=mvcc_warning(mvcc_trackers_desc(|||
      Graph shows memory allocated for trackers of all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_trackers', 'total')
  ),

  memtx_mvcc_trackers_average(
    cfg,
    title='Trackers size (average)',
    description=mvcc_warning(mvcc_trackers_desc(|||
      Graph shows transaction tracker average
      (total allocated bytes / number of all current transactions).
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_trackers', 'average')
  ),

  memtx_mvcc_trackers_max(
    cfg,
    title='Trackers size (max)',
    description=mvcc_warning(mvcc_trackers_desc(|||
      Graph shows the maximum number of bytes allocated for a tracker
      over all current transactions.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_trackers', 'max')
  ),

  local mvcc_conflicts_desc(description) = std.join(
    '\n',
    [|||
      Tarantool allocates memory in case of conflicts.
    |||, description]
  ),

  memtx_mvcc_conflicts_total(
    cfg,
    title='Conflicts size (total)',
    description=mvcc_warning(mvcc_conflicts_desc(|||
      Graph shows memory allocated for all current conflicts.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_conflicts', 'total')
  ),

  memtx_mvcc_conflicts_average(
    cfg,
    title='Conflicts size (average)',
    description=mvcc_warning(mvcc_conflicts_desc(|||
      Graph shows transaction conflict average
      (total allocated bytes / number of all current conflict).
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_conflicts', 'average')
  ),

  memtx_mvcc_conflicts_max(
    cfg,
    title='Conflicts size (max)',
    description=mvcc_warning(mvcc_conflicts_desc(|||
      Graph shows the maximum number of bytes allocated for a transaction conflict.
    |||)),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=8,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_conflicts', 'max')
  ),

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
    cfg,
    title='Stories tuples used',
    description=mvcc_warning(mvcc_stories_desc(mvcc_used_desc(count_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='tuples',
    decimals=0,
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_used_stories', 'count')
  ),

  memtx_mvcc_tuples_used_stories_total(
    cfg,
    title='Stories tuples used size',
    description=mvcc_warning(mvcc_stories_desc(mvcc_used_desc(total_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_used_stories', 'total')
  ),

  memtx_mvcc_tuples_used_retained_count(
    cfg,
    title='Retained tuples used',
    description=mvcc_warning(mvcc_retained_desc(mvcc_used_desc(count_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='tuples',
    decimals=0,
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_used_retained', 'count')
  ),

  memtx_mvcc_tuples_used_retained_total(
    cfg,
    title='Retained tuples used size',
    description=mvcc_warning(mvcc_retained_desc(mvcc_used_desc(total_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_used_retained', 'total')
  ),

  memtx_mvcc_tuples_read_view_stories_count(
    cfg,
    title='Stories tuples in read views',
    description=mvcc_warning(mvcc_stories_desc(mvcc_read_view_desc(count_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='tuples',
    decimals=0,
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_read_view_stories', 'count')
  ),

  memtx_mvcc_tuples_read_view_stories_total(
    cfg,
    title='Stories tuples in read views size',
    description=mvcc_warning(mvcc_stories_desc(mvcc_read_view_desc(total_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_read_view_stories', 'total')
  ),

  memtx_mvcc_tuples_read_view_retained_count(
    cfg,
    title='Retained tuples in read views',
    description=mvcc_warning(mvcc_retained_desc(mvcc_read_view_desc(count_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='tuples',
    decimals=0,
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_read_view_retained', 'count')
  ),

  memtx_mvcc_tuples_read_view_retained_total(
    cfg,
    title='Retained tuples in read views size',
    description=mvcc_warning(mvcc_retained_desc(mvcc_read_view_desc(total_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_read_view_retained', 'total')
  ),

  memtx_mvcc_tuples_tracking_stories_count(
    cfg,
    title='Stories tuples tracked',
    description=mvcc_warning(mvcc_stories_desc(mvcc_tracking_desc(count_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='tuples',
    decimals=0,
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_tracking_stories', 'count')
  ),

  memtx_mvcc_tuples_tracking_stories_total(
    cfg,
    title='Stories tuples tracked size',
    description=mvcc_warning(mvcc_stories_desc(mvcc_tracking_desc(total_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_tracking_stories', 'total')
  ),

  memtx_mvcc_tuples_tracking_retained_count(
    cfg,
    title='Retained tuples tracked',
    description=mvcc_warning(mvcc_retained_desc(mvcc_tracking_desc(count_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    labelY1='tuples',
    decimals=0,
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_tracking_retained', 'count')
  ),

  memtx_mvcc_tuples_tracking_retained_total(
    cfg,
    title='Retained tuples tracked size',
    description=mvcc_warning(mvcc_retained_desc(mvcc_tracking_desc(total_desc))),
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    labelY1='in bytes',
    panel_width=6,
  ).addTarget(
    mvcc_target(cfg, 'tnt_memtx_mvcc_tuples_tracking_retained', 'total')
  ),
}
