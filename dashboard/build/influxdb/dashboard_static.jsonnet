local dashboard_raw = import 'dashboard/build/influxdb/dashboard_raw.libsonnet';

dashboard_raw(
  datasource=std.extVar('DATASOURCE'),
  policy=std.extVar('POLICY'),
  measurement=std.extVar('MEASUREMENT'),
).build()
