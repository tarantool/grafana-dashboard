local variable = import 'dashboard/variable.libsonnet';

{
  local supported_types = {
    [variable.datasource_type.prometheus]: true,
    [variable.datasource_type.influxdb]: true,
  },

  local validate_basic(cfg) =
    if std.type(cfg) != 'object' then
      error 'ConfigurationError: configuration must be non-empty and have key-value structure'
    else if std.objectHas(cfg, 'type') == false then
      error "ConfigurationError: 'type' field is required (for example, 'type: prometheus')"
    else if (cfg.type in supported_types) == false then
      error std.format("ConfigurationError: 'type' field possible values: %s", std.join(', ', std.objectFields(supported_types)))
    else
      cfg,

  local default_cfg = {
    [variable.datasource_type.prometheus]: {
      type: variable.datasource_type.prometheus,
      title: 'Tarantool dashboard',
      datasource: variable.datasource.prometheus,
      filters: { alias: ['=~', variable.prometheus.alias], job: ['=~', variable.prometheus.job] },
    },
    [variable.datasource_type.influxdb]: {
      type: variable.datasource_type.influxdb,
      title: 'Tarantool dashboard',
      datasource: variable.datasource.influxdb,
      policy: variable.influxdb.policy,
      measurement: variable.influxdb.measurement,
      filters: { label_pairs_alias: ['=~', variable.influxdb.alias] },
    },
  },

  local fill_defaults(cfg) =
    default_cfg[cfg.type] + cfg +
    // Jsonnet object merge process only top-level, we need to process embedded fields explicitly
    { filters: default_cfg[cfg.type].filters + std.get(cfg, 'filters', default={}) },

  local schema = {
    [variable.datasource_type.prometheus]: {
      type: 'string',
      title: 'string',
      datasource: 'string',
      filters: 'object',
    },
    [variable.datasource_type.influxdb]: {
      type: 'string',
      title: 'string',
      datasource: 'string',
      policy: 'string',
      measurement: 'string',
      filters: 'object',
    },
  },

  local assert_type(k, v, type, err_tmpl) =
    if std.type(v) != type then
      error std.format(err_tmpl, [k, type, std.type(v)])
    else
      true,

  local validate_filter(key, value) =
    [assert_type(key, value, 'array', "ConfigurationError: field 'filters.%s' expected type %s, got %s")] + [
      if std.length(value) != 2 then
        error std.format("ConfigurationError: field 'filters.%s' expected to be in format [condition, value]", key)
      else
        true,
    ] + [assert_type(key, value[0], 'string', "ConfigurationError: field 'filters.%s[0]' expected type %s, got %s")] +
    [assert_type(key, value[1], 'string', "ConfigurationError: field 'filters.%s[1]' expected type %s, got %s")],

  local _validate_fields(cfg, schema) =
    [
      if (item.key in schema) == false then
        error std.format("ConfigurationError: %s configuration unknown field '%s'", [cfg.type, item.key])
      else
        assert_type(item.key, item.value, schema[item.key], "ConfigurationError: field '%s' expected type %s, got %s")
      for item in std.objectKeysValues(cfg)
    ] + std.flattenArrays([
      validate_filter(item.key, item.value)
      for item in std.objectKeysValues(cfg.filters)
    ]),

  local validate_fields(cfg) =
    if std.all(_validate_fields(cfg, schema[cfg.type])) then cfg,

  prepare(cfg)::
    validate_fields(fill_defaults(validate_basic(cfg))),
}
