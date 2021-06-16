local grafana = import 'grafonnet/grafana.libsonnet';

local cluster = import 'cluster.libsonnet';
local http = import 'http.libsonnet';
local memory_misc = import 'memory_misc.libsonnet';
local net = import 'net.libsonnet';
local operations = import 'operations.libsonnet';
local slab = import 'slab.libsonnet';
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
      row.new(title='Tarantool network activity'),
      { w: 24, h: 1, x: 0, y: 23 + offset }
    )
    .addPanel(
      net.bytes_received_per_second(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 12, h: 8, x: 0, y: 24 + offset }
    )
    .addPanel(
      net.bytes_sent_per_second(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 12, h: 8, x: 12, y: 24 + offset }
    )
    .addPanel(
      net.net_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 32 + offset }
    )
    .addPanel(
      net.net_pending(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 32 + offset }
    )
    .addPanel(
      net.current_connections(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 32 + offset }
    )
    .addPanel(
      row.new(title='Tarantool memory allocation overview'),
      { w: 24, h: 1, x: 0, y: 40 + offset }
    )
    .addPanel(
      slab.monitor_info(),
      { w: 24, h: 3, x: 0, y: 41 + offset }
    )
    .addPanel(
      slab.quota_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 44 + offset }
    )
    .addPanel(
      slab.arena_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 44 + offset },
    )
    .addPanel(
      slab.items_used_ratio(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 44 + offset },
    )
    .addPanel(
      slab.quota_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 52 + offset }
    )
    .addPanel(
      slab.arena_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 52 + offset },
    )
    .addPanel(
      slab.items_used(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 52 + offset },
    )
    .addPanel(
      slab.quota_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 0, y: 60 + offset }
    )
    .addPanel(
      slab.arena_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 8, y: 60 + offset },
    )
    .addPanel(
      slab.items_size(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 8, h: 8, x: 16, y: 60 + offset },
    )
    .addPanel(
      row.new(title='Tarantool memory miscellaneous'),
      { w: 24, h: 1, x: 0, y: 68 + offset }
    )
    .addPanel(
      memory_misc.lua_memory(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
      ),
      { w: 24, h: 8, x: 0, y: 69 + offset },
    )
    .addPanel(
      row.new(title='Tarantool operations statistics'),
      { w: 24, h: 1, x: 0, y: 77 + offset }
    )
    .addPanel(
      operations.space_select_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 78 + offset },
    )
    .addPanel(
      operations.space_insert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 78 + offset },
    )
    .addPanel(
      operations.space_replace_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 78 + offset },
    )
    .addPanel(
      operations.space_upsert_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 86 + offset },
    )
    .addPanel(
      operations.space_update_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 86 + offset },
    )
    .addPanel(
      operations.space_delete_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 86 + offset },
    )
    .addPanel(
      operations.call_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 94 + offset },
    )
    .addPanel(
      operations.eval_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 94 + offset },
    )
    .addPanel(
      operations.error_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 94 + offset },
    )
    .addPanel(
      operations.auth_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 0, y: 102 + offset },
    )
    .addPanel(
      operations.SQL_prepare_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 8, y: 102 + offset },
    )
    .addPanel(
      operations.SQL_execute_rps(
        datasource=datasource,
        policy=policy,
        measurement=measurement,
        job=job,
        rate_time_range=rate_time_range,
      ),
      { w: 8, h: 8, x: 16, y: 102 + offset },
    ),
}
