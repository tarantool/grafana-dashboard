# Tarantool Grafana dashboard

Dashboard for Tarantool application and database server monitoring, based on [grafonnet](https://github.com/grafana/grafonnet-lib) library.

Our pages on Grafana Official & community built dashboards:
[InfluxDB version](https://grafana.com/grafana/dashboards/12567),
[Prometheus version](https://grafana.com/grafana/dashboards/13054)
[InfluxDB TDG version](https://grafana.com/grafana/dashboards/16405),
[Prometheus TDG version](https://grafana.com/grafana/dashboards/16406).

Refer to dashboard [documentation page](https://www.tarantool.io/en/doc/latest/book/monitoring/grafana_dashboard/) for prerequirements and installation guide.

<img src="./doc/monitoring/images/Prometheus_dashboard_1.png" width="250"/> <img src="./doc/monitoring/images/Prometheus_dashboard_2.png" width="250"/> <img src="./doc/monitoring/images/Prometheus_dashboard_3.png" width="250"/>


## Table of contents

- [Installation](#installation)
- [Monitoring cluster](#monitoring-cluster)
- [Manual build](#manual-build)
- [Customization](#customization)
- [Contacts](#contacts)


## Installation

1. Open Grafana import menu.

    ![Grafana import menu](doc/monitoring/images/grafana_import.png)

2. To import a specific dashboard, choose one of the following options:

    - paste the dashboard id (``12567`` for InfluxDB dashboard, ``13054`` for Prometheus dashboard,
      ``16405`` for InfluxDB TDG dashboard, ``16406`` for Prometheus TDG dashboard), or
    - paste a link to the dashboard (
      https://grafana.com/grafana/dashboards/12567 for InfluxDB dashboard,
      https://grafana.com/grafana/dashboards/13054 for Prometheus dashboard,
      https://grafana.com/grafana/dashboards/16405 for InfluxDB TDG dashboard,
      https://grafana.com/grafana/dashboards/16406 for Prometheus TDG dashboard), or
    - paste the dashboard JSON file contents, or
    - upload the dashboard JSON file.

3. Set dashboard name, folder, uid, choose corresponding datasource from drop-down list and set datasource-related query parameters.

    ![Dashboard import variables](doc/monitoring/images/grafana_import_setup.png)

    You need to set the following variables for InfluxDB datasource:

    - `Measurement`,
    - `Policy` (default valie is `autogen`).

    You need to set the following variables for Prometheus datasource:

    - `Job`,
    - `Rate time range` (default valie is `2m`).

    Datasource variables can be obtained from your datasource configuration.
    Variables for example monitoring cluster are described in [Monitoring cluster](#monitoring-cluster) section.


## Monitoring cluster

For guide on setting up your monitoring stack refer to [documentation page](https://www.tarantool.io/en/doc/latest/book/monitoring/grafana_dashboard/).

### Example app

This repository provides preconfigured monitoring cluster with example Tarantool app and load generatior for local dashboard development and tests.

```bash
docker-compose up -d
```
will start 6 containers: Tarantool App, Tarantool Load Generator, Telegraf, InfluxDB, Prometheus and Grafana, which build cluster with two fully operational metrics datasources (InfluxDB and Prometheus), extracting metrics from Tarantool App example project.
We recommend using the exact versions we use in experimental cluster (e.g. Grafana v8.1.5).
After start, Grafana UI will be available at [localhost:3000](http://localhost:3000/).
You can also interact with Prometheus at [localhost:9090](http://localhost:9090/) and InfluxDB at [localhost:8086](http://localhost:8086/).

To set up an InfluxDB dashboard for monitoring example app, use the following variables:

- `Measurement`: `tarantool_app_http`;
- `Policy`: `default`.

To set up an Prometheus dashboard for monitoring example app, use the following variables:

- `Job`: `tarantool_app`;
- `Rate time range`: `2m`.

### Monitoring local app

If you want to monitor Tarantool cluster deployed on your local host, you can use monitoring cluster similar to example app one.

Configure Telegraf/Prometheus to monitor your own app in `example_cluster/telegraf/telegraf.localapp.conf` and `example_cluster/prometheus/prometheus.localapp.yml`.
Use `host.docker.internal` as your machine host in configuration and set cluster instances ports as targets and correct metrics HTTP path.
See more setup tips in [documentation](https://www.tarantool.io/en/doc/latest/book/monitoring/grafana_dashboard/).

Start cluster with 
```bash
docker-compose -f docker-compose.localapp.yml -p localapp-monitoring up -d
```
After start, Grafana UI will be available at [localhost:3000](http://localhost:3000/).
You can also interact with Prometheus at [localhost:9090](http://localhost:9090/) and InfluxDB at [localhost:8086](http://localhost:8086/).

## Manual build

`go` v.1.14 or greater is required to install build and test dependencies.
Run
```bash
make build-deps
```
to install dependencies that are required to build dashboards.

Run
```bash
make test-deps
```
to install build dependencies and dependencies that are required to run tests locally.

You can compile Prometheus dashboard template with
```bash
jsonnet -J ./vendor/ -e "local dashboard = import 'dashboard/prometheus_dashboard.libsonnet'; dashboard.build()"
```
and InfluxDB dashboard template with
```bash
jsonnet -J ./vendor/ -e "local dashboard = import 'dashboard/influxdb_dashboard.libsonnet'; dashboard.build()"
```

To save output into `output.json` file, use
```bash
jsonnet -J ./vendor/ -e "local dashboard = import 'dashboard/prometheus_dashboard.libsonnet'; dashboard.build()" -o ./output.json
```
and to save output into clipboard, use
```bash
jsonnet -J ./vendor/ -e "local dashboard = import 'dashboard/prometheus_dashboard.libsonnet'; dashboard.build()" | xclip -selection clipboard
```

You can run tests with
```bash
make run-tests
```

Compiled dashboard test files can be updated with
```bash
make update-tests
```
It also formats all source files with `jsonnetfmt`.


## Customization

If you're interested in building grafonnet dashboards or custom panels,
I suggest you to start with reading our grafonnet tutorial:
[in English](https://medium.com/@tarantool/grafana-as-code-b642cac9ae75),
[in Russian](https://habr.com/ru/company/vk/blog/577230/).

You can add your own custom panels to the bottom of the template dashboard.

1. Add tarantool/grafana-dashboard as a dependency in your project with jsonnet-bundler.
    Run
    ```bash
    jb init
    ```
    to initialize jsonnet-bundler and add this repo to `jsonnetfile.json` as a dependency:
    ```json
    {
      "version": 1,
      "dependencies": [
        {
          "source": {
            "git": {
              "remote": "https://github.com/tarantool/grafana-dashboard"
            }
          },
          "version": "master"
        }
      ],
      "legacyImports": true
    }
    ```
    Run
    ```bash
    jb install
    ```
    to install dependencies. [`grafonnet`](https://github.com/grafana/grafonnet-lib) library will also be installed as a transitive dependency.


2. There are two main templates: `grafana-dashboard/dashboard/prometheus_dashboard.libsonnet` and `grafana-dashboard/dashboard/influxdb_dashboard.libsonnet`.
    Import one of them in your jsonnet script to build your own custom dashboard.
    ```jsonnet
    # my_dashboard.jsonnet
    local prometheus_dashboard = import 'grafana-dashboard/dashboard/prometheus_dashboard.libsonnet';
    local influxdb_dashboard = import 'grafana-dashboard/dashboard/influxdb_dashboard.libsonnet';
    ```

3. To add your custom panels to a dashboard template, you must create panel objects.

    A row panel can be created by using the following script:
    ```jsonnet
    # my_dashboard.jsonnet
    local common_panels = import 'grafana-dashboard/dashboard/panels/common.libsonnet';

    local my_row = common_panels.row('My custom metrics')
    ```

    Panel with metrics data consists of a visualisation base (graph, table, stat etc.) and one or several datasource queries called "targets". To build a simple visualization graph, you may use `common_panels.default_graph` util.

    ```jsonnet
    # vendor/grafana-dashboard/dashboard/panels/common.libsonnet

    default_graph( # graph panel shortcut
      title, # The title of the graph panel
      description, # (optional) The description of the panel
      datasource, # Targets datasource. Use dashboard/variable.libsonnet to fill this value
      format, # (default 'none') Unit of the Y axes
      min, # (optional) Min of the Y axes
      max, # (optional) Max of the Y axes
      labelY1, # (optional) Label of the left Y axis
      decimals, # (default 3) Override automatic decimal precision for legend and tooltip
      decimalsY1, # (default 0) Override automatic decimal precision for the left Y axis
      legend_avg, # (default true) Show average in legend
      legend_max, # (default true) Show max in legend
      panel_height, # (default 8) Panel heigth in grid units
      panel_width, # (default 8) Panel width in grid units, max is 24
    )
    ```
    Panel size is set with grid units. Grafana uses square-type grid where dashboard width is 24 units. For example, row size is 24 x 1 units and Grafana new panel size is 12 x 9 units.

    If you want to build non-graph panel or a graph panel with more complicated configuration, use `grafonnet` templates.
    You must set a size of each panel before adding it to our dashboard template.
    For each `grafonnet` panel, add `{ gridPos: { w: width, h: height } }` to it.
    For example,
    ```jsonnet
    local grafana = import 'grafonnet/grafana.libsonnet';

    local my_graph = grafana.graphPanel.new(
      title='My custom panel',
      points=true,
    ) { gridPos: { w: 6, h: 4 } };
    ```

    To build a target, you may also use `common_panels` utils.
    ```jsonnet
    # vendor/grafana-dashboard/dashboard/panels/common.libsonnet

    default_metric_target( # plain "select metric" shortcut
      datasource, # Target datasource. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      metric_name, # Target metric name to select
      job, # (Prometheus only) Prometheus metrics job. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      policy, # (InfluxDB only) InfluxDB metrics policy. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      measurement, # (InfluxDB only) InfluxDB metrics measurement. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      converter, # (InfluxDB only, default 'mean') InfluxDB metrics converter (aggregation, selector, etc.)
    ),

    default_rps_target( # counter metric transformed to rps shortcut
      datasource, # Target datasource. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      metric_name, # Target metric name to select
      job, # (Prometheus only) Prometheus metrics job. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      rate_time_range, # (Prometheus only) Prometheus rps computation rate time range. Use vendor/grafana-dashboard/dashboard/variable.libsonnet to fill this value
      policy, # (InfluxDB only) InfluxDB metrics policy. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
      measurement, # (InfluxDB only) InfluxDB metrics measurement. Use grafana-dashboard/dashboard/variable.libsonnet to fill this value
    )
    ```

    To build more compound targets, use `grafonnet` library `prometheus` and `influxdb` templates.

    To use dashboard-wide input and template variables in your queries you must use `grafana-dashboard/dashboard/variable.libsonnet`.
    It imports json object with variable values you neet to set in your queries.

    If you want to build a Prometheus dashboard, use 
    ```jsonnet
    datasource=variable.datasource.prometheus,
    job=variable.prometheus.job,
    rate_time_range=variable.prometheus.rate_time_range
    ```
    in your targets.
    
    If you want to build an InfluxDB dashboard, use 
    ```jsonnet
    datasource=variable.datasource.influxdb,
    policy=variable.influxdb.policy,
    measurement=variable.influxdb.measurement
    ```
    in your targets.

    To add a target to a panel, call `addTarget(target)`.

    To summarise, you can build a simple 'select metric' prometheus panel with
    ```jsonnet
    local common_panels = import 'grafana-dashboard/dashboard/panels/common.libsonnet';
    local variable = import 'grafana-dashboard/dashboard/variable.libsonnet';

    local my_custom_component_memory_graph = common_panels.default_graph(
      title='My custom component memory',
      description=|||
        My custom component used memory.
        Shows mean value.
      |||,
      datasource=variable.datasource.prometheus,
      format='bytes',
      panel_width=12,
      panel_height=6,
    ).addTarget(common.default_metric_target(
      datasource=variable.datasource.prometheus,
      metric_name='my_component_memory',
      job=variable.prometheus.job,
    ))
    ```
    and a simple rps panel with
    ```jsonnet
    local common_panels = import 'grafana-dashboard/dashboard/panels/common.libsonnet';
    local variable = import 'grafana-dashboard/dashboard/variable.libsonnet';

    local my_custom_component_rps_graph = common.default_graph(
      title='My custom component load',
      description=|||
        My custom component processes requests
        and collects info on process to summary collector
        'my_component_load_metric'.
      |||,
      datasource=variable.datasource.prometheus,
      labelY1='requests per second',
      panel_width=18,
      panel_height=6,
    ).addTarget(common.default_rps_target(
      datasource=variable.datasource.prometheus,
      metric_name='my_component_load_metric_count',
      job=variable.prometheus.job,
      rate_time_range=variable.prometheus.rate_time_range,
    ))
    ```
    Corresponding InfluxDB panels could be built with
    ```jsonnet
    local common_panels = import 'grafana-dashboard/dashboard/panels/common.libsonnet';
    local variable = import 'grafana-dashboard/dashboard/variable.libsonnet';

    local my_custom_component_memory_graph = common_panels.default_graph(
      title='My custom component memory',
      description=|||
        My custom component used memory.
        Shows mean value.
      |||,
      datasource=variable.datasource.influxdb,
      format='bytes',
      panel_width=12,
      panel_height=6,
    ).addTarget(common.default_metric_target(
      datasource=variable.datasource.influxdb,
      metric_name='my_component_memory',
      policy=variable.influxdb.policy,
      measurement=variable.influxdb.measurement,
    )),

    local my_custom_component_rps_graph = common.default_graph(
      title='My custom component load',
      description=|||
        My custom component processes requests
        and collects info on process to summary collector
        'my_component_load_metric'.
      |||,
      datasource=variable.datasource.influxdb,
      labelY1='requests per second',
      panel_width=18,
      panel_height=6,
    ).addTarget(common.default_rps_target(
      datasource=variable.datasource.influxdb,
      metric_name='my_component_load_metric_count',
      policy=variable.influxdb.policy,
      measurement=variable.influxdb.measurement,
    ))
    ```
    For more panel tips and examples, please examine this template dashboard source code and test cases.

    To add your custom panels, call `addPanel(panel)` or `addPanels(panel_array)` in dashboard template:
    ```jsonnet
    # my_dashboard.jsonnet
    local prometheus_dashboard = import 'grafana-dashboard/dashboard/prometheus_dashboard.libsonnet';

    ...
    
    local my_dashboard_template = prometheus_dashboard.addPanels([
      my_row, my_custom_component_memory_graph, my_custom_component_rps_graph
    ]);
    ```

    Finally, call `build()` to compute panels positions and build a resulting dashboard:
    ```jsonnet
    # my_dashboard.jsonnet
    ...
    my_dashboard_template.build()
    ```
    Do not use `;` in the end of your script so resulting dashboard will be returned as output.

4. To save resulting dashboard into `output.json` file, use
    ```bash
    jsonnet -J ./vendor/ my_dashboard.jsonnet -o ./output.json
    ```
    and to save output into clipboard, use
    ```bash
    jsonnet -J ./vendor/ my_dashboard.jsonnet -o ./output.json | xclip -selection clipboard
    ```

## Contacts

If you have questions, please ask it on [StackOverflow](https://stackoverflow.com/questions/tagged/tarantool) or contact us in Telegram:

- [Russian-speaking chat](https://t.me/tarantoolru)
- [English-speaking chat](https://t.me/tarantool)
