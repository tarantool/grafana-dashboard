If this pull request introduces support for new metrics, do not forget to
- [ ] add Grafana panel;
- [ ] run `make update-tests` to build new dashboard artifacts;
- [ ] add example application code to generate non-null metrics;
- [ ] attach a screenshot of a new panel to the PR description;
- [ ] add new Telegraf tag key, if relevant,
  - [ ] to all `telegraf.conf` files,
  - [ ] to "Grafana dashboard" documentation page;
- [ ] add alert example, if relevant,
  - [ ] to `alerts.yml`,
  - [ ] to "Alerting" documentation page;
- [ ] update `supported_metrics.md`.

In any case, do not forget to
- [ ] link an issue,
- [ ] add a CHANGELOG entry.
