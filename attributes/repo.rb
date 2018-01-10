default['outlyer']['package_gpg_key'] = 'https://download.outlyer.io/pubkey.gpg'
default['outlyer']['package_gpg_id'] = '113E2B8D'
default['outlyer']['package_distribution'] = 'stable'
case node['platform_family']
when 'rhel', 'fedora'
  default['outlyer']['package_repository'] = "https://download.outlyer.io/packages/#{node['outlyer']['package_distribution']}/el$releasever/$basearch/"
when 'debian'
  default['outlyer']['package_repository'] = "https://download.outlyer.io/deb"
end
