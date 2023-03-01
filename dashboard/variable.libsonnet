{
  datasource_type: {
    influxdb: 'influxdb',
    prometheus: 'prometheus',
  },
  datasource: {
    influxdb: '$influxdb',
    prometheus: '$prometheus',
  },
  prometheus: {
    job: '$job',
    alias: '$alias',
  },
  influxdb: {
    policy: '$policy',
    measurement: '$measurement',
    alias: '/^$alias$/',
  },
  metrics: {
    // It is expected that every job/measurement with Tarantool metrics would have this one.
    tarantool_indicator: 'tnt_info_uptime',
  },
}
