#
# Cookbook Name:: outlyer-agent
# Recipe:: default
#
# Copyright 2018, Dataloop Software Limited
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

include_recipe "outlyer-agent::package"

template node['outlyer']['agent']['conf_file'] do
  path "#{node['outlyer']['agent']['conf_dir']}/#{node['outlyer']['agent']['conf_file']}"
  source "agent.yaml.erb"
  if node['platform_family'] == 'windows'
    owner "Administrators"
  else
    owner "root"
    group "outlyer"
    mode 0640
  end
  notifies :restart, "service[outlyer-agent]", :delayed
end

if node['platform_family'] != 'windows'
    template "circusd.ini" do
      path "#{node['outlyer']['agent']['conf_dir']}/circusd.ini"
      source "circusd.ini.erb"
      owner "root"
      group "outlyer"
      mode 0640
      notifies :restart, "service[outlyer-agent]", :delayed
    end
end

service "outlyer-agent" do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :start ]
end
