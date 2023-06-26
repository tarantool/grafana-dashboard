local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';

{
  row:: common.row('expirationd module statistics'),

  local target(cfg, metric_name, rate=false) =
    common.target(
      cfg,
      metric_name,
      legend={
        prometheus: '{{name}} — {{alias}}',
        influxdb: '$tag_label_pairs_name — $tag_label_pairs_alias',
      },
      group_tags=['label_pairs_alias', 'label_pairs_name'],
      rate=rate,
    ),

  tuples_checked(
    cfg,
    title='Tuples checked',
    description=|||
      A number of task tuples checked for expiration (expired + skipped).
      Graph shows mean tuples per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(
    target(cfg, 'expirationd_checked_count', rate=true)
  ),

  tuples_expired(
    cfg,
    title='Tuples expired',
    description=|||
      A number of task expired tuples.
      Graph shows mean tuples per second.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    labelY1='tuples per second',
    panel_width=12,
  ).addTarget(
    target(cfg, 'expirationd_expired_count', rate=true)
  ),

  restarts(
    cfg,
    title='Restart count',
    description=|||
      A number of task restarts since start.
      From the start is equal to 1.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    decimals=0,
    panel_width=12,
  ).addTarget(
    target(cfg, 'expirationd_restarts')
  ),

  operation_time(
    cfg,
    title='Operation time',
    description=|||
      A task's operation time.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='s',
    panel_width=12,
  ).addTarget(
    target(cfg, 'expirationd_working_time')
  ),
}
