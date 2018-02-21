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
