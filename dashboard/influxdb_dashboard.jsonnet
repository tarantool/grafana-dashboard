local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local cpu = import 'cpu.libsonnet';
local http = import 'http.libsonnet';
local memory_misc = import 'memory_misc.libsonnet';
local net = import 'net.libsonnet';
local operations = import 'operations.libsonnet';
local slab = import 'slab.libsonnet';
local utils = import 'utils.libsonnet';
local vinyl = import 'vinyl.libsonnet';


local datasource = '${DS_INFLUXDB}';
local policy = '${INFLUXDB_POLICY}';
local measurement = '${INFLUXDB_MEASUREMENT}';

grafana.dashboard.new(
  title='Tarantool dashboard',
  description='Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
  editable=true,
  schemaVersion=21,
  time_from='now-3h',
  time_to='now',
  refresh='30s',
  tags=['tarantool'],
)
.addRequired(
  type='grafana',
  id='grafana',
  name='Grafana',
  version='6.6.0'
)
.addRequired(
  type='panel',
  id='graph',
  name='Graph',
  version=''
)
.addRequired(
  type='panel',
  id='text',
  name='Text',
  version=''
)
.addRequired(
  type='datasource',
  id='influxdb',
  name='InfluxDB',
  version='1.0.0'
)
.addInput(
  name='DS_INFLUXDB',
  label='InfluxDB bank',
  type='datasource',
  pluginId='influxdb',
  pluginName='InfluxDB',
  description='InfluxDB Tarantool metrics bank'
)
.addInput(
  name='INFLUXDB_MEASUREMENT',
  label='Measurement',
  type='constant',
  description='InfluxDB Tarantool metrics measurement'
)
.addInput(
  name='INFLUXDB_POLICY',
  label='Policy',
  type='constant',
  value='default',
  description='InfluxDB Tarantool metrics policy'
)
.addPanels(utils.generate_grid([
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

  cluster.replication_lag(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  http.row,

  http.rps_success(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  http.rps_error_4xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  http.rps_error_5xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  http.latency_success(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  http.latency_error_4xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  http.latency_error_5xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  net.row,

  net.bytes_received_per_second(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  net.bytes_sent_per_second(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  net.net_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  net.net_pending(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  net.current_connections(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.row,

  slab.monitor_info(),

  slab.quota_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.arena_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.items_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.quota_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.arena_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.items_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.quota_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.arena_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  slab.items_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),


  vinyl.row,

  vinyl.disk_data(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.index_data(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.regulator_dump_bandwidth(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.regulator_write_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.regulator_rate_limit(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.regulator_dump_watermark(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.tx_commit_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.tx_rollback_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.tx_conflicts_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.tx_read_views(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.scheduler_tasks_inprogress(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.scheduler_tasks_failed_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.scheduler_dump_time_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  vinyl.scheduler_dump_count_rate(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  cpu.row,

  cpu.getrusage_cpu_user_time(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  cpu.getrusage_cpu_system_time(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  memory_misc.row,

  memory_misc.lua_memory(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.row,

  operations.space_select_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.space_insert_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.space_replace_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.space_upsert_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.space_update_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.space_delete_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.call_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.eval_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.error_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.auth_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.SQL_prepare_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),

  operations.SQL_execute_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
]))
