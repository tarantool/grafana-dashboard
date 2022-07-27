local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('Tarantool space statistics'),

  local count(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    metric_name=null,
    engine=null
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='none',
    decimals=0,
    legend_avg=false,
    legend_max=false,
    panel_width=12,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s", engine="%s"}', [metric_name, job, engine]),
        legendFormat='{{alias}} — {{name}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name',
      ).where('metric_name', '=', metric_name).where('label_pairs_engine', '=', engine)
      .selectField('value').addConverter('last')
  ),

  memtx_len(
    title='Number of records (memtx)',
    description=|||
      Number of records in the space (memtx engine).
      Name of space is specified after dash.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: count(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_space_len',
    engine='memtx'
  ),

  vinyl_count(
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
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: count(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_vinyl_tuples',
    engine='vinyl'
  ),

  local bsize_memtx(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    metric_name=null,
  ) = common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('%s{job=~"%s", engine="memtx"}', [metric_name, job]),
        legendFormat='{{alias}} — {{name}}',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name',
      ).where('metric_name', '=', metric_name).where('label_pairs_engine', '=', 'memtx')
      .selectField('value').addConverter('mean')
  ),

  space_bsize(
    title='Data size (memtx)',
    description=std.join(
      '\n',
      [
        |||
          Total number of bytes in all tuples of the space (memtx engine).
          Name of space is specified after dash.
        |||,
        if datasource_type == variable.datasource_type.influxdb then
          |||
            `No data` may be displayed because of tarantool/metrics issue #321,
            use `metrics >= 0.12.0` to fix.
          |||
        else null,
      ]
    ),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: bsize_memtx(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_space_bsize'
  ),

  space_index_bsize(
    title='Index size',
    description=|||
      Total number of bytes taken by the index.
      Name of space is specified after dash,
      index name specified in parentheses.
      Includes both memtx and vinyl spaces.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    format='bytes',
    legend_avg=false,
    legend_max=false,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format('tnt_space_index_bsize{job=~"%s"}', [job]),
        legendFormat='{{alias}} — {{name}} ({{index_name}})',
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name', 'label_pairs_index_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name ($tag_label_pairs_index_name)',
      ).where('metric_name', '=', 'tnt_space_index_bsize')
      .selectField('value').addConverter('mean')
  ),

  space_total_bsize(
    title='Total size (memtx)',
    description=std.join(
      '\n',
      [
        |||
          Total size of tuples and all indexes in the space (memtx engine).
          Name of space is specified after dash.
        |||,
        if datasource_type == variable.datasource_type.influxdb then
          |||
            `No data` may be displayed because of tarantool/metrics issue #321,
            use `metrics >= 0.12.0` to fix.
          |||
        else null,
      ]
    ),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: bsize_memtx(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_space_total_bsize'
  ),
}
