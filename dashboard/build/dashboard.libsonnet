local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local panels_common = import 'dashboard/panels/common.libsonnet';
local section = import 'dashboard/section.libsonnet';
local const = import 'dashboard/const.libsonnet';

local variable_rules = {
  prometheus: [
    {
      condition(cfg):: std.startsWith(cfg.datasource, '$'),
      template(cfg):: grafana.dashboard.variable.datasource(std.lstripChars(cfg.datasource, '$'), 'prometheus'),
    },
    {
      condition(cfg):: std.objectHas(cfg.filters, 'job') && std.startsWith(cfg.filters.job[1], '$'),
      template(cfg):: grafana.template.new(
        name=std.lstripChars(cfg.filters.job[1], '$'),
        datasource=cfg.datasource,
        query=std.format('label_values(%s%s,job)', [cfg.metrics_prefix, variable.metrics.tarantool_indicator]),
        label='Prometheus job',
        refresh='load',
      ),
    },
    {
      condition(cfg):: std.objectHas(cfg.filters, 'alias') && std.startsWith(cfg.filters.alias[1], '$'),
      template(cfg):: grafana.template.new(
        name=std.lstripChars(cfg.filters.alias[1], '$'),
        datasource=cfg.datasource,
        query=std.format(
          'label_values(%s%s{%s},alias)',
          [
            cfg.metrics_prefix,
            const.metrics.tarantool_indicator,
            panels_common.prometheus_query_filters(panels_common.remove_field(cfg.filters, 'alias')),
          ]
        ),
        includeAll=true,
        multi=true,
        current='all',
        label='Instances',
        refresh='time',
      ),
    },
  ],
  influxdb: [
    {
      condition(cfg):: std.startsWith(cfg.datasource, '$'),
      template(cfg):: grafana.dashboard.variable.datasource(std.lstripChars(cfg.datasource, '$'), 'influxdb'),
    },
    {
      condition(cfg):: std.startsWith(cfg.policy, '$'),
      template(cfg):: grafana.template.new(
        name=std.lstripChars(cfg.policy, '$'),
        datasource=cfg.datasource,
        query='SHOW RETENTION POLICIES',
        label='Retention policy',
        refresh='load',
      ),
    },
    {
      condition(cfg):: std.startsWith(cfg.measurement, '$'),
      template(cfg)::
        local filters = panels_common.influxdb_query_filters(panels_common.remove_field(cfg.filters, 'label_pairs_alias'));
        grafana.template.new(
          name=std.lstripChars(cfg.measurement, '$'),
          datasource=cfg.datasource,
          query=std.format(
            'SHOW MEASUREMENTS WHERE "metric_name"=\'%s%s\'%s',
            [
              cfg.metrics_prefix,
              const.metrics.tarantool_indicator,
              if filters == '' then '' else std.format(' AND %s', filters),
            ]
          ),
          label='Measurement',
          refresh='load',
        ),
    },
    {
      condition(cfg):: std.objectHas(cfg.filters, 'label_pairs_alias') &&
                       std.startsWith(cfg.filters.label_pairs_alias[1], '/^$') &&
                       std.endsWith(cfg.filters.label_pairs_alias[1], '$/'),
      template(cfg)::
        local filters = panels_common.influxdb_query_filters(panels_common.remove_field(cfg.filters, 'label_pairs_alias'));
        grafana.template.new(
          name=std.rstripChars(std.lstripChars(cfg.filters.label_pairs_alias[1], '/^$'), '$/'),
          datasource=cfg.datasource,
          query=std.format(
            'SHOW TAG VALUES FROM %s"%s" WITH KEY="label_pairs_alias"%s',
            [
              if cfg.policy == 'default' then '' else std.format('"%s".', cfg.policy),
              cfg.measurement,
              if filters == '' then '' else std.format(' WHERE %s', filters),
            ]
          ),
          includeAll=true,
          multi=true,
          current='all',
          label='Instances',
          refresh='time',
        ),
    },
  ],
};

local fill_variables(cfg, dashboard_template) = std.foldl(
  function(dashboard_template, variable)
    if template_variable.condition(cfg) then
      dashboard_template + grafana.dashboard.withTemplating(variable.template(cfg))
    else
      dashboard_template,
  template_rules[cfg.type],
  dashboard_template
);

function(cfg) std.foldl(
  function(dashboard, key)
    dashboard + grafana.dashboard.withPanels(section[key](cfg)),
  cfg.sections,
  fill_variables(cfg,
    grafana.dashboard.new(cfg.title)
    + grafana.dashboard.withDescription(cfg.description)
    + grafana.dashboard.withEditable()
    + grafana.dashboard.time.withFrom('now-3h')
    + grafana.dashboard.time.withTo('now')
    + grafana.dashboard.withTags(cfg.grafana_tags)
  )
)
