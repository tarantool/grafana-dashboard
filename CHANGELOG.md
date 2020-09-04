# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
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
### Added
- Ready for import InfluxDB dashboard: HTTP panels, memory panels, space operations panels
- Experimental docker cluster: Tarantool + Telegraf + InfluxDB + Grafana, Tarantool + Prometheus + Grafana
- Simple test on InfluxDB dashboard
- Build environment and documentation
