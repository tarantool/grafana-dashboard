local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'panels/cluster.libsonnet';
local cpu = import 'panels/cpu.libsonnet';
local http = import 'panels/http.libsonnet';
local memory_misc = import 'panels/memory_misc.libsonnet';
local net = import 'panels/net.libsonnet';
local operations = import 'panels/operations.libsonnet';
local slab = import 'panels/slab.libsonnet';
local vinyl = import 'panels/vinyl.libsonnet';

local dashboard = import 'dashboard.libsonnet';

local datasource = '${DS_PROMETHEUS}';
local rate_time_range = '$rate_time_range';
local job = '[[job]]';

dashboard.new(
  grafana.dashboard.new(
    title='Tarantool dashboard',
    description='Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
    editable=true,
    schemaVersion=21,
    time_from='now-3h',
    time_to='now',
    refresh='30s',
    tags=['tarantool'],
  ).addRequired(
    type='grafana',
    id='grafana',
    name='Grafana',
    version='6.6.0'
  ).addRequired(
    type='panel',
    id='graph',
    name='Graph',
    version=''
  ).addRequired(
    type='panel',
    id='text',
    name='Text',
    version=''
  ).addRequired(
    type='panel',
    id='stat',
    name='Stat',
    version='',
  ).addRequired(
    type='panel',
    id='table',
    name='Table',
    version='',
  ).addRequired(
    type='datasource',
    id='prometheus',
    name='Prometheus',
    version='1.0.0'
  ).addInput(
    name='DS_PROMETHEUS',
    label='Prometheus',
    type='datasource',
    pluginId='prometheus',
    pluginName='Prometheus',
    description='Prometheus Tarantool metrics bank'
  ).addInput(
    name='PROMETHEUS_JOB',
    label='Job',
    type='constant',
    pluginId=null,
    pluginName=null,
    description='Prometheus Tarantool metrics job'
  ).addInput(
    name='PROMETHEUS_RATE_TIME_RANGE',
    label='Rate time range',
    type='constant',
    value='2m',
    description='Time range for computing rps graphs with rate(). At the very minimum it should be two times the scrape interval.'
  ).addTemplate(
    grafana.template.custom(
      name='job',
      query='${PROMETHEUS_JOB}',
      current='${PROMETHEUS_JOB}',
      hide='variable',
      label='Prometheus job',
    )
  ).addTemplate(
    grafana.template.custom(
      name='rate_time_range',
      query='${PROMETHEUS_RATE_TIME_RANGE}',
      current='${PROMETHEUS_RATE_TIME_RANGE}',
      hide='variable',
      label='rate() time range',
    )
  )
).addPanels([
  cluster.row,

  cluster.health_overview_table(
    datasource=datasource,
    job=job,
  ) { gridPos: { w: 12, h: 8, x: 0, y: 1 } },

  cluster.health_overview_stat(
    datasource=datasource,
    job=job,
  ) { gridPos: { w: 8, h: 3, x: 12, y: 1 } },

  cluster.memory_used_stat(
    datasource=datasource,
    job=job,
  ) { gridPos: { w: 4, h: 5, x: 12, y: 4 } },

  cluster.memory_reserved_stat(
    datasource=datasource,
    job=job,
  ) { gridPos: { w: 4, h: 5, x: 16, y: 4 } },

  cluster.space_ops_stat(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ) { gridPos: { w: 4, h: 4, x: 20, y: 1 } },

  cluster.http_rps_stat(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ) { gridPos: { w: 4, h: 4, x: 20, y: 5 } },

  cluster.cartridge_warning_issues(
    datasource=datasource,
    job=job,
  ),

  cluster.cartridge_critical_issues(
    datasource=datasource,
    job=job,
  ),

  cluster.replication_lag(
    datasource=datasource,
    job=job,
  ),
]).addPanels([
  http.row,

  http.rps_success(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  http.rps_error_4xx(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  http.rps_error_5xx(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  http.latency_success(
    datasource=datasource,
    job=job,
  ),

  http.latency_error_4xx(
    datasource=datasource,
    job=job,
  ),

  http.latency_error_5xx(
    datasource=datasource,
    job=job,
  ),
]).addPanels([
  net.row,

  net.bytes_received_per_second(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  net.bytes_sent_per_second(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  net.net_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  net.net_pending(
    datasource=datasource,
    job=job,
  ),

  net.current_connections(
    datasource=datasource,
    job=job,
  ),
]).addPanels([
  slab.row,

  slab.monitor_info(),

  slab.quota_used_ratio(
    datasource=datasource,
    job=job,
  ),

  slab.arena_used_ratio(
    datasource=datasource,
    job=job,
  ),

  slab.items_used_ratio(
    datasource=datasource,
    job=job,
  ),

  slab.quota_used(
    datasource=datasource,
    job=job,
  ),

  slab.arena_used(
    datasource=datasource,
    job=job,
  ),

  slab.items_used(
    datasource=datasource,
    job=job,
  ),

  slab.quota_size(
    datasource=datasource,
    job=job,
  ),

  slab.arena_size(
    datasource=datasource,
    job=job,
  ),

  slab.items_size(
    datasource=datasource,
    job=job,
  ),
]).addPanels([
  vinyl.row,

  vinyl.disk_data(
    datasource=datasource,
    job=job,
  ),

  vinyl.index_data(
    datasource=datasource,
    job=job,
  ),

  vinyl.regulator_dump_bandwidth(
    datasource=datasource,
    job=job,
  ),

  vinyl.regulator_write_rate(
    datasource=datasource,
    job=job,
  ),

  vinyl.regulator_rate_limit(
    datasource=datasource,
    job=job,
  ),

  vinyl.regulator_dump_watermark(
    datasource=datasource,
    job=job,
  ),

  vinyl.tx_commit_rate(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  vinyl.tx_rollback_rate(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  vinyl.tx_conflicts_rate(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  vinyl.tx_read_views(
    datasource=datasource,
    job=job,
  ),

  vinyl.scheduler_tasks_inprogress(
    datasource=datasource,
    job=job,
  ),

  vinyl.scheduler_tasks_failed_rate(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  vinyl.scheduler_dump_time_rate(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  vinyl.scheduler_dump_count_rate(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),
]).addPanels([
  cpu.row,

  cpu.getrusage_cpu_user_time(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  cpu.getrusage_cpu_system_time(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),
]).addPanels([
  memory_misc.row,

  memory_misc.lua_memory(
    datasource=datasource,
    job=job,
  ),
]).addPanels([
  operations.row,

  operations.space_select_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.space_insert_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.space_replace_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.space_upsert_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.space_update_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.space_delete_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.call_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.eval_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.error_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.auth_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.SQL_prepare_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),

  operations.SQL_execute_rps(
    datasource=datasource,
    job=job,
    rate_time_range=rate_time_range,
  ),
])
