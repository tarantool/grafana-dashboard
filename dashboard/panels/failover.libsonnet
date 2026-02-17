local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local tablePanel = grafana.tablePanel;
local prometheus = grafana.prometheus;

{
  failover_coordinator_row:: common.row('Failover coordinator'),

  coordinators_status(
    cfg,
    title='Coordinators status',
  ):: tablePanel.new(
    title=title,
    datasource=cfg.datasource,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      local filters_obj = common.remove_field(cfg.filters, 'alias');
      local filters = common.prometheus_query_filters(filters_obj);
      local metric = std.format('%starantool_coordinator_active', [cfg.metrics_prefix]);
      prometheus.target(
        expr=if filters == '' then metric else std.format('%s{%s}', [metric, filters]),
        format='table',
        instant=true,
      )
    else
      error 'InfluxDB target is not supported yet'
  ) {

    columns: null,
    styles: null,

    options: {
      cellHeight: 'sm',
      showHeader: true,
    },

    fieldConfig+: {
      overrides+: [
        {
          matcher: { id: 'byName', options: 'status' },
          properties: [
            { id: 'custom.cellOptions', value: { type: 'color-text' } },
            { id: 'type', value: 'number' },
            {
              id: 'mappings',
              value: [
                {
                  type: 'value',
                  options: {
                    '0': { text: 'passive', color: 'yellow' },
                    '1': { text: 'active', color: 'green' },
                  },
                },
                {
                  type: 'special',
                  options: {
                    match: 'null',
                    result: { text: 'disconnected', color: 'red' },
                  },
                },
              ],
            },
          ],
        },
      ],
    },

    transformations: [
      {
        id: 'organize',
        options: {
          excludeByName: {
            Time: true,
            __name__: true,
            instance: true,
            job: true,
          },
          renameByName: {
            Value: 'status',
            alias: 'uuid',
          },
          indexByName: {
            alias: 0,
            Value: 1,
          },
        },
      },
    ],
  },

  instances_seen_by_coordinators(
    cfg,
    title='Instances seen by coordinators',
  ):: tablePanel.new(
    title=title,
    datasource=cfg.datasource,
  ).addTarget(
    if cfg.type == variable.datasource_type.prometheus then
      local filters_obj = common.remove_field(cfg.filters, 'alias');
      local filters = common.prometheus_query_filters(filters_obj);
      local metric = std.format('%starantool_instance_status', [cfg.metrics_prefix]);
      prometheus.target(
        expr=if filters == '' then metric else std.format('%s{%s}', [metric, filters]),
        format='table',
        instant=true,
      )
    else
      error 'InfluxDB target is not supported yet'
  ) {

    columns: null,
    styles: null,
    options: { cellHeight: 'sm', showHeader: true },
    fieldConfig: {
      defaults: {
        custom: {
          align: 'auto',
          cellOptions: { type: 'auto' },
          footer: { reducers: [] },
          inspect: false,
        },
        mappings: [],
        thresholds: {
          mode: 'absolute',
          steps: [
            { color: 'red', value: null },
            { color: 'green', value: 1 },
          ],
        },
      },
      overrides: [
        {
          matcher: { id: 'byName', options: 'status' },
          properties: [
            { id: 'custom.cellOptions', value: { type: 'color-text' } },
            {
              id: 'mappings',
              value: [
                {
                  type: 'value',
                  options: {
                    '0': { color: 'red', text: 'down' },
                    '1': { color: 'green', text: 'alive' },
                  },
                },
                {
                  type: 'special',
                  options: {
                    match: 'nan',
                    result: { color: 'red', text: 'unknown' },
                  },
                },
              ],
            },
          ],
        },
      ],
    },
    transformations: [
      {
        id: 'organize',
        options: {
          excludeByName: {
            Time: true,
            __name__: true,
            job: true,
            exported_job: true,
            endpoint: true,
            namespace: true,
            pod: true,
            service: true,
            instance: true,
          },
          renameByName: {
            alias: 'coordinator uuid',
            exported_instance: 'instance',
            Value: 'status',
          },
        },
      },
      {
        id: 'organize',
        options: {
          indexByName: {
            'coordinator uuid': 0,
            replicaset: 1,
            instance: 2,
            status: 3,
          },
        },
      },
    ],
  },
}
