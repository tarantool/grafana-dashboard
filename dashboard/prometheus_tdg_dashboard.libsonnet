local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/dashboard.libsonnet';
local section = import 'dashboard/section.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

dashboard.new(
  grafana.dashboard.new(
    title='Tarantool Data Grid dashboard',
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
).addPanels(
  section.cluster_prometheus(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.net(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.slab(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.space(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.vinyl(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.cpu_extended(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.runtime(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.luajit(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.operations(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_kafka_common(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_kafka_brokers(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_kafka_topics(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_kafka_consumer(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_kafka_producer(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_expirationd(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_tuples(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_file_connectors(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_graphql(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_iproto(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_rest_api(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
).addPanels(
  section.tdg_tasks(
    datasource_type=variable.datasource_type.prometheus,
    datasource=variable.datasource_var.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range,
  )
)
