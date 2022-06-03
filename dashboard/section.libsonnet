local cluster = import 'panels/cluster.libsonnet';
local cpu = import 'panels/cpu.libsonnet';
local crud = import 'panels/crud.libsonnet';
local http = import 'panels/http.libsonnet';
local luajit = import 'panels/luajit.libsonnet';
local net = import 'panels/net.libsonnet';
local operations = import 'panels/operations.libsonnet';
local runtime = import 'panels/runtime.libsonnet';
local slab = import 'panels/slab.libsonnet';
local space = import 'panels/space.libsonnet';
local vinyl = import 'panels/vinyl.libsonnet';

local tdg_expirationd = import 'panels/tdg/expirationd.libsonnet';
local tdg_file_connectors = import 'panels/tdg/file_connectors.libsonnet';
local tdg_kafka_brokers = import 'panels/tdg/kafka/brokers.libsonnet';
local tdg_kafka_common = import 'panels/tdg/kafka/common.libsonnet';
local tdg_kafka_consumer = import 'panels/tdg/kafka/consumer.libsonnet';
local tdg_kafka_producer = import 'panels/tdg/kafka/producer.libsonnet';
local tdg_kafka_topics = import 'panels/tdg/kafka/topics.libsonnet';
local tdg_tuples = import 'panels/tdg/tuples.libsonnet';

{
  cluster_influxdb(datasource, policy, measurement):: [
    cluster.row,

    cluster.cartridge_warning_issues(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.cartridge_critical_issues(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.replication_status(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.read_only_status(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.replication_lag(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.clock_delta(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),
  ],

  // Must be used only in the top of a dashboard, overall stat panels use complicated layout
  cluster_prometheus(datasource, job, rate_time_range):: [
    cluster.row,

    cluster.health_overview_table(
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 12, h: 8, x: 0, y: 1 } },

    cluster.health_overview_stat(
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 6, h: 3, x: 12, y: 1 } },

    cluster.memory_used_stat(
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 3, h: 3, x: 18, y: 1 } },

    cluster.memory_reserved_stat(
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 3, h: 3, x: 21, y: 1 } },

    cluster.http_rps_stat(
      datasource=datasource,
      job=job,
      rate_time_range=rate_time_range,
    ) { gridPos: { w: 4, h: 5, x: 12, y: 4 } },

    cluster.net_rps_stat(
      datasource=datasource,
      job=job,
      rate_time_range=rate_time_range,
    ) { gridPos: { w: 4, h: 5, x: 16, y: 4 } },

    cluster.space_ops_stat(
      datasource=datasource,
      job=job,
      rate_time_range=rate_time_range,
    ) { gridPos: { w: 4, h: 5, x: 20, y: 4 } },

    cluster.cartridge_warning_issues(
      datasource=datasource,
      job=job,
    ),

    cluster.cartridge_critical_issues(
      datasource=datasource,
      job=job,
    ),

    cluster.replication_status(
      datasource=datasource,
      job=job,
    ),

    cluster.read_only_status(
      datasource=datasource,
      job=job,
    ),

    cluster.replication_lag(
      datasource=datasource,
      job=job,
    ),

    cluster.clock_delta(
      datasource=datasource,
      job=job,
    ),
  ],

  http(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    http.row,

    http.rps_success(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    http.rps_error_4xx(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    http.rps_error_5xx(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    http.latency_success(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.latency_error_4xx(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.latency_error_5xx(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  net(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    net.row,

    net.net_memory(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.bytes_received_per_second(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    net.bytes_sent_per_second(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    net.net_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    net.net_pending(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.requests_in_progress_per_second(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    net.requests_in_progress_current(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.requests_in_queue_per_second(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    net.requests_in_queue_current(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.connections_per_second(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    net.current_connections(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  slab(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    slab.row,

    slab.monitor_info(),

    slab.quota_used_ratio(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.arena_used_ratio(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.items_used_ratio(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.quota_used(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.arena_used(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.items_used(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.quota_size(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.arena_size(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.items_size(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  space(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    space.row,

    space.memtx_len(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.vinyl_count(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.space_bsize(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.space_index_bsize(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.space_total_bsize(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  vinyl(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    vinyl.row,

    vinyl.disk_data(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.index_data(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.index_memory(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.bloom_filter_memory(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_dump_bandwidth(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_write_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_rate_limit(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_dump_watermark(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_blocked_writers(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.tx_commit_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    vinyl.tx_rollback_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    vinyl.tx_conflicts_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    vinyl.tx_read_views(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.scheduler_tasks_inprogress(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.scheduler_tasks_failed_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    vinyl.scheduler_dump_time_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    vinyl.scheduler_dump_count_rate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),
  ],

  cpu(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    cpu.row,

    cpu.getrusage_cpu_user_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    cpu.getrusage_cpu_system_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),
  ],

  cpu_extended(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    cpu.row,

    cpu.getrusage_cpu_user_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    cpu.getrusage_cpu_system_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    cpu.procstat_thread_user_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    cpu.procstat_thread_system_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),
  ],

  runtime(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    runtime.row,

    runtime.lua_memory(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.memory_tx(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_csw_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    runtime.event_loop_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_count(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_memused(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_memalloc(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  luajit(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    luajit.row,

    luajit.snap_restores(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.jit_traces(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.jit_traces_aborts(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.machine_code_areas(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.strhash_hit(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.strhash_miss(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_steps_atomic(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_steps_sweepstring(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_steps_finalize(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_steps_sweep(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_steps_propagate(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_steps_pause(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.strings_allocated(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.tables_allocated(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.cdata_allocated(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.userdata_allocated(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_memory_current(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_memory_freed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    luajit.gc_memory_allocated(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),
  ],

  operations(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    operations.row,

    operations.space_select_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.space_insert_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.space_replace_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.space_upsert_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.space_update_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.space_delete_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.call_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.eval_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.auth_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.SQL_prepare_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    operations.SQL_execute_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),
  ],

  crud(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    crud.row,

    crud.select_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.select_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.select_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.select_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.tuples_fetched_panel(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.tuples_lookup_panel(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.map_reduces(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.insert_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.insert_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.insert_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.replace_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.replace_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.upsert_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.upsert_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.update_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.update_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.update_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.update_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.delete_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.delete_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.delete_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.delete_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.count_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.count_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.count_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.count_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.get_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.get_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.get_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.get_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.borders_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.borders_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.borders_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.borders_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.len_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.len_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.len_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.len_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.truncate_success_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.truncate_success_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.truncate_error_rps(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    crud.truncate_error_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_common(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_kafka_common.row,

    tdg_kafka_common.queue_operations(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.message_current(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.message_size(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.requests(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.request_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.responses(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.response_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.messages_sent(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.message_bytes_sent(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.messages_received(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_common.message_bytes_received(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),
  ],

  tdg_kafka_brokers(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_kafka_brokers.row,

    tdg_kafka_brokers.stateage(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.connects(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.disconnects(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.poll_wakeups(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.outbuf(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.outbuf_msg(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.waitresp(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.waitresp_msg(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.requests(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.request_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.request_errors(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.request_retries(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.request_idle(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.request_timeout(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.responses(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.response_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.response_errors(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.response_corriderrs(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.response_idle(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.response_partial(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.requests_by_type(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_brokers.internal_producer_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.internal_request_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.broker_latency(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.broker_throttle(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_topics(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_kafka_topics.row,

    tdg_kafka_topics.age(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.metadata_age(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.topic_batchsize(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.topic_batchcnt(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_msgq(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_xmit_msgq(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_fetchq_msgq(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_msgq_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_xmit_msgq_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_fetchq_msgq_bytes(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_messages_sent(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_topics.partition_message_bytes_sent(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_topics.partition_messages_consumed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_topics.partition_message_bytes_consumed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_topics.partition_messages_dropped(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_topics.partition_messages_in_flight(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_consumer(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_kafka_consumer.row,

    tdg_kafka_consumer.stateage(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_consumer.rebalance_age(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_consumer.rebalances(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_kafka_consumer.assignment_size(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_producer(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_kafka_producer.row,

    tdg_kafka_producer.idemp_stateage(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_producer.txn_stateage(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_expirationd(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_expirationd.row,

    tdg_expirationd.tuples_checked(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_expirationd.tuples_expired(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      rate_time_range=rate_time_range,
    ),

    tdg_expirationd.restarts(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_expirationd.operation_time(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_tuples(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_tuples.row,

    tdg_tuples.tuples_scanned_average(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tuples.tuples_returned_average(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tuples.tuples_scanned_max(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tuples.tuples_returned_max(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_file_connectors(datasource, policy=null, measurement=null, job=null, rate_time_range=null):: [
    tdg_file_connectors.row,

    tdg_file_connectors.files_processed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.objects_processed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.files_process_errors(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.file_size(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.current_bytes_processed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.current_objects_processed(
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],
}
