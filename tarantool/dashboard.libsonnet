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
    job=null
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
      { w: 24, h: 1, x: 0, y: 0 }
    )
    .addPanel(
      http.rps_success(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 1 }
    )
    .addPanel(
      http.rps_error_4xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 1 },
    )
    .addPanel(
      http.rps_error_5xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 1 },
    )
    .addPanel(
      http.latency_success(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 9 }
    )
    .addPanel(
      http.latency_error_4xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 9 },
    )
    .addPanel(
      http.latency_error_5xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 9 },
    )
    .addPanel(
      row.new(title='Tarantool memory overview'),
      { w: 24, h: 1, x: 0, y: 17 }
    )
    .addPanel(
      slab.monitor_info(),
      { w: 24, h: 3, x: 0, y: 18 }
    )
    .addPanel(
      slab.quota_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 21 }
    )
    .addPanel(
      slab.arena_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 21 },
    )
    .addPanel(
      slab.items_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 21 },
    )
    .addPanel(
      slab.quota_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 29 }
    )
    .addPanel(
      slab.arena_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 29 },
    )
    .addPanel(
      slab.items_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 29 },
    )
    .addPanel(
      slab.quota_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 37 }
    )
    .addPanel(
      slab.arena_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 37 },
    )
    .addPanel(
      slab.items_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 37 },
    )
    .addPanel(
      row.new(title='Tarantool spaces statistics'),
      { w: 24, h: 1, x: 0, y: 45 }
    )
    .addPanel(
      space.select_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 46 },
    )
    .addPanel(
      space.insert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 46 },
    )
    .addPanel(
      space.replace_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 46 },
    )
    .addPanel(
      space.upsert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 46 },
    )
    .addPanel(
      space.update_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 46 },
    )
    .addPanel(
      space.delete_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 46 },
    ),
}
