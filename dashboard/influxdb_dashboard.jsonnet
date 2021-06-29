local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local cpu = import 'cpu.libsonnet';
local http = import 'http.libsonnet';
local memory_misc = import 'memory_misc.libsonnet';
local net = import 'net.libsonnet';
local operations = import 'operations.libsonnet';
local slab = import 'slab.libsonnet';
local utils = import 'utils.libsonnet';
local row = grafana.row;
local dashboard = grafana.dashboard;


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
  cluster.row { gridPos: { w: 24, h: 1 } },

  cluster.cartridge_warning_issues(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 12, h: 6 } },

  cluster.cartridge_critical_issues(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 12, h: 6 } },

  cluster.replication_lag(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 24, h: 8 } },

  http.row { gridPos: { w: 24, h: 1 } },

  http.rps_success(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  http.rps_error_4xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  http.rps_error_5xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  http.latency_success(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  http.latency_error_4xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  http.latency_error_5xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  net.row { gridPos: { w: 24, h: 1 } },

  net.bytes_received_per_second(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 12, h: 8 } },

  net.bytes_sent_per_second(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 12, h: 8 } },

  net.net_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  net.net_pending(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  net.current_connections(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.row { gridPos: { w: 24, h: 1 } },

  slab.monitor_info() { gridPos: { w: 24, h: 3 } },

  slab.quota_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.arena_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.items_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.quota_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.arena_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.items_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.quota_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.arena_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  slab.items_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  cpu.row { gridPos: { w: 24, h: 1 } },

  cpu.getrusage_cpu_user_time(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 12, h: 8 } },

  cpu.getrusage_cpu_system_time(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 12, h: 8 } },

  memory_misc.row { gridPos: { w: 24, h: 1 } },

  memory_misc.lua_memory(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 24, h: 8 } },

  operations.row { gridPos: { w: 24, h: 1 } },

  operations.space_select_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.space_insert_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.space_replace_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.space_upsert_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.space_update_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.space_delete_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.call_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.eval_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.error_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.auth_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.SQL_prepare_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },

  operations.SQL_execute_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ) { gridPos: { w: 8, h: 8 } },
]))
