local grafana = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool space statistics'),

  local count(
    cfg,
    title=null,
    description=null,
    metric_name=null,
    engine=null
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='none',
    decimals=0,
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    common.target(
      cfg,
      metric_name,
      additional_filters={
        [variable.datasource_type.prometheus]: { engine: ['=', engine] },
        [variable.datasource_type.influxdb]: { label_pairs_engine: ['=', engine] },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} — {{name}}',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias — $tag_label_pairs_name',
      },
      group_tags=['label_pairs_alias', 'label_pairs_name'],
      converter='last',
    ),
  ),

  memtx_len(
    cfg,
    title='Number of records (memtx)',
    description=|||
      Number of records in the space (memtx engine).
      Name of space is specified after dash.
    |||,
  ):: count(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_space_len',
    engine='memtx'
  ),

  vinyl_count(
    cfg,
    title='Number of records (vinyl)',
    description=|||
      Number of records in the space (vinyl engine).
      Name of space is specified after dash.
      By default this metrics is disabled,
      to enable it you must set global variable
      include_vinyl_count to true. Beware that
      count() operation scans the space and may
      slow down your app. 

      Panel works with `metrics >= 0.13.0`.
    |||,
  ):: count(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_vinyl_tuples',
    engine='vinyl'
  ),

  local bsize_memtx(
    cfg,
    title=null,
    description=null,
    metric_name=null,
  ) = common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    common.target(
      cfg,
      metric_name,
      additional_filters={
        [variable.datasource_type.prometheus]: { engine: ['=', 'memtx'] },
        [variable.datasource_type.influxdb]: { label_pairs_engine: ['=', 'memtx'] },
      },
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} — {{name}}',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias — $tag_label_pairs_name',
      },
      group_tags=['label_pairs_alias', 'label_pairs_name'],
    ),
  ),

  space_bsize(
    cfg,
    title='Data size (memtx)',
    description=std.join(
      '\n',
      [
        |||
          Total number of bytes in all tuples of the space (memtx engine).
          Name of space is specified after dash.
        |||,
        if cfg.type == variable.datasource_type.influxdb then
          |||
            `No data` may be displayed because of tarantool/metrics issue #321,
            use `metrics >= 0.12.0` to fix.
          |||
        else null,
      ]
    ),
  ):: bsize_memtx(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_space_bsize'
  ),

  space_index_bsize(
    cfg,
    title='Index size',
    description=|||
      Total number of bytes taken by the index.
      Name of space is specified after dash,
      index name specified in parentheses.
      Includes both memtx and vinyl spaces.
    |||,
  ):: common.default_graph(
    cfg,
    title=title,
    description=description,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    common.target(
      cfg,
      'tnt_space_index_bsize',
      legend={
        [variable.datasource_type.prometheus]: '{{alias}} — {{name}} ({{index_name}})',
        [variable.datasource_type.influxdb]: '$tag_label_pairs_alias — $tag_label_pairs_name ($tag_label_pairs_index_name)',
      },
      group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_index_name'],
    ),
  ),

  space_total_bsize(
    cfg,
    title='Total size (memtx)',
    description=std.join(
      '\n',
      [
        |||
          Total size of tuples and all indexes in the space (memtx engine).
          Name of space is specified after dash.
        |||,
        if cfg.type == variable.datasource_type.influxdb then
          |||
            `No data` may be displayed because of tarantool/metrics issue #321,
            use `metrics >= 0.12.0` to fix.
          |||
        else null,
      ]
    ),
  ):: bsize_memtx(
    cfg,
    title=title,
    description=description,
    metric_name='tnt_space_total_bsize'
  ),
}
