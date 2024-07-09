.. _monitoring-alerting-page:

===============================================================================
Alerting
===============================================================================

You can set up alerts on metrics to get a notification when something went
wrong. We will use `Prometheus alert rules <https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/>`_
as an example here. You can get full ``alerts.yml`` file at
`tarantool/grafana-dashboard GitHub repo <https://github.com/tarantool/grafana-dashboard/tree/master/example_cluster/prometheus/alerts.yml>`_.

.. _monitoring-alerting-tarantool:

-------------------------------------------------------------------------------
Tarantool metrics
-------------------------------------------------------------------------------

You can use internal Tarantool metrics to monitor detailed RAM consumption,
replication state, database engine status, track business logic issues (like
HTTP 4xx and 5xx responses or low request rate) and external modules statistics
(like ``CRUD`` errors or Cartridge issues). Evaluation timeouts, severity
levels and thresholds (especially ones for business logic) are placed here for
the sake of example: you may want to increase or decrease them for your
application. Also, don't forget to set sane rate time ranges based on your
Prometheus configuration.

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Lua memory
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The Lua memory is limited to 2 GB per instance. Monitoring ``tnt_info_memory_lua``
metric may prevent memory overflow and detect the presence of bad Lua code
practices.

..  code-block:: yaml

    - alert: HighLuaMemoryWarning
      expr: tnt_info_memory_lua >= (512 * 1024 * 1024)
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') Lua runtime warning"
        description: "'{{ $labels.alias }}' instance of job '{{ $labels.job }}' uses too much Lua memory
          and may hit threshold soon."

    - alert: HighLuaMemoryAlert
      expr: tnt_info_memory_lua >= (1024 * 1024 * 1024)
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') Lua runtime alert"
        description: "'{{ $labels.alias }}' instance of job '{{ $labels.job }}' uses too much Lua memory
          and likely to hit threshold soon."

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Memtx arena memory
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

By monitoring :ref:`slab allocation statistics <box_slab_info>` you can see
how many free RAM is remaining to store memtx tuples and indexes for an
instance. If Tarantool hit the limits, the instance will become unavailable
for write operations, so this alert may help you see when it's time to increase
your ``memtx_memory`` limit or to add a new storage to a vshard cluster.

..  code-block:: yaml

    - alert: LowMemtxArenaRemainingWarning
      expr: (tnt_slab_quota_used_ratio >= 80) and (tnt_slab_arena_used_ratio >= 80)
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') low arena memory remaining"
        description: "Low arena memory (tuples and indexes) remaining for '{{ $labels.alias }}' instance of job '{{ $labels.job }}'.
          Consider increasing memtx_memory or number of storages in case of sharded data."

    - alert: LowMemtxArenaRemaining
      expr: (tnt_slab_quota_used_ratio >= 90) and (tnt_slab_arena_used_ratio >= 90)
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') low arena memory remaining"
        description: "Low arena memory (tuples and indexes) remaining for '{{ $labels.alias }}' instance of job '{{ $labels.job }}'.
          You are likely to hit limit soon.
          It is strongly recommended to increase memtx_memory or number of storages in case of sharded data."

    - alert: LowMemtxItemsRemainingWarning
      expr: (tnt_slab_quota_used_ratio >= 80) and (tnt_slab_items_used_ratio >= 80)
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') low items memory remaining"
        description: "Low items memory (tuples) remaining for '{{ $labels.alias }}' instance of job '{{ $labels.job }}'.
          Consider increasing memtx_memory or number of storages in case of sharded data."

    - alert: LowMemtxItemsRemaining
      expr: (tnt_slab_quota_used_ratio >= 90) and (tnt_slab_items_used_ratio >= 90)
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') low items memory remaining"
        description: "Low items memory (tuples) remaining for '{{ $labels.alias }}' instance of job '{{ $labels.job }}'.
          You are likely to hit limit soon.
          It is strongly recommended to increase memtx_memory or number of storages in case of sharded data."

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Vinyl engine status
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

You can monitor :ref:`vinyl regulator <box_introspection-box_stat_vinyl_regulator>`
performance to track possible scheduler or disk issues.

..  code-block:: yaml

    - alert: LowVinylRegulatorRateLimit
      expr: tnt_vinyl_regulator_rate_limit < 100000
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') have low vinyl regulator rate limit"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' have low vinyl engine regulator rate limit.
          This indicates issues with the disk or the scheduler."


:ref:`Vinyl transactions <box_introspection-box_stat_vinyl_tx>` errors are likely
to lead to user requests errors.

..  code-block:: yaml

    - alert: HighVinylTxConflictRate
      expr: rate(tnt_vinyl_tx_conflict[5m]) / rate(tnt_vinyl_tx_commit[5m]) > 0.05
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') have high vinyl tx conflict rate"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' have
          high vinyl transactions conflict rate. It indicates that vinyl is not healthy."

:ref:`Vinyl scheduler <box_introspection-box_stat_vinyl>` failed tasks
are a good signal of disk issues and may be the reason of increasing RAM
consumption.

..  code-block:: yaml

    - alert: HighVinylSchedulerFailedTasksRate
      expr: rate(tnt_vinyl_scheduler_tasks{status="failed"}[5m]) > 0.1
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') have high vinyl scheduler failed tasks rate"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' have
          high vinyl scheduler failed tasks rate."


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Replication state
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If ``tnt_replication_status`` is equal to ``0``, instance :ref:`replication <box_info_replication>`
status is not equal to ``"follows"``: replication is either not ready yet or
has been stopped due to some reason. 

..  code-block:: yaml

    - alert: ReplicationNotRunning
      expr: tnt_replication_status == 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') {{ $labels.stream }} (id {{ $labels.id }})
          replication is not running"
        description: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') {{ $labels.stream }} (id {{ $labels.id }})
          replication is not running. Check Cartridge UI for details."

Even if async replication is ``"follows"``, it could be considered malfunctioning
if the lag is too high. It also may affect Tarantool garbage collector work,
see :ref:`box.info.gc() <box_info_gc>`.

..  code-block:: yaml

    - alert: HighReplicationLag
      expr: tnt_replication_lag > 1
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') have high replication lag (id {{ $labels.id }})"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' have high replication lag
          (id {{ $labels.id }}), check up your network and cluster state."

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Event loop
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

High :ref:`fiber <fiber-fibers>` event loop time leads to bad application
performance, timeouts and various warnings. The reason could be a high quantity
of working fibers or fibers that spend too much time without any yields or
sleeps.

..  code-block:: yaml

    - alert: HighEVLoopTime
      expr: tnt_ev_loop_time > 0.1
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') event loop has high cycle duration"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' event loop has high cycle duration.
          Some high loaded fiber has too little yields. It may be the reason of 'Too long WAL write' warnings."


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Configuration status
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

:ref:`Configuration status <config_api_reference_info>` displays
Tarantool 3 configuration apply state. Additional metrics desplay the count
of apply warnings and errors.

..  code-block:: yaml

    - alert: ConfigWarningAlerts
      expr: tnt_config_alerts{level="warn"} > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') has configuration 'warn' alerts"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' has configuration 'warn' alerts.
                      Please, check config:info() for detailed info."

    - alert: ConfigErrorAlerts
      expr: tnt_config_alerts{level="error"} > 0
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') has configuration 'error' alerts"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' has configuration 'error' alerts.
                      Latest configuration has not been applied.
                      Please, check config:info() for detailed info."

    - alert: ConfigStatusNotReady
      expr: tnt_config_status{status="ready"} == 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') configuration is not ready"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' configuration is not ready.
                      Please, check config:info() for detailed info."


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Cartridge issues
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

:ref:`Cartridge issues and warnings <cartridge-troubleshooting>` aggregate
both single instance or replicaset issues (like memory or replication issues
we've discussed in another paragraphs) and Cartridge cluster malfunctions
(for example, clusteride config issues).

..  code-block:: yaml

    - alert: CartridgeWarningIssues
      expr: tnt_cartridge_issues{level="warning"} > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') has 'warning'-level Cartridge issues"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' has 'warning'-level Cartridge issues.
          Possible reasons: high replication lag, replication long idle,
          failover or switchover issues, clock issues, memory fragmentation,
          configuration issues, alien members."

    - alert: CartridgeCriticalIssues
      expr: tnt_cartridge_issues{level="critical"} > 0
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') has 'critical'-level Cartridge issues"
        description: "Instance '{{ $labels.alias }}' of job '{{ $labels.job }}' has 'critical'-level Cartridge issues.
          Possible reasons: replication process critical fail,
          running out of available memory."


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
HTTP server statistics
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

:ref:`metrics <metrics-reference>` allows to monitor `tarantool/http <https://github.com/tarantool/http>`_
handles, see :ref:`"Collecting HTTP request latency statistics" <metrics-api_reference-collecting_http_statistics>`.
Here we use a ``summary`` collector with a default name and 0.99 quantile
computation.

Too many responses with error codes usually is a sign of API issues or
application malfunction.

..  code-block:: yaml

    - alert: HighInstanceHTTPClientErrorRate
      expr: sum by (job, instance, method, path, alias) (rate(http_server_request_latency_count{ job="tarantool", status=~"^4\\d{2}$" }[5m])) > 10
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') high rate of client error responses"
        description: "Too many {{ $labels.method }} requests to {{ $labels.path }} path 
          on '{{ $labels.alias }}' instance of job '{{ $labels.job }}' get client error (4xx) responses."

    - alert: HighHTTPClientErrorRate
      expr: sum by (job, method, path) (rate(http_server_request_latency_count{ job="tarantool", status=~"^4\\d{2}$" }[5m])) > 20
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Job '{{ $labels.job }}' high rate of client error responses"
        description: "Too many {{ $labels.method }} requests to {{ $labels.path }} path
          on instances of job '{{ $labels.job }}' get client error (4xx) responses."

    - alert: HighHTTPServerErrorRate
      expr: sum by (job, instance, method, path, alias) (rate(http_server_request_latency_count{ job="tarantool", status=~"^5\\d{2}$" }[5m])) > 0
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') server error responses"
        description: "Some {{ $labels.method }} requests to {{ $labels.path }} path 
          on '{{ $labels.alias }}' instance of job '{{ $labels.job }}' get server error (5xx) responses."

Responding with high latency is a synonym of insufficient performance. It may
be a sign of application malfunction. Or maybe you need to add more routers to
your cluster.

..  code-block:: yaml

    - alert: HighHTTPLatency
      expr: http_server_request_latency{ job="tarantool", quantile="0.99" } > 0.1
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') high HTTP latency"
        description: "Some {{ $labels.method }} requests to {{ $labels.path }} path with {{ $labels.status }} response status
          on '{{ $labels.alias }}' instance of job '{{ $labels.job }}' are processed too long."

Having too little requests when you expect them may detect balancer, external
client or network malfunction.

..  code-block:: yaml

    - alert: LowRouterHTTPRequestRate
      expr: sum by (job, instance, alias) (rate(http_server_request_latency_count{ job="tarantool", alias=~"^.*router.*$" }[5m])) < 10
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Router '{{ $labels.alias }}' ('{{ $labels.job }}') low activity"
        description: "Router '{{ $labels.alias }}' instance of job '{{ $labels.job }}' gets too little requests.
          Please, check up your balancer middleware."


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
CRUD module statistics
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If your application uses `CRUD <https://github.com/tarantool/crud>`_ module
requests, monitoring module statistics may track internal errors caused by
invalid process of input and internal parameters.

..  code-block:: yaml

    - alert: HighCRUDErrorRate
      expr: rate(tnt_crud_stats_count{ job="tarantool", status="error" }[5m]) > 0.1
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') too many CRUD {{ $labels.operation }} errors."
        description: "Too many {{ $labels.operation }} CRUD requests for '{{ $labels.name }}' space on
          '{{ $labels.alias }}' instance of job '{{ $labels.job }}' get module error responses."

Statistics could also monitor requests performance. Too high request latency
will lead to high latency of client responses. It may be caused by network
or disk issues. Read requests with bad (with respect to space indexes and
sharding schema) conditions may lead to full-scans or map reduces and also
could be the reason of high latency.

..  code-block:: yaml

    - alert: HighCRUDLatency
      expr: tnt_crud_stats{ job="tarantool", quantile="0.99" } > 0.1
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') too high CRUD {{ $labels.operation }} latency."
        description: "Some {{ $labels.operation }} {{ $labels.status }} CRUD requests for '{{ $labels.name }}' space on
          '{{ $labels.alias }}' instance of job '{{ $labels.job }}' are processed too long."

You also can directly monitor map reduces and scan rate.

..  code-block:: yaml

    - alert: HighCRUDMapReduceRate
      expr: rate(tnt_crud_map_reduces{ job="tarantool" }[5m]) > 0.1
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "Instance '{{ $labels.alias }}' ('{{ $labels.job }}') too many CRUD {{ $labels.operation }} map reduces."
        description: "There are too many {{ $labels.operation }} CRUD map reduce requests for '{{ $labels.name }}' space on
          '{{ $labels.alias }}' instance of job '{{ $labels.job }}'.
          Check your request conditions or consider changing sharding schema."


.. _monitoring-alerting-server:

-------------------------------------------------------------------------------
Server-side monitoring
-------------------------------------------------------------------------------

If there are no Tarantool metrics, you may miss critical conditions. Prometheus
provide ``up`` metric to monitor the health of its targets.

..  code-block:: yaml

    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        summary: "Instance '{{ $labels.instance }}' ('{{ $labels.job }}') down"
        description: "'{{ $labels.instance }}' of job '{{ $labels.job }}' has been down for more than a minute."

Do not forget to monitor your server's CPU, disk and RAM from server side with
your favorite tools. For example, on some high CPU consumption cases Tarantool
instance may stop to send metrics, so you can track such breakdowns only from
the outside.
