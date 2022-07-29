local grafana = import 'grafonnet/grafana.libsonnet';

local common = import 'dashboard/panels/common.libsonnet';
local variable = import 'dashboard/variable.libsonnet';

local influxdb = grafana.influxdb;
local prometheus = grafana.prometheus;

// Add util functions for panels.

local crud_warning(description) = std.join(
  '\n',
  [description, |||
    CRUD 0.11.0 or newer is required to use statistics.
    Enable statistics with `crud.cfg{stats = true, stats_driver = 'metrics'}`
  |||]
);

local crud_quantile_warning(description) = std.join(
  '\n',
  [description, |||
    CRUD 0.11.0 or newer is required to use statistics.
    Enable quantiles with `crud.cfg{stats = true, stats_driver = 'metrics', stats_quantiles = true}`.
    If `No data` displayed yet data expected, try to calibrate tolerated error with
    `crud.cfg{stats_quantile_tolerated_error=1e-4}`.
  |||]
);

local status_text(status) = (if status == 'ok' then 'success' else 'error');

local operation_rps_template(
  title=null,
  description=null,
  datasource_type=null,
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
      std.format('%s %s requests', [std.asciiUpper(operation), status_text(status)])
  ),
  description=description,
  datasource=datasource,
  min=0,
  labelY1='requests per second',
  decimals=2,
  decimalsY1=2,
  panel_height=8,
  panel_width=6,
).addTarget(
  if datasource_type == variable.datasource_type.prometheus then
    prometheus.target(
      expr=std.format(
        'rate(tnt_crud_stats_count{job=~"%s",operation="%s",status="%s"}[$__rate_interval])',
        [job, operation, status]
      ),
      legendFormat='{{alias}} — {{name}}'
    )
  else if datasource_type == variable.datasource_type.influxdb then
    influxdb.target(
      policy=policy,
      measurement=measurement,
      group_tags=['label_pairs_alias', 'label_pairs_name'],
      alias='$tag_label_pairs_alias — $tag_label_pairs_name',
    ).where('metric_name', '=', 'tnt_crud_stats_count')
    .where('label_pairs_operation', '=', operation)
    .where('label_pairs_status', '=', status)
    .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
);

local operation_latency_template(
  title=null,
  description=null,
  datasource_type=null,
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
  if datasource_type == variable.datasource_type.prometheus then
    prometheus.target(
      expr=std.format(
        'tnt_crud_stats{job=~"%s",operation="%s",status="%s",quantile="0.99"}',
        [job, operation, status]
      ),
      legendFormat='{{alias}} — {{name}}'
    )
  else if datasource_type == variable.datasource_type.influxdb then
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
);

local operation_rps(
  title=null,
  description=null,
  datasource_type=null,
  datasource=null,
  policy=null,
  measurement=null,
  job=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation=operation,
  status=status,
);

local operation_latency(
  title=null,
  description=null,
  datasource_type=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation=operation,
  status=status,
);

local operation_rps_object(
  title=null,
  description=null,
  datasource_type=null,
  datasource=null,
  policy=null,
  measurement=null,
  job=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation=operation,
  status=status,
);

local operation_latency_object(
  title=null,
  description=null,
  datasource_type=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation=operation,
  status=status,
);

local operation_rps_object_many(
  title=null,
  description=null,
  datasource_type=null,
  datasource=null,
  policy=null,
  measurement=null,
  job=null,
  operation_stripped=null,
  status=null,
      ) = operation_rps_template(
  title=title,
  description=(
    if description != null then
      description
    else
      crud_warning(std.format(|||
        Total count of %s %s_many and %s_object_many requests to cluster spaces with CRUD module.
        Graph shows average requests per second.
      |||, [status_text(status), operation_stripped, operation_stripped]))
  ),
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation=std.format('%s_many', operation_stripped),
  status=status,
);

local operation_latency_object_many(
  title=null,
  description=null,
  datasource_type=null,
  datasource=null,
  policy=null,
  measurement=null,
  job=null,
  operation_stripped=null,
  status=null,
      ) = operation_latency_template(
  title=title,
  description=(
    if description != null then
      description
    else
      crud_quantile_warning(std.format(|||
        99th percentile of %s %s_many and %s_object_many CRUD module requests latency with aging.
      |||, [status_text(status), operation_stripped, operation_stripped]))
  ),
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation=std.format('%s_many', operation_stripped),
  status=status,
);

local operation_rps_select(
  title=null,
  description=null,
  datasource_type=null,
  datasource=null,
  policy=null,
  measurement=null,
  job=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation='select',
  status=status,
);

local operation_latency_select(
  title=null,
  description=null,
  datasource_type=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation='select',
  status=status,
);

local operation_rps_borders(
  title=null,
  description=null,
  datasource_type=null,
  datasource=null,
  policy=null,
  measurement=null,
  job=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation='borders',
  status=status,
);

local operation_latency_borders(
  title=null,
  description=null,
  datasource_type=null,
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
  datasource_type=datasource_type,
  datasource=datasource,
  policy=policy,
  measurement=measurement,
  job=job,
  operation='borders',
  status=status,
);

local tuples_panel(
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
  description=common.group_by_fill_0_warning(
    crud_warning(description),
    datasource_type,
  ),
  datasource=datasource,
  min=0,
  labelY1='tuples per request',
  panel_height=8,
  panel_width=8,
).addTarget(
  if datasource_type == variable.datasource_type.prometheus then
    prometheus.target(
      expr=std.format(
        |||
          rate(%(metric_name)s{job=~"%(job)s",operation="select"}[$__rate_interval]) /
          (sum without (status) (rate(tnt_crud_stats_count{job=~"%(job)s",operation="select"}[$__rate_interval])))
        |||,
        {
          metric_name: metric_name,
          job: job,
        }
      ),
      legendFormat='{{alias}} — {{name}}'
    )
  else if datasource_type == variable.datasource_type.influxdb then
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
);

// Add first set of panels to the module: row, select operations, borders operations, select tuples details.
local module = {
  row:: common.row('CRUD module statistics'),

  select_success_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_rps_select(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='ok',
  ),

  select_success_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_select(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='ok',
  ),

  select_error_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_rps_select(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='error',
  ),

  select_error_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_select(
    title=title,
    description=description,
    datasource_type=datasource_type,
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
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tuples_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_crud_tuples_fetched',
  ),

  tuples_lookup_panel(
    title='SELECT tuples lookup',
    description=|||
      Average number of tuples looked up on storages while collecting responses
      for SELECT/PAIRS requests (including scrolls for multibatch requests)
      for a space. Both success and error requests are taken into consideration.
    |||,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: tuples_panel(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    metric_name='tnt_crud_tuples_lookup',
  ),

  map_reduces(
    title='Map reduce SELECT requests',
    description=crud_warning(|||
      Number of SELECT and PAIRS requests that resulted in map reduce.
      Graph shows average requests per second.
      Both success and error requests are taken into consideration.
    |||),
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: common.default_graph(
    title=title,
    description=description,
    datasource=datasource,
    min=0,
    labelY1='requests per second',
    panel_height=8,
    panel_width=8,
  ).addTarget(
    if datasource_type == variable.datasource_type.prometheus then
      prometheus.target(
        expr=std.format(
          'rate(tnt_crud_map_reduces{job=~"%s",operation="select"}[$__rate_interval])',
          [job],
        ),
        legendFormat='{{alias}} — {{name}}'
      )
    else if datasource_type == variable.datasource_type.influxdb then
      influxdb.target(
        policy=policy,
        measurement=measurement,
        group_tags=['label_pairs_alias', 'label_pairs_name'],
        alias='$tag_label_pairs_alias — $tag_label_pairs_name',
      ).where('metric_name', '=', 'tnt_crud_map_reduces')
      .where('label_pairs_operation', '=', 'select')
      .selectField('value').addConverter('mean').addConverter('non_negative_derivative', ['1s'])
  ),

  borders_success_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_rps_borders(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='ok',
  ),

  borders_success_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_borders(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='ok',
  ),

  borders_error_rps(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_rps_borders(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='error',
  ),

  borders_error_latency(
    title=null,
    description=null,
    datasource_type=null,
    datasource=null,
    policy=null,
    measurement=null,
    job=null,
  ):: operation_latency_borders(
    title=title,
    description=description,
    datasource_type=datasource_type,
    datasource=datasource,
    policy=policy,
    measurement=measurement,
    job=job,
    status='error',
  ),
};

local operations_with_object = ['insert', 'replace', 'upsert'];
local operations_stripped_with_object_many = ['insert', 'replace', 'upsert'];
local operations_without_object = ['update', 'delete', 'get', 'len', 'truncate', 'count'];

// Add second set of panels to the module: panels for operations which have _object version.
local module_with_object_panels = std.foldl(function(_module, operation) (
  _module {
    [std.format('%s_success_rps', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_rps_object(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='ok',
    ),

    [std.format('%s_success_latency', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_latency_object(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='ok',
    ),

    [std.format('%s_error_rps', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_rps_object(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='error',
    ),

    [std.format('%s_error_latency', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_latency_object(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='error',
    ),
  }
), operations_with_object, module);

// Add third set of panels to the module: panels for _many operations.
local module_with_object_and_many_panels = std.foldl(function(_module, operation_stripped) (
  _module {
    [std.format('%s_many_success_rps', operation_stripped)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_rps_object_many(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation_stripped=operation_stripped,
      status='ok',
    ),

    [std.format('%s_many_success_latency', operation_stripped)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_latency_object_many(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation_stripped=operation_stripped,
      status='ok',
    ),

    [std.format('%s_many_error_rps', operation_stripped)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_rps_object_many(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation_stripped=operation_stripped,
      status='error',
    ),

    [std.format('%s_many_error_latency', operation_stripped)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_latency_object_many(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation_stripped=operation_stripped,
      status='error',
    ),
  }
), operations_stripped_with_object_many, module_with_object_panels);

// Add last set of panels to the module: remaining operation panels without _object version.
std.foldl(function(_module, operation) (
  _module {
    [std.format('%s_success_rps', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_rps(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='ok',
    ),

    [std.format('%s_success_latency', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_latency(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='ok',
    ),

    [std.format('%s_error_rps', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_rps(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='error',
    ),

    [std.format('%s_error_latency', operation)](
      title=null,
      description=null,
      datasource_type=null,
      datasource=null,
      policy=null,
      measurement=null,
      job=null,
    ):: operation_latency(
      title=title,
      description=description,
      datasource_type=datasource_type,
      datasource=datasource,
      policy=policy,
      measurement=measurement,
      job=job,
      operation=operation,
      status='error',
    ),
  }
), operations_without_object, module_with_object_and_many_panels)
