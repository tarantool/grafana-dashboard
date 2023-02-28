# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed
- Replace LuaJit deprecated metrics with new ones


## [1.5.0] - 2022-09-22
Grafana revisions: [InfluxDB revision 15](https://grafana.com/api/dashboards/12567/revisions/15/download), [Prometheus revision 15](https://grafana.com/api/dashboards/13054/revisions/15/download), [InfluxDB TDG revision 4](https://grafana.com/api/dashboards/16405/revisions/4/download), [Prometheus TDG revision 4](https://grafana.com/api/dashboards/16406/revisions/4/download).

### Added
- Variable to select displayed cluster instances


## [1.4.0] - 2022-08-03
Grafana revisions: [InfluxDB revision 14](https://grafana.com/api/dashboards/12567/revisions/14/download), [Prometheus revision 14](https://grafana.com/api/dashboards/13054/revisions/14/download), [InfluxDB TDG revision 3](https://grafana.com/api/dashboards/16405/revisions/3/download), [Prometheus TDG revision 3](https://grafana.com/api/dashboards/16406/revisions/3/download).

### Added
- Options to build static dashboards
- Runtime arena memory panel
- Vinyl tuple cache and level 0 memory panels

### Changed
- Set default Prometheus job to `tarantool`
- Set default InfluxDB measurement to `tarantool_http`
- Use in-built `$__rate_interval` instead of user-defined `$rate_time_range`
- Use `fill(null)` in InfluxQL requests


## [1.3.0] - 2022-06-29
Grafana revisions: [InfluxDB revision 13](https://grafana.com/api/dashboards/12567/revisions/13/download), [Prometheus revision 13](https://grafana.com/api/dashboards/13054/revisions/13/download), [InfluxDB TDG revision 2](https://grafana.com/api/dashboards/16405/revisions/2/download), [Prometheus TDG revision 2](https://grafana.com/api/dashboards/16406/revisions/2/download).

### Added
- Panels for expirationd module statistics


## [1.2.1] - 2022-06-24
Grafana revisions: [InfluxDB revision 12](https://grafana.com/api/dashboards/12567/revisions/12/download), [Prometheus revision 12](https://grafana.com/api/dashboards/13054/revisions/12/download), [InfluxDB TDG revision 2](https://grafana.com/api/dashboards/16405/revisions/2/download), [Prometheus TDG revision 2](https://grafana.com/api/dashboards/16406/revisions/2/download).

## Fixed
- TDG dashboard file connectors processed panel name changed to "Total files processed"
- Set valid metrics name to TDG dashboard Kafka partitions panels
- Display only 99th quantile for Prometheus TDG Kafka metrics


## [1.2.0] - 2022-06-08
Grafana revisions: [InfluxDB revision 12](https://grafana.com/api/dashboards/12567/revisions/12/download), [Prometheus revision 12](https://grafana.com/api/dashboards/13054/revisions/12/download), [InfluxDB TDG revision 1](https://grafana.com/api/dashboards/16405/revisions/1/download), [Prometheus TDG revision 1](https://grafana.com/api/dashboards/16406/revisions/1/download).

### Added
- TDG (ver. 2) example cluster draft
- Dashboard templates for TDG (ver. 2)
- Kafka metrics panels for TDG dashboard
- Thread CPU panels for TDG dashboard
- expirationd panels for TDG dashboard
- Tuples panels for TDG dashboard
- File connectors panels for TDG dashboard
- GraphQL requests panels for TDG dashboard
- IProto requests panels for TDG dashboard
- REST API requests panels for TDG dashboard
- Task statistics panels for TDG dashboard

### Changed
- Change replication status panel labels

### Fixed
- Remove rate from fiber context switches panel
- Remove fiber context switches alert example


## [1.1.0] - 2022-05-17
Grafana revisions: [InfluxDB revision 10](https://grafana.com/api/dashboards/12567/revisions/10/download), [Prometheus revision 11](https://grafana.com/api/dashboards/13054/revisions/11/download)

### Added
- Panels and alerts for CRUD module statistics

### Changed
- Set default InfluxDB policy to `autogen`


## [1.0.0] - 2022-05-06
Grafana revisions: [InfluxDB revision 9](https://grafana.com/api/dashboards/12567/revisions/9/download), [Prometheus revision 10](https://grafana.com/api/dashboards/13054/revisions/10/download)

### Added
- Space tuples number and bsize panels
- Fiber stats panels and alert example
- Event loop time panel and alert example
- LuaJit statistics panels
- Transactions memory panel
- Net memory and new binary connections panels
- Vinyl index and bloom filter memory panels
- Clock delta panel
- Replication status panel and alert example
- Read only status panel
- Vinyl regulator blocked writers panel
- Net requests in progress/in stream queue panels

### Changed
- Rework "Tarantool memory memory miscellaneous" section to "Tarantool runtime overview"
- Vinyl disk panels name
- Update metrics version to 0.13.0
- Update panel descriptions
- Collapse dashboard rows
- Use new metrics instead of deprecated ones
- Bump Grafana requirement to 8.x


## [0.3.3] - 2021-10-08
Grafana revisions: [InfluxDB revision 8](https://grafana.com/api/dashboards/12567/revisions/8/download), [Prometheus revision 8](https://grafana.com/api/dashboards/13054/revisions/8/download)

### Added
- Overall net requests panel for Prometheus dashboard

### Changed
- Use green color for low values in overall panels
- Configure default collector in example cluster
- Make variables comparison consistent in Prometheus dashboard


## [0.3.2] - 2021-08-20
Grafana revisions: [InfluxDB revision 7](https://grafana.com/api/dashboards/12567/revisions/7/download), [Prometheus revision 7](https://grafana.com/api/dashboards/13054/revisions/7/download)

### Changed
- Show CPU time in percents


## [0.3.1] - 2021-07-08
Grafana revisions: [InfluxDB revision 6](https://grafana.com/api/dashboards/12567/revisions/6/download), [Prometheus revision 6](https://grafana.com/api/dashboards/13054/revisions/6/download)

### Added
- Support adding custom panels before dashboard build
- Simple customization guide
- Cluster for local Tarantool app monitoring
- Vinyl panels and alert examples

### Changed
- Code rework: introduce grid generation, separate dashboards code
- Code rework: use common graph template to reduce code copypaste, set panel size in code
- Code rework: add dashboard wrap-up, group panels into sections
- Rename "Tarantool memory allocation overview" to "Tarantool memtx allocation overview"


## [0.3.0] - 2021-06-17
Grafana revisions: [InfluxDB revision 5](https://grafana.com/api/dashboards/12567/revisions/5/download), [Prometheus revision 5](https://grafana.com/api/dashboards/13054/revisions/5/download)

### Added
- Prometheus example alert rules (instance state, memory usage, HTTP load and latency rule examples, etc)
- Test Prometheus example alert rules with promtool
- Cartridge issues metrics labels to Telegraf configuration
- Cartridge issues panels and "Cluster overview" row
- Network activity row and panels
- Non-CRUD operations panels
- CPU time getrusage panels
- Replication lag panel

### Changed
- Update metrics version to 0.9.0
- Separate app cluster and load generator in example docker stand
- Use cartridge-cli to run and setup example app cluster instead of luatest
- Group Prometheus cluster overview panels into "Cluster overview" row
- Rework "Tarantool spaces statistics" block to "Tarantool operations statistics"
- Use Tarantool 2.x instead of Tarantool 1.x in test app and load generator

### Fixed
- Add missing space and replication metrics labels to Telegraf configuration


## [0.2.3] - 2021-03-11
Grafana revisions: [InfluxDB revision 4](https://grafana.com/api/dashboards/12567/revisions/4/download), [Prometheus revision 4](https://grafana.com/api/dashboards/13054/revisions/4/download)

### Added
- Memory miscellaneous row with Lua memory panel

### Changed
- Rename memory overview row


## [0.2.2] - 2021-01-28
Grafana revisions: [Prometheus revision 3](https://grafana.com/api/dashboards/13054/revisions/3/download)

### Changed
- Make Prometheus rps graphs rate() time range configurable


## [0.2.1] - 2020-12-11
Grafana revisions: [Prometheus revision 2](https://grafana.com/api/dashboards/13054/revisions/2/download)

### Added
- Cluster overview panels for Prometheus


## [0.2.0] - 2020-09-23
Grafana revisions: [InfluxDB revision 3](https://grafana.com/api/dashboards/12567/revisions/3/download), [Prometheus revision 1](https://grafana.com/api/dashboards/13054/revisions/1/download)

### Added
- Dashboard for Prometheus

### Changed
- Update metrics version to 0.5.0
- Replace average latency collector with summary collector in example cluster
- Replace average latency panels with summary 99th percentile panels

### Fixed
- Example cluster now starts successfully
- Example cluster metrics no more breaks Prometheus metrics collect


## [0.1.1] - 2020-09-04
Grafana revisions: [InfluxDB revision 2](https://grafana.com/api/dashboards/12567/revisions/2/download)

### Added
- Publish dashboard on Grafana official and community built dashboards
- Generate HTTP and space operations traffic for example cluster with luatest

### Changed
- Update metrics version to 0.3.0 in experimental cluster
- Rework example Tarantool instance on "cartridge.roles.metrics"
- Rework example Tarantool docker to start multiple instances with luatest
- Make InfluxDB policy configurable
- Documentation improvements and fixes


## [0.1.0] - 2020-06-30
Grafana revisions: [InfluxDB revision 1](https://grafana.com/api/dashboards/12567/revisions/1/download)

### Added
- Ready for import InfluxDB dashboard: HTTP panels, memory panels, space operations panels
- Experimental docker cluster: Tarantool + Telegraf + InfluxDB + Grafana, Tarantool + Prometheus + Grafana
- Simple test on InfluxDB dashboard
- Build environment and documentation
