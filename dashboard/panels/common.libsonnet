local grafana = import 'grafonnet/grafana.libsonnet';

local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

local prometheus_query_filters(filters) = std.join(
  ',',
  std.map(
    function(key)
      std.format('%s%s"%s"', [key, filters[key][0], filters[key][1]]),
    std.objectFields(filters)
  )
);

local influxdb_query_filters(filters) = std.join(' AND ', std.map(
  function(key)
    local condition = filters[key][0];
    local value = filters[key][1];
    if std.startsWith(value, '/') && std.endsWith(value, '/') then  //regex condition
      std.format('"%s" %s %s', [key, condition, value])
    else
      std.format('"%s" %s \'%s\'', [key, condition, value]),
  std.objectFields(filters)
));

{
  default_graph(
    cfg,
    title=null,
    description=null,
    format='none',
    min=null,
    max=null,
    labelY1=null,
    fill=0,
    decimals=2,
    decimalsY1=0,
    legend_avg=true,
    legend_max=true,
    legend_rightSide=false,
    panel_height=8,
    panel_width=8,
  ):: grafana.graphPanel.new(
    title=title,
    description=description,
    datasource=cfg.datasource,

    format=format,
    min=min,
    max=max,
    labelY1=labelY1,
    fill=fill,
    decimals=decimals,
    decimalsY1=decimalsY1,
    sort='decreasing',
    legend_alignAsTable=true,
    legend_avg=legend_avg,
    legend_current=true,
    legend_max=legend_max,
    legend_rightSide=legend_rightSide,
    legend_values=true,
    legend_sort='current',
    legend_sortDesc=true,
  ) { gridPos: { w: panel_width, h: panel_height } },

  row(title):: grafana.row.new(title, collapse=true) { gridPos: { w: 24, h: 1 } },

  prometheus_query_filters:: prometheus_query_filters,
  influxdb_query_filters:: influxdb_query_filters,

  target(
    cfg,
    metric_name,
    additional_filters={
      [variable.datasource_type.prometheus]: {},
      [variable.datasource_type.influxdb]: {},
    },
    legend={
      [variable.datasource_type.prometheus]: '{{alias}}',
      [variable.datasource_type.influxdb]: '$tag_label_pairs_alias',
    },
    group_tags=['label_pairs_alias'],  // influxdb only
    converter='mean',  // influxdb only
    rate=false,
  )::
    local filters = additional_filters[cfg.type] + cfg.filters;
    if cfg.type == variable.datasource_type.prometheus then
      local expr = std.format('%s%s{%s}', [cfg.metrics_prefix, metric_name, prometheus_query_filters(filters)]);
      prometheus.target(
        expr=if rate then std.format('rate(%s[$__rate_interval])', expr) else expr,
        legendFormat=legend[cfg.type],
      )
    else if cfg.type == variable.datasource_type.influxdb then
      local target = std.foldl(
        function(target, key)
          target.where(key, filters[key][0], filters[key][1]),
        std.objectFields(filters),
        influxdb.target(
          policy=cfg.policy,
          measurement=cfg.measurement,
          group_tags=group_tags,
          alias=legend[cfg.type],
          fill='null',
        ).where('metric_name', '=', std.format('%s%s', [cfg.metrics_prefix, metric_name]))
      ).selectField('value').addConverter(converter);
      if rate then target.addConverter('non_negative_derivative', ['1s']) else target,

  group_by_fill_0_warning(
    cfg,
    description,
  )::
    if cfg.type == variable.datasource_type.influxdb then
      std.join('\n', [description, |||
        Current value may be 0 from time to time due to fill(0)
        and GROUP BY including partial intervals.
        Refer to https://github.com/influxdata/influxdb/issues/8244
        for updates.
      |||])
    else
      description,

  remove_field(obj, key)::
    { [item.key]: item.value for item in std.objectKeysValuesAll(obj) if item.key != key },
}
