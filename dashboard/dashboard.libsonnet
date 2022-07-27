local utils = import 'dashboard/utils.libsonnet';

{
  new(
    grafana_dashboard,
    panels=[],
  ):: {
    _grafana_dashboard: grafana_dashboard,
    _panels: panels,
    addPanel(panel):: self { _panels+: [panel] },
    addPanels(panels):: self { _panels+: panels },
    addInput(
      name,
      label,
      type,
      pluginId=null,
      pluginName=null,
      description='',
      value=null,
    ):: self {
      _grafana_dashboard: super._grafana_dashboard.addInput(
        name,
        label,
        type,
        pluginId,
        pluginName,
        description,
        value
      ),
    },
    addTemplate(t):: self { _grafana_dashboard: super._grafana_dashboard.addTemplate(t) },
    build():: self._grafana_dashboard.addPanels(utils.collapse_rows(utils.generate_grid(self._panels))),
  },
}
