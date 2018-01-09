windows_package 'outlyer-agent' do
  source 'https://download.outlyer.io/windows/latest/outlyer-agent-1.1.32-1_x86.exe'
  remote_file_attributes ({
    :checksum => '2cd19b931355e23eee095ffd4d8140cfe3625741eff503615c821907a3dcd546',
    :path => 'C:\\outlyer-agent.exe'
  })
  #installer_type :custom
  options ''
end

template node['outlyer']['agent']['conf_file'] do
  path 'c:\outlyer\agent.yaml'
  source "agent.yaml.erb"
  notifies :restart, "windows_service[outlyer-agent]", :delayed
end

windows_service 'outlyer-agent' do
  action :configure_startup
  startup_type :manual
end
