name             "outlyer-agent"
maintainer       'Dataloop Software Limited'
maintainer_email 'support@outlyer.com'
license          'All rights reserved'
description      'Installs/Configures outlyer agent'
issues_url       'https://github.com/outlyerapp/outlyer-chef/issues' if respond_to?(:issues_url)
source_url       'https://github.com/outlyerapp/outlyer-chef' if respond_to?(:source_url)
supports         'debian'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'

chef_version '>= 12.0'

depends 'apt',   '~> 2.9.2'
depends 'yum',   '~> 3.8.2'
