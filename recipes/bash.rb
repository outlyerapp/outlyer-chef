#
# Cookbook Name:: outlyer
# Recipe:: bash
#
# Copyright 2013, Dataloop Software Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

user node['outlyer']['node']['user'] do
    action :create
    supports :mange_home => true
    comment "Dataloop User Account"
    home node['outlyer']['agent']['run_dir']
end

remote_file node['outlyer']['agent']['bin_dir'] do
  source node['outlyer']['agent']['uri']
  checksum node['outlyer']['agent']['checksum']
  mode 0755
end

directory node['outlyer']['agent']['run_dir'] do
  action :create 
  owner node['outlyer']['node']['user']
  group node['outlyer']['node']['user']
  mode 0755
  recursive true
end

directory "#{node['outlyer']['agent']['run_dir']}" do
  action :create 
  owner node['outlyer']['node']['user']
  group node['outlyer']['node']['user']
  mode 0755
  recursive true
end


directory node['outlyer']['agent']['log_dir'] do
  action :create 
  owner node['outlyer']['node']['user']
  group node['outlyer']['node']['user']
  mode 0755
end

directory node['outlyer']['agent']['conf_dir'] do
  action :create 
  owner node['outlyer']['node']['user']
  group node['outlyer']['node']['user']
  mode 0755
end

template node['outlyer']['agent']['init'] do
  source "outlyer-agent.erb"
  owner "root"
  group "root"
  mode 0755
end

## I'm not particularly proud of this but for some reason the
#permissions on /opt/outlyer keep being reset to "root:root",
#preventing the agent from starting properly.
#
#This bash script forces the permissions to the correct settings and
#allows the agent to start properly.
bash "hack permissions" do
    user "root"
    cwd  "/opt"
    code <<-EOH
    chown -Rvf outlyer:root /opt/outlyer
    EOH
end
