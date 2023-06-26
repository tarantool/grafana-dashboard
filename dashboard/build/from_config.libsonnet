local config = import 'dashboard/build/config.libsonnet';
local dashboard = import 'dashboard/build/dashboard.libsonnet';

function(cfg)
  dashboard(config.prepare(cfg))
