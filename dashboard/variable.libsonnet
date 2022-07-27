{
  datasource_type: {
    influxdb: 'influxdb',
    prometheus: 'prometheus',
  },
  datasource_var: {
    influxdb: '${DS_INFLUXDB}',
    prometheus: '${DS_PROMETHEUS}',
  },
  prometheus: {
    job: '$job',
    rate_time_range: '$rate_time_range',
  },
  influxdb: {
    policy: '${INFLUXDB_POLICY}',
    measurement: '${INFLUXDB_MEASUREMENT}',
  },
}
