default['outlyer']['agent']['keep_old_config'] = nil # or true to keep old config
default['outlyer']['agent']['version'] = nil
default['outlyer']['agent']['solo_mode'] = 'false'
default['outlyer']['agent']['debug'] = 'false'
default['outlyer']['agent']['docker'] = 'false'
default['outlyer']['agent']['name'] = nil

default['outlyer']['agent']['conf_dir'] = "/etc/outlyer"
default['outlyer']['agent']['conf_file'] = "agent.yaml"

default['outlyer']['agent']['api_key'] = nil
default['outlyer']['agent']['server'] = "wss://agent.outlyer.com"

# Hash of labels to apply to host
default['outlyer']['agent']['labels'] = {}
# List of host label keys to also apply to metrics
default['outlyer']['agent']['metric_labels'] = []
