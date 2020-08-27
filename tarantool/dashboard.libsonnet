local grafana = import 'grafonnet/grafana.libsonnet';

local http = import 'http.libsonnet';
local slab = import 'slab.libsonnet';
local space = import 'space.libsonnet';
local row = grafana.row;

{
  build(
    dashboard,
    datasource,
    policy=null,
    measurement=null,
    job=null,
    offset=0
  )::
    dashboard
    .addRequired(
      type='grafana',
      id='grafana',
      name='Grafana',
      version='6.6.0'
    )
    .addRequired(
      type='panel',
      id='graph',
      name='Graph',
      version=''
    )
    .addRequired(
      type='panel',
      id='text',
      name='Text',
      version=''
    )
    .addPanel(
      row.new(title='Tarantool HTTP statistics'),
      { w: 24, h: 1, x: 0, y: 0 + offset }
    )
    .addPanel(
      http.rps_success(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 1 + offset }
    )
    .addPanel(
      http.rps_error_4xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 1 + offset },
    )
    .addPanel(
      http.rps_error_5xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 1 + offset },
    )
    .addPanel(
      http.latency_success(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 9 + offset }
    )
    .addPanel(
      http.latency_error_4xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 9 + offset },
    )
    .addPanel(
      http.latency_error_5xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 9 + offset },
    )
    .addPanel(
      row.new(title='Tarantool memory overview'),
      { w: 24, h: 1, x: 0, y: 17 + offset }
    )
    .addPanel(
      slab.monitor_info(),
      { w: 24, h: 3, x: 0, y: 18 + offset }
    )
    .addPanel(
      slab.quota_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 21 + offset }
    )
    .addPanel(
      slab.arena_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 21 + offset },
    )
    .addPanel(
      slab.items_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 21 + offset },
    )
    .addPanel(
      slab.quota_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 29 + offset }
    )
    .addPanel(
      slab.arena_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 29 + offset },
    )
    .addPanel(
      slab.items_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 29 + offset },
    )
    .addPanel(
      slab.quota_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 37 + offset }
    )
    .addPanel(
      slab.arena_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 37 + offset },
    )
    .addPanel(
      slab.items_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 37 + offset },
    )
    .addPanel(
      row.new(title='Tarantool spaces statistics'),
      { w: 24, h: 1, x: 0, y: 45 + offset }
    )
    .addPanel(
      space.select_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 46 + offset },
    )
    .addPanel(
      space.insert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 46 + offset },
    )
    .addPanel(
      space.replace_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 46 + offset },
    )
    .addPanel(
      space.upsert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 46 + offset },
    )
    .addPanel(
      space.update_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 46 + offset },
    )
    .addPanel(
      space.delete_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 46 + offset },
    ),
}
