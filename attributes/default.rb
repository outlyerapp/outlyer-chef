default['outlyer']['agent']['version'] = nil
default['outlyer']['agent']['solo_mode'] = nil
default['outlyer']['agent']['debug'] = nil
default['outlyer']['agent']['docker'] = nil
default['outlyer']['agent']['name'] = nil

# install will install, uptionaly with a spesific version
default['outlyer']['agent']['install'] = true
# upgrade will install and upgrade to latest.  Any set version will be ignored if set.
default['outlyer']['agent']['upgrade'] = false

case node['platform_family']
when 'windows'
  default['outlyer']['agent']['home_dir'] = 'c:\outlyer'
  default['outlyer']['agent']['conf_dir'] = 'c:\outlyer'
  default['outlyer']['agent']['plugin_dir'] = 'c:\outlyer\plugins'
else
  default['outlyer']['agent']['home_dir'] = '/opt/outlyer'
  default['outlyer']['agent']['conf_dir'] = '/etc/outlyer'
  default['outlyer']['agent']['plugin_dir'] = '/etc/outlyer/plugins'
end

default['outlyer']['agent']['conf_file'] = 'agent.yaml'

default['outlyer']['agent']['agent_key'] = nil
default['outlyer']['agent']['server'] = 'wss://agent.outlyer.com'

# Hash of labels to apply to host
default['outlyer']['agent']['labels'] = {}
# List of host label keys to also apply to metrics
default['outlyer']['agent']['metric_labels'] = nil
