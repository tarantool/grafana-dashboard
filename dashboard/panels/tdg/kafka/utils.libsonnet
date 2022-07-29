local grafana = import 'grafonnet/grafana.libsonnet';

local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  kafka_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  )::
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s"}', [metric_name, job]),
        legendFormat='{{name}} — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_type', 'label_pairs_connector_name'],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean'),

  kafka_rps_target(
    datasource_type,
    metric_name,
    job=null,
    policy=null,
    measurement=null,
  )::
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('rate(%s{job=~"%s"}[$__rate_interval])',
                        [metric_name, job]),
        legendFormat='{{name}} — {{alias}} ({{type}}, {{connector_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_type', 'label_pairs_connector_name'],
        alias='$tag_label_pairs_name — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
      ).where('metric_name', '=', metric_name)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s']),
}
