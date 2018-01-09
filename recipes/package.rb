#
# Cookbook Name:: dataloop
# Recipe:: package
#
# Copyright 2014, Dataloop Software Limited
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

include_recipe 'dataloop-agent::repo'

case node['platform_family']
when 'rhel', 'fedora'
  package_install_opts = ''
when 'debian'
  package_install_opts = ''
  if node['dataloop']['agent']['keep_old_config'] then
    package_install_opts = '-o Dpkg::Options::="--force-confold"'
  end
end

package "dataloop-agent" do
  version node['dataloop']['agent']['version']
  options package_install_opts
  action :upgrade
end
