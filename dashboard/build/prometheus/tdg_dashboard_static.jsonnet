local tdg_dashboard_raw = import 'dashboard/build/prometheus/tdg_dashboard_raw.libsonnet';

tdg_dashboard_raw(
  datasource=std.extVar('DATASOURCE'),
  job=std.extVar('JOB'),
  rate_time_range=std.extVar('RATE_TIME_RANGE'),
).build()
