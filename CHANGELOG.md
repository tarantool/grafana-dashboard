# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added
- Space tuples number and bsize panels
- Fiber stats panels

### Changes
- Rework "Tarantool memory memory miscellaneous" section to "Tarantool runtime overview"
- Vinyl disk panels name
- Update metrics version to 0.12.0

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
