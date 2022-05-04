{
  /**
   * There is no way to make a 8.x timeseries panel with
   * grafana/grafonnet-lib tools for now (7.x subfolder graph
   * is incompatible).
   *
   * This is a rough draft of a tool to make a 8.x timeseries panel.
   *
   * @name timeseries.new
   *
   * @param title The title of the panel.
   * @param description (optional) The description of the panel.
   * @param datasource (optional) Datasource.
   * @param panel_height (optional) Panel height in grid units.
   * @param panel_width (optional) Panel width in grid units.
   * @param min (optional) Min of the Y axes.
   * @param max (optional) Max of the Y axes.
   * @param unit (optional) Y axes unit.
   *
   * @method addTarget(target) Adds a target object.
   * @method addTargets(targets) Adds an array of targets.
   */
  new(
    title,
    description=null,
    datasource=null,
    panel_height=8,
    panel_width=8,
    max=null,
    min=null,
    unit='none',
  ):: {
    title: title,
    datasource: datasource,
    fieldConfig: {
      defaults: {
        color: {
          mode: 'palette-classic',
        },
        custom: {
          axisLabel: '',
          axisPlacement: 'auto',
          barAlignment: 0,
          drawStyle: 'line',
          fillOpacity: 0,
          gradientMode: 'none',
          hideFrom: {
            legend: false,
            tooltip: false,
            viz: false,
          },
          lineInterpolation: 'linear',
          lineWidth: 1,
          pointSize: 5,
          scaleDistribution: {
            type: 'linear',
          },
          showPoints: 'never',
          spanNulls: false,
          stacking: {
            group: 'A',
            mode: 'none',
          },
          thresholdsStyle: {
            mode: 'off',
          },
        },
        mappings: [],
        max: max,
        min: min,
        thresholds: {
          mode: 'absolute',
          steps: [],
        },
      },
      overrides: [],
    },
    targets: [],
    [if description != null then 'description']: description,
    type: 'timeseries',
    _nextTarget:: 0,
    gridPos: { w: panel_width, h: panel_height },
    options: {
      legend: {
        calcs: ['last'],
        displayMode: 'table',
        placement: 'right',
      },
      tooltip: {
        mode: 'multi',
      },
    },

    addTarget(target):: self {
      // automatically ref id in added targets.
      // https://github.com/kausalco/public/blob/master/klumps/grafana.libsonnet
      local nextTarget = super._nextTarget,
      _nextTarget: nextTarget + 1,
      targets+: [target { refId: std.char(std.codepoint('A') + nextTarget) }],
    },

    addTargets(targets):: std.foldl(function(p, t) p.addTarget(t), targets, self),

    addValueMapping(value, color, text):: self {
      local fieldConfig = super.fieldConfig,

      fieldConfig: fieldConfig {
        defaults: fieldConfig.defaults {
          mappings: fieldConfig.defaults.mappings + [{
            options: {
              [std.toString(value)]: {
                color: color,
                index: 0,
                text: text,
              },
            },
            type: 'value',
          }],
        },
      },
    },

    addRangeMapping(from, to, text):: self {
      local fieldConfig = super.fieldConfig,

      fieldConfig: fieldConfig {
        defaults: fieldConfig.defaults {
          mappings: fieldConfig.defaults.mappings + [{
            options: {
              from: from,
              result: {
                index: 0,
                text: text,
              },
              to: to,
            },
            type: 'range',
          }],
        },
      },
    },
  },
}
