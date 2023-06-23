local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local dashboard = import 'dashboard/dashboard.libsonnet';
local panels_common = import 'dashboard/panels/common.libsonnet';
local section = import 'dashboard/section.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local fill_requirements(cfg, dashboard_template) =
  if cfg.type == variable.datasource_type.prometheus then
    dashboard_template.addRequired(
      type='panel',
      id='stat',
      name='Stat',
      version='',
    ).addRequired(
      type='panel',
      id='table',
      name='Table',
      version='',
    ).addRequired(
      type='datasource',
      id='prometheus',
      name='Prometheus',
      version='1.0.0'
    )
  else if cfg.type == variable.datasource_type.influxdb then
    dashboard_template.addRequired(
      type='datasource',
      id='influxdb',
      name='InfluxDB',
      version='1.0.0'
    );

local template_rules = {
  [variable.datasource_type.prometheus]: [
    {
      condition(cfg):: std.startsWith(cfg.datasource, '$'),
      template(cfg):: grafana.template.datasource(
        name=std.lstripChars(cfg.datasource, '$'),
        query='prometheus',
        current=null,
        label='Datasource',
      ),
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
            variable.metrics.tarantool_indicator,
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
  [variable.datasource_type.influxdb]: [
    {
      condition(cfg):: std.startsWith(cfg.datasource, '$'),
      template(cfg):: grafana.template.datasource(
        name=std.lstripChars(cfg.datasource, '$'),
        query='influxdb',
        current=null,
        label='Datasource',
      ),
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
              variable.metrics.tarantool_indicator,
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

local fill_templates(cfg, dashboard_template) = std.foldl(
  function(dashboard_template, template_variable)
    if template_variable.condition(cfg) then
      dashboard_template.addTemplate(template_variable.template(cfg))
    else
      dashboard_template,
  template_rules[cfg.type],
  dashboard_template
);

function(cfg) std.foldl(
  function(dashboard, key)
    dashboard.addPanels(section[key](cfg)),
  cfg.sections,
  dashboard.new(
    // TODO: requirements based on cfg.sections
    fill_templates(cfg, fill_requirements(
      cfg,
      grafana.dashboard.new(
        title=cfg.title,
        description=cfg.description,
        editable=true,
        schemaVersion=21,
        time_from='now-3h',
        time_to='now',
        refresh='30s',
        tags=cfg.grafana_tags,
      ).addRequired(
        type='grafana',
        id='grafana',
        name='Grafana',
        version='8.0.0'
      ).addRequired(
        type='panel',
        id='graph',
        name='Graph',
        version=''
      ).addRequired(
        type='panel',
        id='timeseries',
        name='Timeseries',
        version=''
      ).addRequired(
        type='panel',
        id='text',
        name='Text',
        version=''
      )
    ))
  )
)
