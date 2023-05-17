{
  datasource_type: {
    influxdb: 'influxdb',
    prometheus: 'prometheus',
  },
  metrics: {
    // It is expected that every job/measurement with Tarantool metrics would have this one.
    tarantool_indicator: 'tnt_info_uptime',
  },
}
