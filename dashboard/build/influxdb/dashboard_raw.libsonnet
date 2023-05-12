local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/dashboard.libsonnet';
local section = import 'dashboard/section.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

function(cfg) dashboard.new(
  grafana.dashboard.new(
    title=cfg.title,
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
    version='8.0.0'
  ).addRequired(
    type='panel',
    id='graph',
    name='Graph',
    version=''
  ).addRequired(
    type='panel',
    id='timeseries',
    name='Timeseries',
    version=''
  ).addRequired(
    type='panel',
    id='text',
    name='Text',
    version=''
  ).addRequired(
    type='datasource',
    id='influxdb',
    name='InfluxDB',
    version='1.0.0'
  )
).addPanels(
  section.cluster_influxdb(cfg)
).addPanels(
  section.replication(cfg)
).addPanels(
  section.http(cfg)
).addPanels(
  section.net(cfg)
).addPanels(
  section.slab(cfg)
).addPanels(
  section.mvcc(cfg)
).addPanels(
  section.space(cfg)
).addPanels(
  section.vinyl(cfg)
).addPanels(
  section.cpu(cfg)
).addPanels(
  section.runtime(cfg)
).addPanels(
  section.luajit(cfg)
).addPanels(
  section.operations(cfg)
).addPanels(
  section.crud(cfg)
).addPanels(section.expirationd(cfg))
