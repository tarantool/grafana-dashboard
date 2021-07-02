local utils = import 'utils.libsonnet';

{
  new(
    grafana_dashboard,
    panels=[],
  ):: {
    _grafana_dashboard: grafana_dashboard,
    _panels: panels,
    addPanels(panels):: self { _panels+: panels },
    build():: self._grafana_dashboard.addPanels(utils.generate_grid(self._panels)),
  },
}