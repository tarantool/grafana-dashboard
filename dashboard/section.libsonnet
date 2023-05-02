local cluster = import 'dashboard/panels/cluster.libsonnet';
local cpu = import 'dashboard/panels/cpu.libsonnet';
local crud = import 'dashboard/panels/crud.libsonnet';
local expirationd = import 'dashboard/panels/expirationd.libsonnet';
local http = import 'dashboard/panels/http.libsonnet';
local luajit = import 'dashboard/panels/luajit.libsonnet';
local mvcc = import 'dashboard/panels/mvcc.libsonnet';
local net = import 'dashboard/panels/net.libsonnet';
local operations = import 'dashboard/panels/operations.libsonnet';
local replication = import 'dashboard/panels/replication.libsonnet';
local runtime = import 'dashboard/panels/runtime.libsonnet';
local slab = import 'dashboard/panels/slab.libsonnet';
local space = import 'dashboard/panels/space.libsonnet';
local vinyl = import 'dashboard/panels/vinyl.libsonnet';

local tdg_file_connectors = import 'dashboard/panels/tdg/file_connectors.libsonnet';
local tdg_graphql = import 'dashboard/panels/tdg/graphql.libsonnet';
local tdg_iproto = import 'dashboard/panels/tdg/iproto.libsonnet';
local tdg_kafka_brokers = import 'dashboard/panels/tdg/kafka/brokers.libsonnet';
local tdg_kafka_common = import 'dashboard/panels/tdg/kafka/common.libsonnet';
local tdg_kafka_consumer = import 'dashboard/panels/tdg/kafka/consumer.libsonnet';
local tdg_kafka_producer = import 'dashboard/panels/tdg/kafka/producer.libsonnet';
local tdg_kafka_topics = import 'dashboard/panels/tdg/kafka/topics.libsonnet';
local tdg_rest_api = import 'dashboard/panels/tdg/rest_api.libsonnet';
local tdg_tasks = import 'dashboard/panels/tdg/tasks.libsonnet';
local tdg_tuples = import 'dashboard/panels/tdg/tuples.libsonnet';

{
  cluster_influxdb(datasource_type, datasource, policy, measurement, alias):: [
    cluster.row,

    cluster.cartridge_warning_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.cartridge_critical_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.failovers_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.read_only_status(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.election_state(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.election_vote(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.election_leader(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),

    cluster.election_term(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      alias=alias,
    ),
  ],

  // Must be used only in the top of a dashboard, overall stat panels use complicated layout
  cluster_prometheus(datasource_type, datasource, job, alias, labels):: [
    cluster.row,

    cluster.health_overview_table(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 12, h: 8, x: 0, y: 1 } },

    cluster.health_overview_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 6, h: 3, x: 12, y: 1 } },

    cluster.memory_used_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 3, h: 3, x: 18, y: 1 } },

    cluster.memory_reserved_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 3, h: 3, x: 21, y: 1 } },

    cluster.http_rps_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 4, h: 5, x: 12, y: 4 } },

    cluster.net_rps_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 4, h: 5, x: 16, y: 4 } },

    cluster.space_ops_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
    ) { gridPos: { w: 4, h: 5, x: 20, y: 4 } },

    cluster.cartridge_warning_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.cartridge_critical_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.failovers_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.read_only_status(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.election_state(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.election_vote(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.election_leader(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cluster.election_term(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  replication(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    replication.row,

    replication.replication_status(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    replication.replication_lag(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    replication.clock_delta(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    replication.synchro_queue_owner(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    replication.synchro_queue_term(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    replication.synchro_queue_length(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    replication.synchro_queue_busy(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  http(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    http.row,

    http.rps_success(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    http.rps_error_4xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    http.rps_error_5xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    http.latency_success(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    http.latency_error_4xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    http.latency_error_5xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  net(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    net.row,

    net.net_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.bytes_received_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.bytes_sent_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.net_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.net_pending(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_progress_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_progress_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_queue_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_queue_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.connections_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.current_connections(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.bytes_sent_per_thread_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.bytes_received_per_thread_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.connections_per_thread_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.current_connections_per_thread(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.net_rps_per_thread(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_progress_per_thread_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_queue_per_thread_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.net_pending_per_thread(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_progress_current_per_thread(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    net.requests_in_queue_current_per_thread(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  slab(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    slab.row,

    slab.monitor_info(),

    slab.quota_used_ratio(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.arena_used_ratio(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.items_used_ratio(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.quota_used(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.arena_used(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.items_used(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.quota_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.arena_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    slab.items_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  mvcc(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    mvcc.row,

    mvcc.memtx_tnx_statements_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_statements_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_statements_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_user_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_user_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_user_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_system_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_system_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_tnx_system_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_trackers_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_trackers_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_trackers_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_conflicts_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_conflicts_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_conflicts_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_used_stories_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_used_stories_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_used_retained_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_used_retained_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_read_view_stories_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_read_view_stories_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_read_view_retained_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_read_view_retained_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_tracking_stories_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_tracking_stories_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_tracking_retained_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    mvcc.memtx_mvcc_tuples_tracking_retained_total(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  space(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    space.row,

    space.memtx_len(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    space.vinyl_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    space.space_bsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    space.space_index_bsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    space.space_total_bsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  vinyl(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    vinyl.row,

    vinyl.disk_data(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.index_data(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.tuples_cache_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.index_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.bloom_filter_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.regulator_dump_bandwidth(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.regulator_write_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.regulator_rate_limit(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.memory_level0(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.regulator_dump_watermark(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.regulator_blocked_writers(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.tx_commit_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.tx_rollback_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.tx_conflicts_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.tx_read_views(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.scheduler_tasks_inprogress(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.scheduler_tasks_failed_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.scheduler_dump_time_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    vinyl.scheduler_dump_count_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  cpu(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    cpu.row,

    cpu.getrusage_cpu_user_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cpu.getrusage_cpu_system_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  cpu_extended(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    cpu.row,

    cpu.getrusage_cpu_user_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cpu.getrusage_cpu_system_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cpu.procstat_thread_user_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    cpu.procstat_thread_system_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  runtime(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    runtime.row,

    runtime.lua_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.runtime_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.memory_tx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.fiber_csw(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.event_loop_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.fiber_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.fiber_memused(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    runtime.fiber_memalloc(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  luajit(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    luajit.row,

    luajit.snap_restores(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.jit_traces(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.jit_traces_aborts(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.machine_code_areas(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.strhash_hit(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.strhash_miss(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_steps_atomic(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_steps_sweepstring(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_steps_finalize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_steps_sweep(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_steps_propagate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_steps_pause(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.strings_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.tables_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.cdata_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.userdata_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_memory_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_memory_freed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    luajit.gc_memory_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  operations(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    operations.row,

    operations.space_select_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.space_insert_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.space_replace_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.space_upsert_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.space_update_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.space_delete_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.call_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.eval_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.auth_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.SQL_prepare_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.SQL_execute_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.txn_begin_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.txn_commit_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    operations.txn_rollback_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  crud(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    crud.row,

    crud.select_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.select_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.select_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.select_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.tuples_fetched_panel(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.tuples_lookup_panel(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.map_reduces(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_many_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_many_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_many_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.insert_many_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_many_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_many_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_many_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.replace_many_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_many_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_many_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_many_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.upsert_many_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.update_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.update_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.update_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.update_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.delete_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.delete_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.delete_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.delete_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.count_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.count_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.count_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.count_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.get_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.get_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.get_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.get_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.borders_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.borders_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.borders_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.borders_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.len_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.len_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.len_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.len_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.truncate_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.truncate_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.truncate_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    crud.truncate_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  expirationd(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    expirationd.row,

    expirationd.tuples_checked(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    expirationd.tuples_expired(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    expirationd.restarts(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    expirationd.operation_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  tdg_kafka_common(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_kafka_common.row,

    tdg_kafka_common.queue_operations(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.message_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.message_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.requests(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.request_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.responses(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.response_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.messages_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.message_bytes_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.messages_received(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_common.message_bytes_received(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  tdg_kafka_brokers(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_kafka_brokers.row,

    tdg_kafka_brokers.stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.connects(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.disconnects(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.poll_wakeups(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.outbuf(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.outbuf_msg(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.waitresp(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.waitresp_msg(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.requests(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.request_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.request_errors(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.request_retries(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.request_idle(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.request_timeout(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.responses(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.response_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.response_errors(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.response_corriderrs(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.response_idle(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.response_partial(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.requests_by_type(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.internal_producer_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.internal_request_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.broker_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_brokers.broker_throttle(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  tdg_kafka_topics(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_kafka_topics.row,

    tdg_kafka_topics.age(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.metadata_age(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.topic_batchsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.topic_batchcnt(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_msgq(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_xmit_msgq(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_fetchq_msgq(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_msgq_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_xmit_msgq_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_fetchq_msgq_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_messages_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_message_bytes_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_messages_consumed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_message_bytes_consumed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_messages_dropped(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_topics.partition_messages_in_flight(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  tdg_kafka_consumer(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_kafka_consumer.row,

    tdg_kafka_consumer.stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_consumer.rebalance_age(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_consumer.rebalances(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),

    tdg_kafka_consumer.assignment_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      alias=alias,
    ),
  ],

  tdg_kafka_producer(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_kafka_producer.row,

    tdg_kafka_producer.idemp_stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_kafka_producer.txn_stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  tdg_tuples(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_tuples.row,

    tdg_tuples.tuples_scanned_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tuples.tuples_returned_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tuples.tuples_scanned_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tuples.tuples_returned_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  tdg_file_connectors(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_file_connectors.row,

    tdg_file_connectors.files_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_file_connectors.objects_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_file_connectors.files_process_errors(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_file_connectors.file_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_file_connectors.current_bytes_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_file_connectors.current_objects_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  tdg_graphql(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_graphql.row,

    tdg_graphql.query_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_graphql.query_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_graphql.query_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_graphql.mutation_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_graphql.mutation_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_graphql.mutation_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  tdg_iproto(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_iproto.row,

    tdg_iproto.put_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.put_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.put_batch_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.put_batch_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.find_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.find_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.update_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.update_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.get_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.get_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.delete_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.delete_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.count_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.count_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.map_reduce_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.map_reduce_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.call_on_storage_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_iproto.call_on_storage_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  tdg_rest_api(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_rest_api.row,

    tdg_rest_api.read_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.read_error_4xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.read_error_5xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.read_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.read_error_4xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.read_error_5xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.write_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.write_error_4xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.write_error_5xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.write_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.write_error_4xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_rest_api.write_error_5xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],

  tdg_tasks(datasource_type, datasource, policy=null, measurement=null, job=null, alias=null, labels=null):: [
    tdg_tasks.row,

    tdg_tasks.jobs_started(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.jobs_failed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.jobs_succeeded(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.jobs_running(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.jobs_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.tasks_started(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.tasks_failed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.tasks_succeeded(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.tasks_stopped(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.tasks_running(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.tasks_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.system_tasks_started(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.system_tasks_failed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.system_tasks_succeeded(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.system_tasks_running(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),

    tdg_tasks.system_tasks_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      labels=labels,
      alias=alias,
    ),
  ],
}
