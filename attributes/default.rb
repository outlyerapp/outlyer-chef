default['outlyer']['agent']['install_method'] = 'file' # package or bash or file
default['outlyer']['agent']['keep_old_config'] = nil # or true to keep old config
default['outlyer']['agent']['version'] = nil
default['outlyer']['agent']['solo_mode'] = 'no'
default['outlyer']['agent']['debug'] = 'no'
default['outlyer']['agent']['docker'] = 'no'

default['outlyer']['agent']['init'] = "/etc/init.d/outlyer-agent"
default['outlyer']['agent']['run_dir'] = "/opt/outlyer/plugins/rpc"
default['outlyer']['agent']['log_dir'] = "/var/log/outlyer"
default['outlyer']['agent']['conf_dir'] = "/etc/outlyer"
default['outlyer']['agent']['conf_file'] = "agent.yaml"
default['outlyer']['agent']['statsd_file'] = "statsd.yaml"
default['outlyer']['agent']['init_vars_file'] = 'outlyer-agent'
default['outlyer']['agent']['deregister_onstop'] = 'yes' # or no

case node['platform_family']
when 'rhel', 'fedora'
  default['outlyer']['agent']['init_vars_dir'] = '/etc/sysconfig'
when 'debian'
  default['outlyer']['agent']['init_vars_dir'] = '/etc/default'
end

default['outlyer']['agent']['api_key'] = nil
default['outlyer']['agent']['server'] = "wss://agent.outlyer.com"

# Hash of labels to apply to host
default['outlyer']['agent']['labels'] = {}
# List of host label keys to also apply to metrics
default['outlyer']['agent']['metric_labels'] = ["foo"]

default['outlyer']['agent']['name'] = nil
