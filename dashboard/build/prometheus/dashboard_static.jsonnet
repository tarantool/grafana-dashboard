local dashboard_raw = import 'dashboard/build/prometheus/dashboard_raw.libsonnet';

dashboard_raw(
  datasource=std.extVar('DATASOURCE'),
  job=std.extVar('JOB'),
  rate_time_range=std.extVar('RATE_TIME_RANGE'),
).build()
