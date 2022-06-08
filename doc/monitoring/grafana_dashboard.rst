.. _monitoring-grafana_dashboard-page:

===============================================================================
Grafana dashboard
===============================================================================

Tarantool Grafana dashboard is available as part of
`Grafana Official & community built dashboards <https://grafana.com/grafana/dashboards>`_.
There's a version
`for Prometheus data source <https://grafana.com/grafana/dashboards/13054>`_
and one `for InfluxDB data source <https://grafana.com/grafana/dashboards/12567>`_.
There are also separate dashboards for TDG applications:
`for Prometheus data source <https://grafana.com/grafana/dashboards/16406>`_
and `for InfluxDB data source <https://grafana.com/grafana/dashboards/16405>`_.
Tarantool Grafana dashboard is a ready for import template with basic memory,
space operations, and HTTP load panels, based on default `metrics <https://github.com/tarantool/metrics>`_
package functionality.

Dashboard requires using ``metrics`` **0.13.0** or newer for complete experience;
``'alias'`` :ref:`global label <tarantool-metrics>` must be set on each instance
to properly display panels (e.g. provided with ``cartridge.roles.metrics`` role).

To support `CRUD <https://github.com/tarantool/crud>`_ statistics, install ``CRUD``
**0.11.1** or newer. Call ``crud.cfg`` on router to enable CRUD statistics collect
with latency quantiles.

..  code-block:: lua

    crud.cfg{
        stats = true,
        stats_driver='metrics',
        stats_quantiles=true
    }


.. image:: images/Prometheus_dashboard_1.png
   :width: 30%

.. image:: images/Prometheus_dashboard_2.png
   :width: 30%

.. image:: images/Prometheus_dashboard_3.png
   :width: 30%

.. _monitoring-grafana_dashboard-monitoring_stack:

-------------------------------------------------------------------------------
Prepare a monitoring stack
-------------------------------------------------------------------------------

Since there are Prometheus and InfluxDB data source Grafana dashboards,
you can use
   
- `Telegraf <https://www.influxdata.com/time-series-platform/telegraf/>`_
  as a server agent for collecting metrics, `InfluxDB <https://www.influxdata.com/>`_
  as a time series database for storing metrics, and `Grafana <https://grafana.com/>`_
  as a visualization platform; or
- `Prometheus <https://prometheus.io/>`_ as both a server agent for collecting metrics
  and a time series database for storing metrics, and `Grafana <https://grafana.com/>`_
  as a visualization platform.

For issues concerning setting up Prometheus, Telegraf, InfluxDB, or Grafana instances
please refer to the corresponding project's documentation.

.. _monitoring-grafana_dashboard-collect_metrics:

-------------------------------------------------------------------------------
Collect metrics with server agents
-------------------------------------------------------------------------------

To collect metrics for Prometheus, first set up metrics output with
``prometheus`` format. You can use :ref:`cartridge.roles.metrics <cartridge-role>`
configuration or set up the :ref:`Prometheus output plugin <prometheus>` manually.
To start collecting metrics,
`add a job <https://prometheus.io/docs/prometheus/latest/getting_started/#configure-prometheus-to-monitor-the-sample-targets>`_
to Prometheus configuration with each Tarantool instance URI as a target and
metrics path as it was configured on Tarantool instances:

..  code-block:: yaml

    scrape_configs:
      - job_name: "example_project"
        static_configs:
          - targets: 
            - "example_project:8081"
            - "example_project:8082"
            - "example_project:8083"
        metrics_path: "/metrics/prometheus"


To collect metrics for InfluxDB, use the Telegraf agent.
First off, configure Tarantool metrics output in ``json`` format
with :ref:`cartridge.roles.metrics <cartridge-role>` configuration or
corresponding :ref:`JSON output plugin <json>`. To start collecting metrics,
add `http input <https://github.com/influxdata/telegraf/blob/release-1.17/plugins/inputs/http/README.md>`_
to Telegraf configuration including each Tarantool instance metrics URL:

..  code-block:: toml

    [[inputs.http]]
        urls = [
            "http://example_project:8081/metrics/json",
            "http://example_project:8082/metrics/json",
            "http://example_project:8083/metrics/json"
        ]
        timeout = "30s"
        tag_keys = [
            "metric_name",
            "label_pairs_alias",
            "label_pairs_quantile",
            "label_pairs_path",
            "label_pairs_method",
            "label_pairs_status",
            "label_pairs_operation",
            "label_pairs_level",
            "label_pairs_id",
            "label_pairs_engine",
            "label_pairs_name",
            "label_pairs_index_name",
            "label_pairs_delta",
            "label_pairs_stream"
        ]
        insecure_skip_verify = true
        interval = "10s"
        data_format = "json"
        name_prefix = "example_project_"
        fieldpass = ["value"]

Be sure to include each label key as ``label_pairs_<key>`` so it will be
extracted with plugin. For example, if you use :code:`{ state = 'ready' }` labels
somewhere in metric collectors, add ``label_pairs_state`` tag key.

For TDG dashboard, please use

..  code-block:: toml

    [[inputs.http]]
        urls = [
            "http://example_tdg_project:8081/metrics/json",
            "http://example_tdg_project:8082/metrics/json",
            "http://example_tdg_project:8083/metrics/json"
        ]
        timeout = "30s"
        tag_keys = [
            "metric_name",
            "label_pairs_alias",
            "label_pairs_quantile",
            "label_pairs_path",
            "label_pairs_method",
            "label_pairs_status",
            "label_pairs_operation",
            "label_pairs_level",
            "label_pairs_id",
            "label_pairs_engine",
            "label_pairs_name",
            "label_pairs_index_name",
            "label_pairs_delta",
            "label_pairs_stream",
            "label_pairs_type",
            "label_pairs_connector_name",
            "label_pairs_broker_name",
            "label_pairs_topic",
            "label_pairs_request",
            "label_pairs_kind",
            "label_pairs_thread_name",
            "label_pairs_type_name",
            "label_pairs_operation_name",
            "label_pairs_schema",
            "label_pairs_entity",
            "label_pairs_status_code"
        ]
        insecure_skip_verify = true
        interval = "10s"
        data_format = "json"
        name_prefix = "example_project_"
        fieldpass = ["value"]

If you connect Telegraf instance to InfluxDB storage, metrics will be stored
with ``"<name_prefix>http"`` measurement (``"example_project_http"`` in our example).

.. _monitoring-grafana_dashboard-import:

-------------------------------------------------------------------------------
Import the dashboard
-------------------------------------------------------------------------------
Open Grafana import menu.

..  image:: images/grafana_import.png
    :align: left

To import a specific dashboard, choose one of the following options:

- paste the dashboard id (``12567`` for InfluxDB dashboard, ``13054`` for Prometheus dashboard,
  ``16405`` for InfluxDB TDG dashboard, ``16406`` for Prometheus TDG dashboard), or
- paste a link to the dashboard (
  https://grafana.com/grafana/dashboards/12567 for InfluxDB dashboard,
  https://grafana.com/grafana/dashboards/13054 for Prometheus dashboard,
  https://grafana.com/grafana/dashboards/16405 for InfluxDB TDG dashboard,
  https://grafana.com/grafana/dashboards/16406 for Prometheus TDG dashboard), or
- paste the dashboard JSON file contents, or
- upload the dashboard JSON file.

Set dashboard name, folder, uid (if needed), and datasource-related query parameters
(InfluxDB source, measurement and policy or Prometheus source, job and rate time range).

..  image:: images/grafana_import_setup.png
    :align: left

.. _monitoring-grafana_dashboard-troubleshooting:

-------------------------------------------------------------------------------
Troubleshooting
-------------------------------------------------------------------------------

If there's no data on the graphs, make sure that you have set up datasource and job/measurement correctly.

If there's no data on the rps graphs on Prometheus table, make sure that
your rate time range parameter is at least twice as Prometheus scrape interval.
