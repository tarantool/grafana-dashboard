local grafana = import 'grafonnet/grafana.libsonnet';

local dashboard = import 'dashboard/dashboard.libsonnet';
local section = import 'dashboard/section.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

function(cfg) std.foldl(
  function(dashboard, key)
    dashboard.addPanels(section[key](cfg)),
  cfg.sections,
  dashboard.new(  // TODO: requirements based on cfg.sections
    grafana.dashboard.new(
      title=cfg.title,
      description='Dashboard for Tarantool application and database server monitoring, based on grafonnet library.',
      editable=true,
      schemaVersion=21,
      time_from='now-3h',
      time_to='now',
      refresh='30s',
      tags=['tarantool'],
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
    ).addRequired(
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
  )
)
