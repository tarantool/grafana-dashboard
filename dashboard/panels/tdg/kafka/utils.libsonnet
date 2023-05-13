local grafana = import 'grafonnet/grafana.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  kafka_target(
    cfg,
    metric_name,
    rate=false,
  ):: common_utils.target(
    cfg,
    metric_name,
    legend={
      [variable.datasource_type.prometheus]: '{{name}} — {{alias}} ({{type}}, {{connector_name}})',
      [variable.datasource_type.influxdb]: '$tag_label_pairs_name — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
    },
    group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_type', 'label_pairs_connector_name'],
    rate=rate,
  ),
}
