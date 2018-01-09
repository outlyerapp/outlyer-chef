#
# Cookbook Name:: dataloop
# Recipe:: default
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

case node['platform_family']
when 'rhel', 'fedora'

  yum_repository 'dataloop' do
    description 'Dataloop Repository'
    baseurl      node['dataloop']['package_repository']
    gpgkey       node['dataloop']['package_gpg_key']
    action       :create
  end

when 'debian'
  include_recipe 'apt::default'

  # remove any expired apt-key
  execute "remove expired key" do
    command "apt-key del #{node['dataloop']['package_gpg_id']}"
    only_if "apt-key list | grep #{node['dataloop']['package_gpg_id']} | grep expired"
  end
    
  apt_repository 'dataloop' do
    uri          node['dataloop']['package_repository']
    distribution node['kernel']['machine'] + '/'
    key          node['dataloop']['package_gpg_id']
    keyserver   'keyserver.ubuntu.com'
    distribution node['dataloop']['package_distribution']
    components   ['main']
  end
end
