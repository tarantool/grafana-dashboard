local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local common_utils = import 'dashboard/panels/common.libsonnet';

{
  kafka_target(
    cfg,
    metric_name,
    rate=false,
  ):: common_utils.target(
    cfg,
    metric_name,
    legend={
      prometheus: '{{name}} — {{alias}} ({{type}}, {{connector_name}})',
      influxdb: '$tag_label_pairs_name — $tag_label_pairs_alias ($tag_label_pairs_type, $tag_label_pairs_connector_name)',
    },
    group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_type', 'label_pairs_connector_name'],
    rate=rate,
  ),
}
