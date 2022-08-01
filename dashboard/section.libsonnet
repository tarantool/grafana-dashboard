local cluster = import 'dashboard/panels/cluster.libsonnet';
local cpu = import 'dashboard/panels/cpu.libsonnet';
local crud = import 'dashboard/panels/crud.libsonnet';
local expirationd = import 'dashboard/panels/expirationd.libsonnet';
local http = import 'dashboard/panels/http.libsonnet';
local luajit = import 'dashboard/panels/luajit.libsonnet';
local net = import 'dashboard/panels/net.libsonnet';
local operations = import 'dashboard/panels/operations.libsonnet';
local runtime = import 'dashboard/panels/runtime.libsonnet';
local slab = import 'dashboard/panels/slab.libsonnet';
local space = import 'dashboard/panels/space.libsonnet';
local vinyl = import 'dashboard/panels/vinyl.libsonnet';

local tdg_expirationd = import 'dashboard/panels/tdg/expirationd.libsonnet';
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
  cluster_influxdb(datasource_type, datasource, policy, measurement):: [
    cluster.row,

    cluster.cartridge_warning_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.cartridge_critical_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.replication_status(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.read_only_status(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.replication_lag(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),

    cluster.clock_delta(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
    ),
  ],

  // Must be used only in the top of a dashboard, overall stat panels use complicated layout
  cluster_prometheus(datasource_type, datasource, job):: [
    cluster.row,

    cluster.health_overview_table(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 12, h: 8, x: 0, y: 1 } },

    cluster.health_overview_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 6, h: 3, x: 12, y: 1 } },

    cluster.memory_used_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 3, h: 3, x: 18, y: 1 } },

    cluster.memory_reserved_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 3, h: 3, x: 21, y: 1 } },

    cluster.http_rps_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 4, h: 5, x: 12, y: 4 } },

    cluster.net_rps_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 4, h: 5, x: 16, y: 4 } },

    cluster.space_ops_stat(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ) { gridPos: { w: 4, h: 5, x: 20, y: 4 } },

    cluster.cartridge_warning_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ),

    cluster.cartridge_critical_issues(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ),

    cluster.replication_status(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ),

    cluster.read_only_status(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ),

    cluster.replication_lag(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ),

    cluster.clock_delta(
      datasource_type=datasource_type,
      datasource=datasource,
      job=job,
    ),
  ],

  http(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    http.row,

    http.rps_success(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.rps_error_4xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.rps_error_5xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.latency_success(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.latency_error_4xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    http.latency_error_5xx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  net(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    net.row,

    net.net_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.bytes_received_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.bytes_sent_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.net_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.net_pending(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.requests_in_progress_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.requests_in_progress_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.requests_in_queue_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.requests_in_queue_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.connections_per_second(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    net.current_connections(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  slab(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    slab.row,

    slab.monitor_info(),

    slab.quota_used_ratio(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.arena_used_ratio(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.items_used_ratio(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.quota_used(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.arena_used(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.items_used(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.quota_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.arena_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    slab.items_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  space(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    space.row,

    space.memtx_len(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.vinyl_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.space_bsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.space_index_bsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    space.space_total_bsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  vinyl(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    vinyl.row,

    vinyl.disk_data(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.index_data(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.tuples_cache_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.index_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.bloom_filter_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_dump_bandwidth(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_write_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_rate_limit(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.memory_level0(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_dump_watermark(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.regulator_blocked_writers(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.tx_commit_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.tx_rollback_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.tx_conflicts_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.tx_read_views(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.scheduler_tasks_inprogress(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.scheduler_tasks_failed_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.scheduler_dump_time_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    vinyl.scheduler_dump_count_rate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  cpu(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    cpu.row,

    cpu.getrusage_cpu_user_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    cpu.getrusage_cpu_system_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  cpu_extended(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    cpu.row,

    cpu.getrusage_cpu_user_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    cpu.getrusage_cpu_system_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    cpu.procstat_thread_user_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    cpu.procstat_thread_system_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  runtime(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    runtime.row,

    runtime.lua_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.runtime_memory(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.memory_tx(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_csw(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.event_loop_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_count(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_memused(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    runtime.fiber_memalloc(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  luajit(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    luajit.row,

    luajit.snap_restores(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.jit_traces(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.jit_traces_aborts(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.machine_code_areas(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.strhash_hit(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.strhash_miss(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_steps_atomic(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_steps_sweepstring(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_steps_finalize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_steps_sweep(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_steps_propagate(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_steps_pause(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.strings_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.tables_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.cdata_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.userdata_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_memory_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_memory_freed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    luajit.gc_memory_allocated(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  operations(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    operations.row,

    operations.space_select_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.space_insert_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.space_replace_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.space_upsert_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.space_update_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.space_delete_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.call_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.eval_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.auth_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.SQL_prepare_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    operations.SQL_execute_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  crud(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    crud.row,

    crud.select_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.select_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.select_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.select_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.tuples_fetched_panel(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.tuples_lookup_panel(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.map_reduces(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_many_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_many_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_many_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.insert_many_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_many_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_many_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_many_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.replace_many_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_many_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_many_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_many_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.upsert_many_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.update_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.update_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.update_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.update_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.delete_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.delete_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.delete_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.delete_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.count_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.count_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.count_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.count_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.get_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.get_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.get_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.get_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.borders_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.borders_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.borders_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.borders_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.len_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.len_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.len_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.len_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.truncate_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.truncate_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.truncate_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    crud.truncate_error_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  expirationd(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    expirationd.row,

    expirationd.tuples_checked(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    expirationd.tuples_expired(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    expirationd.restarts(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    expirationd.operation_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_common(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_kafka_common.row,

    tdg_kafka_common.queue_operations(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.message_current(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.message_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.requests(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.request_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.responses(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.response_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.messages_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.message_bytes_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.messages_received(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_common.message_bytes_received(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_brokers(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_kafka_brokers.row,

    tdg_kafka_brokers.stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.connects(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.disconnects(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.poll_wakeups(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.outbuf(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.outbuf_msg(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.waitresp(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.waitresp_msg(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.requests(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.request_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.request_errors(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.request_retries(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.request_idle(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.request_timeout(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.responses(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.response_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.response_errors(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.response_corriderrs(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.response_idle(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.response_partial(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.requests_by_type(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.internal_producer_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.internal_request_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.broker_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_brokers.broker_throttle(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_topics(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_kafka_topics.row,

    tdg_kafka_topics.age(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.metadata_age(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.topic_batchsize(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.topic_batchcnt(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_msgq(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_xmit_msgq(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_fetchq_msgq(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_msgq_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_xmit_msgq_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_fetchq_msgq_bytes(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_messages_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_message_bytes_sent(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_messages_consumed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_message_bytes_consumed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_messages_dropped(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_topics.partition_messages_in_flight(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_consumer(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_kafka_consumer.row,

    tdg_kafka_consumer.stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_consumer.rebalance_age(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_consumer.rebalances(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_consumer.assignment_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_kafka_producer(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_kafka_producer.row,

    tdg_kafka_producer.idemp_stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_kafka_producer.txn_stateage(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_expirationd(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_expirationd.row,

    tdg_expirationd.tuples_checked(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_expirationd.tuples_expired(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_expirationd.restarts(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_expirationd.operation_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_tuples(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_tuples.row,

    tdg_tuples.tuples_scanned_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tuples.tuples_returned_average(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tuples.tuples_scanned_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tuples.tuples_returned_max(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_file_connectors(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_file_connectors.row,

    tdg_file_connectors.files_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.objects_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.files_process_errors(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.file_size(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.current_bytes_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_file_connectors.current_objects_processed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_graphql(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_graphql.row,

    tdg_graphql.query_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_graphql.query_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_graphql.query_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_graphql.mutation_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_graphql.mutation_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_graphql.mutation_error_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_iproto(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_iproto.row,

    tdg_iproto.put_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.put_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.put_batch_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.put_batch_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.find_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.find_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.update_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.update_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.get_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.get_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.delete_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.delete_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.count_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.count_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.map_reduce_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.map_reduce_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.call_on_storage_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_iproto.call_on_storage_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_rest_api(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_rest_api.row,

    tdg_rest_api.read_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.read_error_4xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.read_error_5xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.read_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.read_error_4xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.read_error_5xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.write_success_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.write_error_4xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.write_error_5xx_rps(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.write_success_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.write_error_4xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_rest_api.write_error_5xx_latency(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],

  tdg_tasks(datasource_type, datasource, policy=null, measurement=null, job=null):: [
    tdg_tasks.row,

    tdg_tasks.jobs_started(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.jobs_failed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.jobs_succeeded(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.jobs_running(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.jobs_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.tasks_started(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.tasks_failed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.tasks_succeeded(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.tasks_stopped(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.tasks_running(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.tasks_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.system_tasks_started(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.system_tasks_failed(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.system_tasks_succeeded(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.system_tasks_running(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),

    tdg_tasks.system_tasks_time(
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
    ),
  ],
}
