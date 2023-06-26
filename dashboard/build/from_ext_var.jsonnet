local config = import 'dashboard/build/config.libsonnet';
local dashboard = import 'dashboard/build/dashboard.libsonnet';

local DATASOURCE_TYPE = std.extVar('DATASOURCE_TYPE');
local DASHBOARD_TEMPLATE = std.extVar('DASHBOARD_TEMPLATE');
local DATASOURCE = std.extVar('DATASOURCE');
local JOB = std.extVar('JOB');
local POLICY = std.extVar('POLICY');
local MEASUREMENT = std.extVar('MEASUREMENT');
local WITH_INSTANCE_VARIABLE = (std.asciiUpper(std.extVar('WITH_INSTANCE_VARIABLE')) == 'TRUE');
local TITLE = if std.extVar('TITLE') != '' then std.extVar('TITLE') else null;

local title = if TITLE != null then TITLE else
  if DASHBOARD_TEMPLATE == 'Tarantool' then 'Tarantool dashboard'
  else if DASHBOARD_TEMPLATE == 'TDG' then 'Tarantool Data Grid dashboard';

local description =
  if DASHBOARD_TEMPLATE == 'Tarantool' then
    'Dashboard for Tarantool application and database server monitoring, based on grafonnet library.'
  else if DASHBOARD_TEMPLATE == 'TDG' then
    'Dashboard for Tarantool Data Grid ver. 2 application monitoring, based on grafonnet library.';

local grafana_tags =
  if DASHBOARD_TEMPLATE == 'Tarantool' then ['tarantool']
  else if DASHBOARD_TEMPLATE == 'TDG' then ['tarantool', 'TDG'];
local sections =
  if DASHBOARD_TEMPLATE == 'Tarantool' then [
    'cluster',
    'replication',
    'http',
    'net',
    'slab',
    'mvcc',
    'space',
    'vinyl',
    'cpu',
    'runtime',
    'luajit',
    'operations',
    'crud',
    'expirationd',
  ]
  else if DASHBOARD_TEMPLATE == 'TDG' then [
    'cluster',
    'replication',
    'net',
    'slab',
    'mvcc',
    'space',
    'vinyl',
    'cpu_extended',
    'runtime',
    'luajit',
    'operations',
    'tdg_kafka_common',
    'tdg_kafka_brokers',
    'tdg_kafka_topics',
    'tdg_kafka_consumer',
    'tdg_kafka_producer',
    'expirationd',
    'tdg_tuples',
    'tdg_file_connectors',
    'tdg_graphql',
    'tdg_iproto',
    'tdg_rest_api',
    'tdg_tasks',
  ];

local cfg =
  if DATASOURCE_TYPE == 'prometheus' then
    config.prepare({
      type: DATASOURCE_TYPE,
      title: title,
      description: description,
      grafana_tags: grafana_tags,
      datasource: DATASOURCE,
      filters: { job: ['=~', JOB] } + if WITH_INSTANCE_VARIABLE then { alias: ['=~', '$alias'] } else {},
      sections: sections,
    })
  else if DATASOURCE_TYPE == 'influxdb' then
    config.prepare({
      type: DATASOURCE_TYPE,
      title: title,
      description: description,
      grafana_tags: grafana_tags,
      datasource: DATASOURCE,
      policy: POLICY,
      measurement: MEASUREMENT,
      filters: if WITH_INSTANCE_VARIABLE then { label_pairs_alias: ['=~', '/^$alias$/'] } else {},
      sections: sections,
    });

dashboard(cfg)
