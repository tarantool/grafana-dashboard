// Can't test negative cases here since jsonnet do not have error catch
// https://github.com/google/jsonnet/issues/415

local config = import 'dashboard/build/config.libsonnet';
local config_example = importstr 'config.yml';

{
  default_prometheus: config.prepare({
    type: 'prometheus',
  }),

  default_influxdb: config.prepare({
    type: 'influxdb',
  }),

  example_basic: config.prepare(std.parseYaml(config_example)),

  example_prometheus_dashboard_with_template_variables: config.prepare(std.parseYaml(|||
    type: prometheus
    datasource: '$prometheus'
    filters: {
      job: ['=~', '$job'],
      alias: ['=~', '$alias'],
    }
  |||)),

  example_prometheus_static_dashboard: config.prepare(std.parseYaml(|||
    type: prometheus
    datasource: MyPrometheusWithTarantoolMetrics
    filters: {
      job: ['=', 'MyJobWithTarantoolMetrics'],
    }
  |||)),

  example_prometheus_static_dashboard_with_additional_labels: config.prepare(std.parseYaml(|||
    type: prometheus
    datasource: MyPrometheusWithTarantoolMetrics
    filters: {
      job: ['=', 'MyJobWithTarantoolMetrics'],
      vendor_app_tag: ['=', 'MyCacheApplication'],
    }
  |||)),

  example_prometheus_static_dashboard_with_specific_sections: config.prepare(std.parseYaml(|||
    type: prometheus
    datasource: MyPrometheusWithTarantoolMetrics
    filters: {
      job: ['=', 'MyJobWithTarantoolMetrics'],
    }
    sections:
    - cluster
    - replication
    - http
    - net
    - slab
    - space
    - runtime
    - luajit
    - operations
  |||)),

  example_prometheus_static_TDG_dashboard: config.prepare(std.parseYaml(|||
    type: prometheus
    title: Tarantool Data Grid dashboard
    grafana_tags: [tarantool, TDG]
    datasource: MyPrometheusWithTDGMetrics
    filters: {
      job: ['=', 'MyJobWithTDGMetrics'],
    }
    sections:
    - cluster
    - replication
    - http
    - net
    - slab
    - mvcc
    - space
    - vinyl
    - cpu_extended
    - runtime
    - luajit
    - operations
    - crud
    - tdg_kafka_common
    - tdg_kafka_brokers
    - tdg_kafka_topics
    - tdg_kafka_consumer
    - tdg_kafka_producer
    - expirationd
    - tdg_tuples
    - tdg_file_connectors
    - tdg_graphql
    - tdg_iproto
    - tdg_rest_api
    - tdg_tasks
  |||)),

  example_influxdb_dashboard_with_template_variables: config.prepare(std.parseYaml(|||
    type: influxdb
    datasource: '$influxdb'
    policy: '$policy'
    measurement: '$measurement'
    filters: {
      label_pairs_alias: ['=~', '/^$label_pairs_alias$/'],
    }
  |||)),

  example_influxdb_static_dashboard: config.prepare(std.parseYaml(|||
    type: influxdb
    datasource: MyInfluxDBWithTarantoolMetrics
    policy: default
    measurement: MyMeasurementWithTarantoolMetrics
  |||)),

  filters_truncating: config.prepare({
    type: 'influxdb',
    filters: {
      job: null,
    },
  }),
}
