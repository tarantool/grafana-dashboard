local timeseries = import 'dashboard/grafana/timeseries.libsonnet';

timeseries.new(
  title='title',
  description='description',
  datasource='datasource',
  panel_height=6,
  panel_width=7,
  max=1,
  min=0,
  unit='s',
).addTarget({ target: 'target' })
.addValueMapping(1, 'green', 'ok')
.addValueMapping(0, 'red', 'error')
.addRangeMapping(0.001, 0.999, '-')
