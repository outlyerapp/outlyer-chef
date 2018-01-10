#
# Cookbook Name:: outlyer
# Recipe:: file
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


case node['platform']
when 'rhel', 'fedora', 'centos'
  package_install_opts = ''
  distro = 'centos'
  package = '.rpm'
  arch     = '_X86_64'
when 'debian'
  package_install_opts = ''
  distro = 'debian'
  package = '.deb'
  arch     = '_amd64'
  if node['outlyer']['agent']['keep_old_config'] then
    package_install_opts = '-o Dpkg::Options::="--force-confold"'
  end
when 'ubuntu'
  package_install_opts = ''
  distro = 'ubuntu'
  package = '.deb'
  arch     = '_amd64'
  if node['outlyer']['agent']['keep_old_config'] then
    package_install_opts = '-o Dpkg::Options::="--force-confold"'
  end
end


url = "#{node['outlyer']['agent']['package']['location']}#{node['outlyer']['agent']['package']['maturity']}/#{distro}/#{node['platform_version']}/pkg/outlyer-agent_#{node['outlyer']['agent']['package']['version']}#{arch}#{package}"
log url
remote_file "/var/tmp/outlyer#{package}" do
  source url
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

dpkg_package "outlyer-agent" do
  version node['outlyer']['agent']['version']
  options package_install_opts
  source "/var/tmp/outlyer#{package}"
  only_if {package == '.deb'}
  action :upgrade
end

yum_package "outlyer-agent" do
  version node['outlyer']['agent']['version']
  options package_install_opts
  source "/var/tmp/outlyer#{package}"
  only_if {package == '.rpm'}
  action :upgrade
end
