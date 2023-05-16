local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/dashboard.libsonnet';
local section = import 'dashboard/section.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

function(cfg) std.foldl(
  function(dashboard, key)
    dashboard.addPanels(section[key](cfg)),
  cfg.sections,
  dashboard.new(
    // TODO: requirements based on cfg.sections
    local dashboard_template = grafana.dashboard.new(
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
    );
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
      ),
  )
)
