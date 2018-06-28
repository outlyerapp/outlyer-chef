default['outlyer']['package_gpg_key'] = 'https://packages.outlyer.com/outlyer-pubkey.gpg'
default['outlyer']['package_gpg_id'] = 'ACB6D967'
default['outlyer']['package_distribution'] = 'stable'
case node['platform_family']
when 'rhel', 'fedora'
  default['outlyer']['package_repository'] = "https://packages.outlyer.com/#{node['outlyer']['package_distribution']}/el$releasever/$basearch/"
when 'amazon'
  case node['platform_version']
  when '2'
    default['outlyer']['package_repository'] = "https://packages.outlyer.com/#{node['outlyer']['package_distribution']}/el7/$basearch/"
  else
    default['outlyer']['package_repository'] = "https://packages.outlyer.com/#{node['outlyer']['package_distribution']}/el6/$basearch/"
  end
when 'windows'
  default['outlyer']['package_repository'] = "https://packages.outlyer.com/#{node['outlyer']['package_distribution']}/windows/"
when 'debian'
  default['outlyer']['package_repository'] = "https://packages.outlyer.com/debian"
end
