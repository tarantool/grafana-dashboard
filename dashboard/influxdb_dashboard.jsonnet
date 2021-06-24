local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local cpu = import 'cpu.libsonnet';
local http = import 'http.libsonnet';
local memory_misc = import 'memory_misc.libsonnet';
local net = import 'net.libsonnet';
local operations = import 'operations.libsonnet';
local slab = import 'slab.libsonnet';
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
.addPanel(
  row.new(title='Cluster overview'),
  { w: 24, h: 1, x: 0, y: 0 }
)
.addPanel(
  cluster.cartridge_warning_issues(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 12, h: 6, x: 0, y: 1 }
)
.addPanel(
  cluster.cartridge_critical_issues(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 12, h: 6, x: 12, y: 1 }
)
.addPanel(
  cluster.replication_lag(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 24, h: 8, x: 12, y: 7 }
)
.addPanel(
  row.new(title='Tarantool HTTP statistics'),
  { w: 24, h: 1, x: 0, y: 15 }
)
.addPanel(
  http.rps_success(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 16 }
)
.addPanel(
  http.rps_error_4xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 16 },
)
.addPanel(
  http.rps_error_5xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 16 },
)
.addPanel(
  http.latency_success(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 24 }
)
.addPanel(
  http.latency_error_4xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 24 },
)
.addPanel(
  http.latency_error_5xx(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 24 },
)
.addPanel(
  row.new(title='Tarantool network activity'),
  { w: 24, h: 1, x: 0, y: 32 }
)
.addPanel(
  net.bytes_received_per_second(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 12, h: 8, x: 0, y: 33 }
)
.addPanel(
  net.bytes_sent_per_second(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 12, h: 8, x: 12, y: 33 }
)
.addPanel(
  net.net_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 41 }
)
.addPanel(
  net.net_pending(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 41 }
)
.addPanel(
  net.current_connections(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 41 }
)
.addPanel(
  row.new(title='Tarantool memory allocation overview'),
  { w: 24, h: 1, x: 0, y: 49 }
)
.addPanel(
  slab.monitor_info(),
  { w: 24, h: 3, x: 0, y: 50 }
)
.addPanel(
  slab.quota_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 53 }
)
.addPanel(
  slab.arena_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 53 },
)
.addPanel(
  slab.items_used_ratio(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 53 },
)
.addPanel(
  slab.quota_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 61 }
)
.addPanel(
  slab.arena_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 61 },
)
.addPanel(
  slab.items_used(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 61 },
)
.addPanel(
  slab.quota_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 69 }
)
.addPanel(
  slab.arena_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 69 },
)
.addPanel(
  slab.items_size(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 69 },
)
.addPanel(
  row.new(title='Tarantool CPU statistics'),
  { w: 24, h: 1, x: 0, y: 77 }
)
.addPanel(
  cpu.getrusage_cpu_user_time(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 12, h: 8, x: 0, y: 78 },
)
.addPanel(
  cpu.getrusage_cpu_system_time(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 12, h: 8, x: 12, y: 78 },
)
.addPanel(
  row.new(title='Tarantool memory miscellaneous'),
  { w: 24, h: 1, x: 0, y: 86 }
)
.addPanel(
  memory_misc.lua_memory(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 24, h: 8, x: 0, y: 87 },
)
.addPanel(
  row.new(title='Tarantool operations statistics'),
  { w: 24, h: 1, x: 0, y: 95 }
)
.addPanel(
  operations.space_select_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 96 },
)
.addPanel(
  operations.space_insert_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 96 },
)
.addPanel(
  operations.space_replace_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 96 },
)
.addPanel(
  operations.space_upsert_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 104 },
)
.addPanel(
  operations.space_update_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 104 },
)
.addPanel(
  operations.space_delete_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 104 },
)
.addPanel(
  operations.call_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 112 },
)
.addPanel(
  operations.eval_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 112 },
)
.addPanel(
  operations.error_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 112 },
)
.addPanel(
  operations.auth_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 120 },
)
.addPanel(
  operations.SQL_prepare_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 120 },
)
.addPanel(
  operations.SQL_execute_rps(
    datasource=datasource,
    policy=policy,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 120 },
)
