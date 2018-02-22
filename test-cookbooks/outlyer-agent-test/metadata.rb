name             "outlyer-agent-test"
maintainer       'Dataloop Software Limited'
maintainer_email 'support@outlyer.com'
license          'All rights reserved'
description      'Installs/Configures outlyer agent'
issues_url       'https://github.com/outlyerapp/outlyer-chef/issues' if respond_to?(:issues_url)
source_url       'https://github.com/outlyerapp/outlyer-chef' if respond_to?(:source_url)
chef_version     '>= 12.17' if respond_to?(:chef_version)
supports         'debian'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'