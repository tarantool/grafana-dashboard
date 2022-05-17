local common = import 'common.libsonnet';
local grafana = import 'grafonnet/grafana.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

{
  row:: common.row('CRUD module statistics'),

  local crud_warning(description) = std.join(
    '\n',
    [description, |||
      CRUD 0.11.0 or newer is required to use statistics.
      Enable statistics with `crud.cfg{stats = true, stats_driver = 'metrics'}`
    |||]
  ),

  local crud_quantile_warning(description) = std.join(
    '\n',
    [description, |||
      CRUD 0.11.0 or newer is required to use statistics.
      Enable quantiles with `crud.cfg{stats = true, stats_driver = 'metrics', stats_quantiles = true}`.
      If `No data` displayed yet data expected, try to calibrate tolerated error with
      `crud.cfg{stats_quantile_tolerated_error=1e-4}`.
    |||]
  ),

  local status_text(status) = (if status == 'ok' then 'success' else 'error'),

  local operation_rps_template(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    operation=null,
    status=null,
  ) = common.default_graph(
    title=(
      if title != null then
        title
      else
        std.format('%s %s requests', [std.asciiUpper(operation), status_text(status)])
    ),
    description=common.rate_warning(description, datasource),
    datasource=datasource,
    min=0,
    labelY1='requests per second',
    decimals=2,
    decimalsY1=2,
    panel_height=8,
    panel_width=6,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format(
          'rate(tnt_crud_stats_count{job=~"%s",operation="%s",status="%s"}[%s])',
          [job, operation, status, rate_time_range]
        ),
        legendFormat='{{alias}} — {{name}}'
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name',
      ).where('metric_name', '=', 'tnt_crud_stats_count')
      .where('label_pairs_operation', '=', operation)
      .where('label_pairs_status', '=', status)
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  local operation_latency_template(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    operation=null,
    status=null,
  ) = common.default_graph(
    title=(
      if title != null then
        title
      else
        std.format('%s %s requests latency', [std.asciiUpper(operation), status_text(status)])
    ),
    description=description,
    datasource=datasource,
    format='s',
    min=0,
    labelY1='99th percentile',
    decimals=2,
    decimalsY1=3,
    panel_height=8,
    panel_width=6,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format(
          'tnt_crud_stats{job=~"%s",operation="%s",status="%s",quantile="0.99"}',
          [job, operation, status]
        ),
        legendFormat='{{alias}} — {{name}}'
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name',
      ).where('metric_name', '=', 'tnt_crud_stats')
      .where('label_pairs_operation', '=', operation)
      .where('label_pairs_status', '=', status)
      .where('label_pairs_quantile', '=', '0.99')
      .selectField('value').addConverter('mean')
  ),

  local operation_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    operation=null,
    status=null,
  ) = operation_rps_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_warning(std.format(|||
          Total count of %s %s requests to cluster spaces with CRUD module.
          Graph shows average requests per second.
        |||, [status_text(status), operation]))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation=operation,
    status=status,
  ),

  local operation_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    operation=null,
    status=null,
  ) = operation_latency_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_quantile_warning(std.format(|||
          99th percentile of %s %s CRUD module requests latency with aging.
        |||, [status_text(status), operation]))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation=operation,
    status=status,
  ),

  local operation_rps_object(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    operation=null,
    status=null,
  ) = operation_rps_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_warning(std.format(|||
          Total count of %s %s and %s_object requests to cluster spaces with CRUD module.
          Graph shows average requests per second.
        |||, [status_text(status), operation, operation]))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation=operation,
    status=status,
  ),

  local operation_latency_object(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    operation=null,
    status=null,
  ) = operation_latency_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_quantile_warning(std.format(|||
          99th percentile of %s %s and %s_object CRUD module requests latency with aging.
        |||, [status_text(status), operation, operation]))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation=operation,
    status=status,
  ),

  local operation_rps_select(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    status=null,
  ) = operation_rps_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_warning(std.format(|||
          Total count of %s SELECT and PAIRS requests to cluster spaces with CRUD module.
          Graph shows average requests per second.
        |||, status_text(status)))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='select',
    status=status,
  ),

  local operation_latency_select(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    operation=null,
    status=null,
  ) = operation_latency_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_quantile_warning(std.format(|||
          99th percentile of %s SELECT and PAIRS CRUD module requests latency with aging.
        |||, status_text(status)))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='select',
    status=status,
  ),

  local operation_rps_borders(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    status=null,
  ) = operation_rps_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_warning(std.format(|||
          Total count of %s MIN and MAX requests to cluster spaces with CRUD module.
          Graph shows average requests per second.
        |||, status_text(status)))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='borders',
    status=status,
  ),

  local operation_latency_borders(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    operation=null,
    status=null,
  ) = operation_latency_template(
    title=title,
    description=(
      if description != null then
        description
      else
        crud_quantile_warning(std.format(|||
          99th percentile of %s MIN and MAX CRUD module requests latency with aging.
        |||, status_text(status)))
    ),
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='borders',
    status=status,
  ),

  local tuples_panel(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
    metric_name=null,
  ) = common.default_graph(
    title=title,
    description=common.group_by_fill_0_warning(
      common.rate_warning(
        crud_warning(description),
        datasource,
      ),
      datasource,
    ),
    datasource=datasource,
    min=0,
    labelY1='tuples per request',
    panel_height=8,
    panel_width=8,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format(
          |||
            rate(%(metric_name)s{job=~"%(job)s",operation="select"}[%(rate_time_range)s]) /
            (sum without (status) (rate(tnt_crud_stats_count{job=~"%(job)s",operation="select"}[%(rate_time_range)s])))
          |||,
          {
            metric_name: metric_name,
            job: job,
            rate_time_range: rate_time_range,
          }
        ),
        legendFormat='{{alias}} — {{name}}'
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        rawQuery=true,
        query=std.format(|||
          SELECT mean("%(metric_name)s") / (mean("tnt_crud_stats_count_ok") + mean("tnt_crud_stats_count_error"))
          as "tnt_crud_tuples_per_request" FROM
          (SELECT "value" as "%(metric_name)s" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = '%(metric_name)s' AND "label_pairs_operation" = 'select') AND $timeFilter),
          (SELECT "value" as "tnt_crud_stats_count_error" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = 'tnt_crud_stats_count' AND "label_pairs_operation" = 'select'
          AND "label_pairs_status" = 'error') AND $timeFilter),
          (SELECT "value" as "tnt_crud_stats_count_ok" FROM %(policy_prefix)s"%(measurement)s"
          WHERE ("metric_name" = 'tnt_crud_stats_count' AND "label_pairs_operation" = 'select'
          AND "label_pairs_status" = 'ok') AND $timeFilter)
          GROUP BY time($__interval * 2), "label_pairs_alias", "label_pairs_name" fill(0)
        |||, {
          metric_name: metric_name,
          policy_prefix: if policy == 'default' then '' else std.format('"%(policy)s".', policy),
          measurement: measurement,
        }),
        alias='$tag_label_pairs_alias — $tag_label_pairs_name'
      )
  ),

  select_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_select(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    status='ok',
  ),

  select_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_select(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='ok',
  ),

  select_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_select(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    status='error',
  ),

  select_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_select(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='error',
  ),

  tuples_fetched_panel(
    title='SELECT tuples fetched',
    description=|||
      Average number of tuples fetched during SELECT/PAIRS request for a space.
      Both success and error requests are taken into consideration.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: tuples_panel(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name='tnt_crud_tuples_fetched',
  ),

  tuples_lookup_panel(
    title='SELECT tuples lookup',
    description=|||
      Average number of tuples looked up on storages while collecting responses
      for SELECT/PAIRS requests (including scrolls for multibatch requests)
      for a space. Both success and error requests are taken into consideration.
    |||,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: tuples_panel(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    metric_name='tnt_crud_tuples_lookup',
  ),

  map_reduces(
    title='Map reduce SELECT requests',
    description=common.rate_warning(
      crud_warning(|||
        Number of SELECT and PAIRS requests that resulted in map reduce.
        Graph shows average requests per second.
        Both success and error requests are taken into consideration.
      |||),
      datasource,
    ),
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    min=0,
    labelY1='requests per second',
    panel_height=8,
    panel_width=8,
  ).addTarget(
    if datasource == '${DS_PROMETHEUS}' then
      prometheus.target(
        expr=std.format(
          'rate(tnt_crud_map_reduces{job=~"%s",operation="select"}[%s])',
          [job, rate_time_range],
        ),
        legendFormat='{{alias}} — {{name}}'
      )
    else if datasource == '${DS_INFLUXDB}' then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name',
      ).where('metric_name', '=', 'tnt_crud_map_reduces')
      .where('label_pairs_operation', '=', 'select')
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  insert_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='insert',
    status='ok',
  ),

  insert_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='insert',
    status='ok',
  ),

  insert_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='insert',
    status='error',
  ),

  insert_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='insert',
    status='error',
  ),

  replace_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='replace',
    status='ok',
  ),

  replace_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='replace',
    status='ok',
  ),

  replace_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='replace',
    status='error',
  ),

  replace_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='replace',
    status='error',
  ),

  upsert_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='upsert',
    status='ok',
  ),

  upsert_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='upsert',
    status='ok',
  ),

  upsert_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='upsert',
    status='error',
  ),

  upsert_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_object(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='upsert',
    status='error',
  ),

  update_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='update',
    status='ok',
  ),

  update_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='update',
    status='ok',
  ),

  update_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='update',
    status='error',
  ),

  update_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='update',
    status='error',
  ),

  delete_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='delete',
    status='ok',
  ),

  delete_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='delete',
    status='ok',
  ),

  delete_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='delete',
    status='error',
  ),

  delete_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='delete',
    status='error',
  ),

  count_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='count',
    status='ok',
  ),

  count_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='count',
    status='ok',
  ),

  count_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='count',
    status='error',
  ),

  count_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='count',
    status='error',
  ),

  get_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='get',
    status='ok',
  ),

  get_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='get',
    status='ok',
  ),

  get_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='get',
    status='error',
  ),

  get_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='get',
    status='error',
  ),

  borders_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_borders(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    status='ok',
  ),

  borders_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_borders(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='ok',
  ),

  borders_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps_borders(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    status='error',
  ),

  borders_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_borders(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='error',
  ),

  len_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='len',
    status='ok',
  ),

  len_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='len',
    status='ok',
  ),

  len_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='len',
    status='error',
  ),

  len_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='len',
    status='error',
  ),

  truncate_success_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='truncate',
    status='ok',
  ),

  truncate_success_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='truncate',
    status='ok',
  ),

  truncate_error_rps(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
    rate_time_range=null,
  ):: operation_rps(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    rate_time_range=rate_time_range,
    operation='truncate',
    status='error',
  ),

  truncate_error_latency(
    title=null,
    description=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency(
    title=title,
    description=description,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    operation='truncate',
    status='error',
  ),
}
