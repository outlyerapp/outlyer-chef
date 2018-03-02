default['outlyer']['package_gpg_key'] = 'http://packages.outlyer.com/outlyer-pubkey.gpg'
default['outlyer']['package_gpg_id'] = 'ACB6D967'
default['outlyer']['package_distribution'] = 'stable'
case node['platform_family']
when 'rhel', 'fedora'
  default['outlyer']['package_repository'] = "http://packages.outlyer.com/#{node['outlyer']['package_distribution']}/el$releasever/$basearch/"
when 'amazon'
  default['outlyer']['package_repository'] = "http://packages.outlyer.com/#{node['outlyer']['package_distribution']}/el6/$basearch/"
when 'windows'
  default['outlyer']['package_repository'] = "https://s3.amazonaws.com/packages.outlyer.com/#{node['outlyer']['package_distribution']}/windows/"
when 'debian'
  default['outlyer']['package_repository'] = "http://packages.outlyer.com/debian"
end
