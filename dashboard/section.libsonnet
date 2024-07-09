local variable = import 'dashboard/variable.libsonnet';

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
local vinyl = import 'dashboard/panels/vinyl.libsonnet';

{
  cluster_tarantool3(cfg):: if cfg.type == variable.datasource_type.prometheus then [
    // Must be used only in the top of a dashboard, overall stat panels use complicated layout
    cluster.row,
    cluster.health_overview_table(cfg) { gridPos: { w: 12, h: 8, x: 0, y: 1 } },
    cluster.health_overview_stat(cfg) { gridPos: { w: 6, h: 3, x: 12, y: 1 } },
    cluster.memory_used_stat(cfg) { gridPos: { w: 3, h: 3, x: 18, y: 1 } },
    cluster.memory_reserved_stat(cfg) { gridPos: { w: 3, h: 3, x: 21, y: 1 } },
    cluster.http_rps_stat(cfg) { gridPos: { w: 4, h: 5, x: 12, y: 4 } },
    cluster.net_rps_stat(cfg) { gridPos: { w: 4, h: 5, x: 16, y: 4 } },
    cluster.space_ops_stat(cfg) { gridPos: { w: 4, h: 5, x: 20, y: 4 } },
    cluster.tarantool3_config_status(cfg),
    cluster.tarantool3_config_warning_alerts(cfg),
    cluster.tarantool3_config_error_alerts(cfg),
    cluster.read_only_status(cfg, panel_width=24),
    cluster.election_state(cfg),
    cluster.election_vote(cfg),
    cluster.election_leader(cfg),
    cluster.election_term(cfg),
  ] else if cfg.type == variable.datasource_type.influxdb then [
    cluster.row,
    cluster.tarantool3_config_status(cfg),
    cluster.tarantool3_config_warning_alerts(cfg),
    cluster.tarantool3_config_error_alerts(cfg),
    cluster.read_only_status(cfg, panel_width=24),
    cluster.election_state(cfg),
    cluster.election_vote(cfg),
    cluster.election_leader(cfg),
    cluster.election_term(cfg),
  ],

  cluster_cartridge(cfg):: if cfg.type == variable.datasource_type.prometheus then [
    // Must be used only in the top of a dashboard, overall stat panels use complicated layout
    cluster.row,
    cluster.health_overview_table(cfg) { gridPos: { w: 12, h: 8, x: 0, y: 1 } },
    cluster.health_overview_stat(cfg) { gridPos: { w: 6, h: 3, x: 12, y: 1 } },
    cluster.memory_used_stat(cfg) { gridPos: { w: 3, h: 3, x: 18, y: 1 } },
    cluster.memory_reserved_stat(cfg) { gridPos: { w: 3, h: 3, x: 21, y: 1 } },
    cluster.http_rps_stat(cfg) { gridPos: { w: 4, h: 5, x: 12, y: 4 } },
    cluster.net_rps_stat(cfg) { gridPos: { w: 4, h: 5, x: 16, y: 4 } },
    cluster.space_ops_stat(cfg) { gridPos: { w: 4, h: 5, x: 20, y: 4 } },
    cluster.cartridge_warning_issues(cfg),
    cluster.cartridge_critical_issues(cfg),
    cluster.failovers_per_second(cfg),
    cluster.read_only_status(cfg),
    cluster.election_state(cfg),
    cluster.election_vote(cfg),
    cluster.election_leader(cfg),
    cluster.election_term(cfg),
  ] else if cfg.type == variable.datasource_type.influxdb then [
    cluster.row,
    cluster.cartridge_warning_issues(cfg),
    cluster.cartridge_critical_issues(cfg),
    cluster.failovers_per_second(cfg),
    cluster.read_only_status(cfg),
    cluster.election_state(cfg),
    cluster.election_vote(cfg),
    cluster.election_leader(cfg),
    cluster.election_term(cfg),
  ],

  replication_tarantool3(cfg):: [
    replication.row,
    replication.replication_status(cfg, panel_width=12),
    replication.replication_lag(cfg, panel_width=12),
    replication.synchro_queue_owner(cfg),
    replication.synchro_queue_term(cfg),
    replication.synchro_queue_length(cfg),
    replication.synchro_queue_busy(cfg),
  ],

  replication_cartridge(cfg):: [
    replication.row,
    replication.replication_status(cfg),
    replication.replication_lag(cfg),
    replication.clock_delta(cfg),
    replication.synchro_queue_owner(cfg),
    replication.synchro_queue_term(cfg),
    replication.synchro_queue_length(cfg),
    replication.synchro_queue_busy(cfg),
  ],

  http(cfg):: [
    http.row,
    http.rps_success(cfg),
    http.rps_error_4xx(cfg),
    http.rps_error_5xx(cfg),
    http.latency_success(cfg),
    http.latency_error_4xx(cfg),
    http.latency_error_5xx(cfg),
  ],

  net(cfg):: [
    net.row,
    net.net_memory(cfg),
    net.bytes_received_per_second(cfg),
    net.bytes_sent_per_second(cfg),
    net.net_rps(cfg),
    net.net_pending(cfg),
    net.requests_in_progress_per_second(cfg),
    net.requests_in_progress_current(cfg),
    net.requests_in_queue_per_second(cfg),
    net.requests_in_queue_current(cfg),
    net.connections_per_second(cfg),
    net.current_connections(cfg),
    net.bytes_sent_per_thread_per_second(cfg),
    net.bytes_received_per_thread_per_second(cfg),
    net.connections_per_thread_per_second(cfg),
    net.current_connections_per_thread(cfg),
    net.net_rps_per_thread(cfg),
    net.requests_in_progress_per_thread_per_second(cfg),
    net.requests_in_queue_per_thread_per_second(cfg),
    net.net_pending_per_thread(cfg),
    net.requests_in_progress_current_per_thread(cfg),
    net.requests_in_queue_current_per_thread(cfg),
  ],

  slab(cfg):: [
    slab.row,
    slab.monitor_info(),
    slab.quota_used_ratio(cfg),
    slab.arena_used_ratio(cfg),
    slab.items_used_ratio(cfg),
    slab.quota_used(cfg),
    slab.arena_used(cfg),
    slab.items_used(cfg),
    slab.quota_size(cfg),
    slab.arena_size(cfg),
    slab.items_size(cfg),
  ],

  mvcc(cfg):: [
    mvcc.row,
    mvcc.memtx_tnx_statements_total(cfg),
    mvcc.memtx_tnx_statements_average(cfg),
    mvcc.memtx_tnx_statements_max(cfg),
    mvcc.memtx_tnx_user_total(cfg),
    mvcc.memtx_tnx_user_average(cfg),
    mvcc.memtx_tnx_user_max(cfg),
    mvcc.memtx_tnx_system_total(cfg),
    mvcc.memtx_tnx_system_average(cfg),
    mvcc.memtx_tnx_system_max(cfg),
    mvcc.memtx_mvcc_trackers_total(cfg),
    mvcc.memtx_mvcc_trackers_average(cfg),
    mvcc.memtx_mvcc_trackers_max(cfg),
    mvcc.memtx_mvcc_conflicts_total(cfg),
    mvcc.memtx_mvcc_conflicts_average(cfg),
    mvcc.memtx_mvcc_conflicts_max(cfg),
    mvcc.memtx_mvcc_tuples_used_stories_count(cfg),
    mvcc.memtx_mvcc_tuples_used_stories_total(cfg),
    mvcc.memtx_mvcc_tuples_used_retained_count(cfg),
    mvcc.memtx_mvcc_tuples_used_retained_total(cfg),
    mvcc.memtx_mvcc_tuples_read_view_stories_count(cfg),
    mvcc.memtx_mvcc_tuples_read_view_stories_total(cfg),
    mvcc.memtx_mvcc_tuples_read_view_retained_count(cfg),
    mvcc.memtx_mvcc_tuples_read_view_retained_total(cfg),
    mvcc.memtx_mvcc_tuples_tracking_stories_count(cfg),
    mvcc.memtx_mvcc_tuples_tracking_stories_total(cfg),
    mvcc.memtx_mvcc_tuples_tracking_retained_count(cfg),
    mvcc.memtx_mvcc_tuples_tracking_retained_total(cfg),
  ],

  space(cfg):: [
    space.row,
    space.memtx_len(cfg),
    space.vinyl_count(cfg),
    space.space_bsize(cfg),
    space.space_index_bsize(cfg),
    space.space_total_bsize(cfg),
  ],

  vinyl(cfg):: [
    vinyl.row,
    vinyl.disk_data(cfg),
    vinyl.index_data(cfg),
    vinyl.tuples_cache_memory(cfg),
    vinyl.index_memory(cfg),
    vinyl.bloom_filter_memory(cfg),
    vinyl.regulator_dump_bandwidth(cfg),
    vinyl.regulator_write_rate(cfg),
    vinyl.regulator_rate_limit(cfg),
    vinyl.memory_level0(cfg),
    vinyl.regulator_dump_watermark(cfg),
    vinyl.regulator_blocked_writers(cfg),
    vinyl.tx_commit_rate(cfg),
    vinyl.tx_rollback_rate(cfg),
    vinyl.tx_conflicts_rate(cfg),
    vinyl.tx_read_views(cfg),
    vinyl.scheduler_tasks_inprogress(cfg),
    vinyl.scheduler_tasks_failed_rate(cfg),
    vinyl.scheduler_dump_time_rate(cfg),
    vinyl.scheduler_dump_count_rate(cfg),
  ],

  cpu(cfg):: [
    cpu.row,
    cpu.getrusage_cpu_user_time(cfg),
    cpu.getrusage_cpu_system_time(cfg),
  ],

  cpu_extended(cfg):: [
    cpu.row,
    cpu.getrusage_cpu_user_time(cfg),
    cpu.getrusage_cpu_system_time(cfg),
    cpu.procstat_thread_user_time(cfg),
    cpu.procstat_thread_system_time(cfg),
  ],

  runtime(cfg):: [
    runtime.row,
    runtime.lua_memory(cfg),
    runtime.runtime_memory(cfg),
    runtime.memory_tx(cfg),
    runtime.fiber_csw(cfg),
    runtime.event_loop_time(cfg),
    runtime.fiber_count(cfg),
    runtime.fiber_memused(cfg),
    runtime.fiber_memalloc(cfg),
  ],

  luajit(cfg):: [
    luajit.row,
    luajit.snap_restores(cfg),
    luajit.jit_traces(cfg),
    luajit.jit_traces_aborts(cfg),
    luajit.machine_code_areas(cfg),
    luajit.strhash_hit(cfg),
    luajit.strhash_miss(cfg),
    luajit.gc_steps_atomic(cfg),
    luajit.gc_steps_sweepstring(cfg),
    luajit.gc_steps_finalize(cfg),
    luajit.gc_steps_sweep(cfg),
    luajit.gc_steps_propagate(cfg),
    luajit.gc_steps_pause(cfg),
    luajit.strings_allocated(cfg),
    luajit.tables_allocated(cfg),
    luajit.cdata_allocated(cfg),
    luajit.userdata_allocated(cfg),
    luajit.gc_memory_current(cfg),
    luajit.gc_memory_freed(cfg),
    luajit.gc_memory_allocated(cfg),
  ],

  operations(cfg):: [
    operations.row,
    operations.space_select_rps(cfg),
    operations.space_insert_rps(cfg),
    operations.space_replace_rps(cfg),
    operations.space_upsert_rps(cfg),
    operations.space_update_rps(cfg),
    operations.space_delete_rps(cfg),
    operations.call_rps(cfg),
    operations.eval_rps(cfg),
    operations.error_rps(cfg),
    operations.auth_rps(cfg),
    operations.SQL_prepare_rps(cfg),
    operations.SQL_execute_rps(cfg),
    operations.txn_begin_rps(cfg),
    operations.txn_commit_rps(cfg),
    operations.txn_rollback_rps(cfg),
  ],

  crud(cfg):: [
    crud.row,
    crud.select_success_rps(cfg),
    crud.select_success_latency(cfg),
    crud.select_error_rps(cfg),
    crud.select_error_latency(cfg),
    crud.tuples_fetched_panel(cfg),
    crud.tuples_lookup_panel(cfg),
    crud.map_reduces(cfg),
    crud.insert_success_rps(cfg),
    crud.insert_success_latency(cfg),
    crud.insert_error_rps(cfg),
    crud.insert_error_latency(cfg),
    crud.insert_many_success_rps(cfg),
    crud.insert_many_success_latency(cfg),
    crud.insert_many_error_rps(cfg),
    crud.insert_many_error_latency(cfg),
    crud.replace_success_rps(cfg),
    crud.replace_success_latency(cfg),
    crud.replace_error_rps(cfg),
    crud.replace_error_latency(cfg),
    crud.replace_many_success_rps(cfg),
    crud.replace_many_success_latency(cfg),
    crud.replace_many_error_rps(cfg),
    crud.replace_many_error_latency(cfg),
    crud.upsert_success_rps(cfg),
    crud.upsert_success_latency(cfg),
    crud.upsert_error_rps(cfg),
    crud.upsert_error_latency(cfg),
    crud.upsert_many_success_rps(cfg),
    crud.upsert_many_success_latency(cfg),
    crud.upsert_many_error_rps(cfg),
    crud.upsert_many_error_latency(cfg),
    crud.update_success_rps(cfg),
    crud.update_success_latency(cfg),
    crud.update_error_rps(cfg),
    crud.update_error_latency(cfg),
    crud.delete_success_rps(cfg),
    crud.delete_success_latency(cfg),
    crud.delete_error_rps(cfg),
    crud.delete_error_latency(cfg),
    crud.count_success_rps(cfg),
    crud.count_success_latency(cfg),
    crud.count_error_rps(cfg),
    crud.count_error_latency(cfg),
    crud.get_success_rps(cfg),
    crud.get_success_latency(cfg),
    crud.get_error_rps(cfg),
    crud.get_error_latency(cfg),
    crud.borders_success_rps(cfg),
    crud.borders_success_latency(cfg),
    crud.borders_error_rps(cfg),
    crud.borders_error_latency(cfg),
    crud.len_success_rps(cfg),
    crud.len_success_latency(cfg),
    crud.len_error_rps(cfg),
    crud.len_error_latency(cfg),
    crud.truncate_success_rps(cfg),
    crud.truncate_success_latency(cfg),
    crud.truncate_error_rps(cfg),
    crud.truncate_error_latency(cfg),
  ],

  expirationd(cfg):: [
    expirationd.row,
    expirationd.tuples_checked(cfg),
    expirationd.tuples_expired(cfg),
    expirationd.restarts(cfg),
    expirationd.operation_time(cfg),
  ],

  tdg_kafka_common(cfg):: [
    tdg_kafka_common.row,
    tdg_kafka_common.queue_operations(cfg),
    tdg_kafka_common.message_current(cfg),
    tdg_kafka_common.message_size(cfg),
    tdg_kafka_common.requests(cfg),
    tdg_kafka_common.request_bytes(cfg),
    tdg_kafka_common.responses(cfg),
    tdg_kafka_common.response_bytes(cfg),
    tdg_kafka_common.messages_sent(cfg),
    tdg_kafka_common.message_bytes_sent(cfg),
    tdg_kafka_common.messages_received(cfg),
    tdg_kafka_common.message_bytes_received(cfg),
  ],

  tdg_kafka_brokers(cfg):: [
    tdg_kafka_brokers.row,
    tdg_kafka_brokers.stateage(cfg),
    tdg_kafka_brokers.connects(cfg),
    tdg_kafka_brokers.disconnects(cfg),
    tdg_kafka_brokers.poll_wakeups(cfg),
    tdg_kafka_brokers.outbuf(cfg),
    tdg_kafka_brokers.outbuf_msg(cfg),
    tdg_kafka_brokers.waitresp(cfg),
    tdg_kafka_brokers.waitresp_msg(cfg),
    tdg_kafka_brokers.requests(cfg),
    tdg_kafka_brokers.request_bytes(cfg),
    tdg_kafka_brokers.request_errors(cfg),
    tdg_kafka_brokers.request_retries(cfg),
    tdg_kafka_brokers.request_idle(cfg),
    tdg_kafka_brokers.request_timeout(cfg),
    tdg_kafka_brokers.responses(cfg),
    tdg_kafka_brokers.response_bytes(cfg),
    tdg_kafka_brokers.response_errors(cfg),
    tdg_kafka_brokers.response_corriderrs(cfg),
    tdg_kafka_brokers.response_idle(cfg),
    tdg_kafka_brokers.response_partial(cfg),
    tdg_kafka_brokers.requests_by_type(cfg),
    tdg_kafka_brokers.internal_producer_latency(cfg),
    tdg_kafka_brokers.internal_request_latency(cfg),
    tdg_kafka_brokers.broker_latency(cfg),
    tdg_kafka_brokers.broker_throttle(cfg),
  ],

  tdg_kafka_topics(cfg):: [
    tdg_kafka_topics.row,
    tdg_kafka_topics.age(cfg),
    tdg_kafka_topics.metadata_age(cfg),
    tdg_kafka_topics.topic_batchsize(cfg),
    tdg_kafka_topics.topic_batchcnt(cfg),
    tdg_kafka_topics.partition_msgq(cfg),
    tdg_kafka_topics.partition_xmit_msgq(cfg),
    tdg_kafka_topics.partition_fetchq_msgq(cfg),
    tdg_kafka_topics.partition_msgq_bytes(cfg),
    tdg_kafka_topics.partition_xmit_msgq_bytes(cfg),
    tdg_kafka_topics.partition_fetchq_msgq_bytes(cfg),
    tdg_kafka_topics.partition_messages_sent(cfg),
    tdg_kafka_topics.partition_message_bytes_sent(cfg),
    tdg_kafka_topics.partition_messages_consumed(cfg),
    tdg_kafka_topics.partition_message_bytes_consumed(cfg),
    tdg_kafka_topics.partition_messages_dropped(cfg),
    tdg_kafka_topics.partition_messages_in_flight(cfg),
  ],

  tdg_kafka_consumer(cfg):: [
    tdg_kafka_consumer.row,
    tdg_kafka_consumer.stateage(cfg),
    tdg_kafka_consumer.rebalance_age(cfg),
    tdg_kafka_consumer.rebalances(cfg),
    tdg_kafka_consumer.assignment_size(cfg),
  ],

  tdg_kafka_producer(cfg):: [
    tdg_kafka_producer.row,
    tdg_kafka_producer.idemp_stateage(cfg),
    tdg_kafka_producer.txn_stateage(cfg),
  ],

  tdg_tuples(cfg):: [
    tdg_tuples.row,
    tdg_tuples.tuples_scanned_average(cfg),
    tdg_tuples.tuples_returned_average(cfg),
    tdg_tuples.tuples_scanned_max(cfg),
    tdg_tuples.tuples_returned_max(cfg),
  ],

  tdg_file_connectors(cfg):: [
    tdg_file_connectors.row,
    tdg_file_connectors.files_processed(cfg),
    tdg_file_connectors.objects_processed(cfg),
    tdg_file_connectors.files_process_errors(cfg),
    tdg_file_connectors.file_size(cfg),
    tdg_file_connectors.current_bytes_processed(cfg),
    tdg_file_connectors.current_objects_processed(cfg),
  ],

  tdg_graphql(cfg):: [
    tdg_graphql.row,
    tdg_graphql.query_success_rps(cfg),
    tdg_graphql.query_success_latency(cfg),
    tdg_graphql.query_error_rps(cfg),
    tdg_graphql.mutation_success_rps(cfg),
    tdg_graphql.mutation_success_latency(cfg),
    tdg_graphql.mutation_error_rps(cfg),
  ],

  tdg_iproto(cfg):: [
    tdg_iproto.row,
    tdg_iproto.put_rps(cfg),
    tdg_iproto.put_latency(cfg),
    tdg_iproto.put_batch_rps(cfg),
    tdg_iproto.put_batch_latency(cfg),
    tdg_iproto.find_rps(cfg),
    tdg_iproto.find_latency(cfg),
    tdg_iproto.update_rps(cfg),
    tdg_iproto.update_latency(cfg),
    tdg_iproto.get_rps(cfg),
    tdg_iproto.get_latency(cfg),
    tdg_iproto.delete_rps(cfg),
    tdg_iproto.delete_latency(cfg),
    tdg_iproto.count_rps(cfg),
    tdg_iproto.count_latency(cfg),
    tdg_iproto.map_reduce_rps(cfg),
    tdg_iproto.map_reduce_latency(cfg),
    tdg_iproto.call_on_storage_rps(cfg),
    tdg_iproto.call_on_storage_latency(cfg),
  ],

  tdg_rest_api(cfg):: [
    tdg_rest_api.row,
    tdg_rest_api.read_success_rps(cfg),
    tdg_rest_api.read_error_4xx_rps(cfg),
    tdg_rest_api.read_error_5xx_rps(cfg),
    tdg_rest_api.read_success_latency(cfg),
    tdg_rest_api.read_error_4xx_latency(cfg),
    tdg_rest_api.read_error_5xx_latency(cfg),
    tdg_rest_api.write_success_rps(cfg),
    tdg_rest_api.write_error_4xx_rps(cfg),
    tdg_rest_api.write_error_5xx_rps(cfg),
    tdg_rest_api.write_success_latency(cfg),
    tdg_rest_api.write_error_4xx_latency(cfg),
    tdg_rest_api.write_error_5xx_latency(cfg),
  ],

  tdg_tasks(cfg):: [
    tdg_tasks.row,
    tdg_tasks.jobs_started(cfg),
    tdg_tasks.jobs_failed(cfg),
    tdg_tasks.jobs_succeeded(cfg),
    tdg_tasks.jobs_running(cfg),
    tdg_tasks.jobs_time(cfg),
    tdg_tasks.tasks_started(cfg),
    tdg_tasks.tasks_failed(cfg),
    tdg_tasks.tasks_succeeded(cfg),
    tdg_tasks.tasks_stopped(cfg),
    tdg_tasks.tasks_running(cfg),
    tdg_tasks.tasks_time(cfg),
    tdg_tasks.system_tasks_started(cfg),
    tdg_tasks.system_tasks_failed(cfg),
    tdg_tasks.system_tasks_succeeded(cfg),
    tdg_tasks.system_tasks_running(cfg),
    tdg_tasks.system_tasks_time(cfg),
  ],
}
