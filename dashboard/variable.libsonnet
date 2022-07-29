{
  datasource_type: {
    influxdb: 'influxdb',
    prometheus: 'prometheus',
  },
  datasource: {
    influxdb: '${DS_INFLUXDB}',
    prometheus: '${DS_PROMETHEUS}',
  },
  prometheus: {
    job: '$job',
  },
  influxdb: {
    policy: '${INFLUXDB_POLICY}',
    measurement: '${INFLUXDB_MEASUREMENT}',
  },
}
