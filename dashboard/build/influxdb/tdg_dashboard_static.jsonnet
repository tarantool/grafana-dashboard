local tdg_dashboard_raw = import 'dashboard/build/influxdb/tdg_dashboard_raw.libsonnet';

tdg_dashboard_raw(
  datasource=std.extVar('DATASOURCE'),
  policy=std.extVar('POLICY'),
  measurement=std.extVar('MEASUREMENT'),
).build()
