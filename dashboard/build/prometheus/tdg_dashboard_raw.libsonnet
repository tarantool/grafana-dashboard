local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/dashboard.libsonnet';
local section = import 'dashboard/section.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

function(cfg) dashboard.new(
  grafana.dashboard.new(
    title=cfg.title,
    description='Dashboard for Tarantool Data Grid ver. 2 application monitoring, based on grafonnet library.',
    editable=true,
    schemaVersion=21,
    time_from='now-3h',
    time_to='now',
    refresh='30s',
    tags=['tarantool', 'TDG'],
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
  )
).addPanels(
  section.cluster_prometheus(cfg)
).addPanels(
  section.replication(cfg)
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
  section.cpu_extended(cfg)
).addPanels(
  section.runtime(cfg)
).addPanels(
  section.luajit(cfg)
).addPanels(
  section.operations(cfg)
).addPanels(
  section.tdg_kafka_common(cfg)
).addPanels(
  section.tdg_kafka_brokers(cfg)
).addPanels(
  section.tdg_kafka_topics(cfg)
).addPanels(
  section.tdg_kafka_consumer(cfg)
).addPanels(
  section.tdg_kafka_producer(cfg)
).addPanels(
  section.expirationd(cfg)
).addPanels(
  section.tdg_tuples(cfg)
).addPanels(
  section.tdg_file_connectors(cfg)
).addPanels(
  section.tdg_graphql(cfg)
).addPanels(
  section.tdg_iproto(cfg)
).addPanels(
  section.tdg_rest_api(cfg)
).addPanels(section.tdg_tasks(cfg))
