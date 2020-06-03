local grafana = import 'grafonnet/grafana.libsonnet';

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

local measurement = 'example_project_http';
local t = {
  "current": {
    "selected": false,
    "text": measurement,
    "value": measurement
  },
  "hide": 2,
  "label": null,
  "name": "measurement",
  "options": [
    {
      "selected": true,
      "text": measurement,
      "value": measurement
    }
  ],
  "query": measurement,
  "skipUrlSync": false,
  "type": "constant"
};

dashboard
  .addTemplate(t)
  .addPanel(grafana.row.new(title='memory'), {x: 0, y: 0})
  .addPanel(
    slab.monitor_info(), 
    {w: 24, h: 3, x: 0, y: 0})
  .addPanel(
    slab.quota_used_ratio(
      datasource=datasource,
    ),
    {w: 8, h: 8, x: 0, y: 3}
  )
  .addPanel(
    slab.arena_used_ratio(
      datasource=datasource,
    ),
    {w: 8, h: 8, x: 8, y: 3},
  )
  .addPanel(
    slab.items_used_ratio(
      datasource=datasource,
    ),
    {w: 8, h: 8, x: 16, y: 3},
  )
