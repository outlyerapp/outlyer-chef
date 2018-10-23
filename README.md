Outlyer-agent Cookbook
=================
This cookbook installs the Outlyer agent on a host.

Requirements
------------
* Chef 13 or higher
* Chef 13 or higher on Microsoft Windows platforms
* see metadata.rb for cookbook dependencies

Platforms
---------
* Ubuntu 12.04, 14.04, 16.04
* Rhel/Centos >= 6

Optional
------------
Encrypted Data Bag called outlyer/keys to store the agent key securely.

Attributes
----------
```
* node['outlyer']['agent']['agent_key'] : __REQUIRED__ you must set this to the agent_key for you account. Your servers will need it to communicate with outlyer.io. It is stored on you servers in a protected file.
* node['outlyer']['agent']['keep_old_config'] : true to keep old config on debian and force install
* node['outlyer']['agent']['version'] : Choose the version of agent to install. Set to _nil_ for the latest.
* node['outlyer']['agent']['solo_mode'] : Whether you run in solo mode with RPC turned off
* node['outlyer']['agent']['debug'] : Debugging flag
* node['outlyer']['agent']['docker'] : Choose whether to discover and collect metrics for Docker containers
* node['outlyer']['agent']['name'] : A custom name for this agent, default will be hostname if not set
* node['outlyer']['agent']['home_dir'] : location for the agent to store its files
* node['outlyer']['agent']['conf_dir'] : location for check config files
* node['outlyer']['agent']['plugin_dir'] : location for check plugin files
* node['outlyer']['agent']['conf_file'] : override agent config file
* node['outlyer']['agent']['server'] : outlyer agent enpoint, should never need changing
* node['outlyer']['agent']['labels'] : Hash of labels to apply to host
* node['outlyer']['agent']['metric_labels'] : List of host label keys to also apply to metrics
```

Usage
-----
Import this cookbook into your environment:

* Berkshelf:
  * cookbook "outlyer-agent", git: "https://github.com/outlyerapp/outlyer-chef", tag: "v1.0.1"

* Librarian:
  * cookbook 'outlyer-agent', :git => 'https://github.com/outlyerapp/outlyer-chef', :ref => 'v1.0.1'


Include the default recipe in your nodes run list and set at least your agent key

```
{
  default_attributes: {
    outlyer: {
      agent: {
        agent_key: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
      }
    }
  },
  run_list: [
    recipe[outlyer-agent]
  ]
}
```

Microsoft Windows
-----------------
Include the windows recipe only in your run list


Tags
----
Use `node['outlyer']['agent']['tags']` to setup automatic tags so you don't need to set them in the web UI


Testing
-------
You can use test-kitchen
Testing for this cookbook has been setup with Librarian-chef and Test-Kitchen utilising vagrant as the machine provider

* Clone the repository
* copy .kitchen.yml to a local version .kitchen.local.yml (this is not checked into git)
* edit the agent_key attribute in .kitchen.local.yml with your value
* replace the auth_token with a fresh one in test/integration/default/integration_test.yml
* run `kitchen converge outlyer-agent-<vagrant box name>` then `kitchen verify <vagrant box name>`

Contributing
------------
Pull requests welcome.

License and Authors
-------------------
Author: Oliver Greenaway <oliver.greenaway@outlyer.com>  
Author: Tom Ashley <tom.ashley@outlyer.con>

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


Deprecated / In development
---------------------------

Create an encrypted data bag named outlyer/keys with the following content and place
the secret key in /etc/chef/edbkeys/outlyer.key on each node that you
want to use this cookbook with.

```json
{
      "id": "keys",
      "agent_key": "YOUR AGENT KEY"
}
```
Now include `outlyer` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[outlyer]"
  ]
}
```
