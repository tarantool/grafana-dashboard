local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local http = import 'http.libsonnet';
local memory_misc = import 'memory_misc.libsonnet';
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
    rate_time_range=null,
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
      cluster.cartridge_warning_issues(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 12, h: 6, x: 0, y: 0 + offset }
    )
    .addPanel(
      cluster.cartridge_critical_issues(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 12, h: 6, x: 12, y: 0 + offset }
    )
    .addPanel(
      row.new(title='Tarantool HTTP statistics'),
      { w: 24, h: 1, x: 0, y: 6 + offset }
    )
    .addPanel(
      http.rps_success(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 7 + offset }
    )
    .addPanel(
      http.rps_error_4xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 7 + offset },
    )
    .addPanel(
      http.rps_error_5xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 7 + offset },
    )
    .addPanel(
      http.latency_success(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 15 + offset }
    )
    .addPanel(
      http.latency_error_4xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 15 + offset },
    )
    .addPanel(
      http.latency_error_5xx(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 15 + offset },
    )
    .addPanel(
      row.new(title='Tarantool memory allocation overview'),
      { w: 24, h: 1, x: 0, y: 23 + offset }
    )
    .addPanel(
      slab.monitor_info(),
      { w: 24, h: 3, x: 0, y: 24 + offset }
    )
    .addPanel(
      slab.quota_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 27 + offset }
    )
    .addPanel(
      slab.arena_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 27 + offset },
    )
    .addPanel(
      slab.items_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 27 + offset },
    )
    .addPanel(
      slab.quota_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 35 + offset }
    )
    .addPanel(
      slab.arena_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 35 + offset },
    )
    .addPanel(
      slab.items_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 35 + offset },
    )
    .addPanel(
      slab.quota_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 43 + offset }
    )
    .addPanel(
      slab.arena_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 43 + offset },
    )
    .addPanel(
      slab.items_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 43 + offset },
    )
    .addPanel(
      row.new(title='Tarantool memory miscellaneous'),
      { w: 24, h: 1, x: 0, y: 51 + offset }
    )
    .addPanel(
      memory_misc.lua_memory(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 24, h: 8, x: 0, y: 52 + offset },
    )
    .addPanel(
      row.new(title='Tarantool spaces statistics'),
      { w: 24, h: 1, x: 0, y: 60 + offset }
    )
    .addPanel(
      space.select_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 61 + offset },
    )
    .addPanel(
      space.insert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 61 + offset },
    )
    .addPanel(
      space.replace_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 61 + offset },
    )
    .addPanel(
      space.upsert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 69 + offset },
    )
    .addPanel(
      space.update_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 69 + offset },
    )
    .addPanel(
      space.delete_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 69 + offset },
    ),
}
