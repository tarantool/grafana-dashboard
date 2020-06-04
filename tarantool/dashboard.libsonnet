local grafana = import 'grafonnet/grafana.libsonnet';

local http = import 'http.libsonnet';
local slab = import 'slab.libsonnet';

local datasource = 'default';
local measurement = 'example_project_http';

local dashboard = grafana.dashboard.new(
  title='example_project_http',
  description='example dashboard',
  editable=true,
  schemaVersion=21,
  time_from='now-6h',
  time_to='now',
  refresh='30s',
  tags=['tag1', 'tag2'],
);

local datasource = '${DS_INFLUXDB}';
local measurement = '${TARANTOOL_MEASUREMENT}';

dashboard
.addInput(
  name='DS_INFLUXDB',
  label='InfluxDB bank',
  type='datasource',
  pluginId='influxdb',
  pluginName='InfluxDB',
  description='InfluxDB Tarantool metrics bank'
)
.addInput(
  name='TARANTOOL_MEASUREMENT',
  label='Measurement',
  type='constant',
  pluginId=null,
  pluginName=null,
  description='InfluxDB Tarantool metrics measurement'
)
.addRequired(
  type='grafana',
  id='grafana',
  name='Grafana',
  version='6.6.0'
)
.addRequired(
  type='datasource',
  id='influxdb',
  name='InfluxDB',
  version='1.0.0'
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
.addPanel(
  grafana.row.new(title='Tarantool HTTP statistics'),
  { w: 24, h: 1, x: 0, y: 0 }
)
.addPanel(
  http.rps_success(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 1 }
)
.addPanel(
  http.rps_error_4xx(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 1 },
)
.addPanel(
  http.rps_error_5xx(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 1 },
)
.addPanel(
  http.latency_success(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 9 }
)
.addPanel(
  http.latency_error_4xx(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 9 },
)
.addPanel(
  http.latency_error_5xx(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 9 },
)
.addPanel(
  grafana.row.new(title='Tarantool memory overview'),
  { w: 24, h: 1, x: 0, y: 17 }
)
.addPanel(
  slab.monitor_info(),
  { w: 24, h: 3, x: 0, y: 18 }
)
.addPanel(
  slab.quota_used_ratio(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 21 }
)
.addPanel(
  slab.arena_used_ratio(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 21 },
)
.addPanel(
  slab.items_used_ratio(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 21 },
)
.addPanel(
  slab.quota_used(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 29 }
)
.addPanel(
  slab.arena_used(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 29 },
)
.addPanel(
  slab.items_used(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 29 },
)
.addPanel(
  slab.quota_size(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 0, y: 37 }
)
.addPanel(
  slab.arena_size(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 8, y: 37 },
)
.addPanel(
  slab.items_size(
    datasource=datasource,
    measurement=measurement,
  ),
  { w: 8, h: 8, x: 16, y: 37 },
)
