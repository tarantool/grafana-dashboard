local grafana = import 'grafonnet/grafana.libsonnet';

local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  kafka_target(
    cfg,
    metric_name,
  )::
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s",alias=~"%s"}', [metric_name, cfg.filters.job[1], cfg.filters.alias[1]]),
        legendFormat='{{name}} — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_type', 'label_pairs_connector_name'],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias[1])
      .selectField('value').addConverter('mean'),

  kafka_rps_target(
    cfg,
    metric_name,
  )::
    if cfg.type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s",alias=~"%s"}[$__rate_interval])',
                        [metric_name, cfg.filters.job[1], cfg.filters.alias[1]]),
        legendFormat='{{name}} — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if cfg.type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=cfg.policy,
        measurement=cfg.measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_type', 'label_pairs_connector_name'],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
        fill='null',
      ).where('metric_name', '=', metric_name)
      .where('label_pairs_alias', '=~', cfg.filters.label_pairs_alias[1])
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
}
