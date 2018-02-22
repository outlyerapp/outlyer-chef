require 'rspec/retry'
require 'securerandom'

ACCOUNT = 'outlyer' #'int-tests'
AUTH_TOKEN = attribute('auth_token', default: '', description: 'authentication token')
API_URL = attribute('api_url', default: '', description: 'public api url')

hostname = ''
test_id = SecureRandom.uuid

chef_apply_bin = '/opt/chef/bin/chef-apply'
chef_solo_cmd = '/opt/chef/bin/chef-solo -c /tmp/kitchen/solo.rb'
log_file = '/var/log/outlyer/agent.log'
node_json_path = '/Users/vagrant/Desktop/outlyer-agent/node.json'
pip_cmd = '/opt/outlyer/embedded/bin/pip3'
ruby_bin = '/opt/chef/embedded/bin/ruby'
service_start = 'systemctl start outlyer-agent'
service_stop = 'systemctl stop outlyer-agent'
service_restart = 'systemctl restart outlyer-agent'

if os[:family] == 'windows'
  chef_apply_bin = 'c:/opscode/chef/bin/chef-apply.bat'
  chef_solo_cmd = 'c:/opscode/chef/bin/chef-solo.bat -c c:/Users/vagrant/AppData/Local/Temp/kitchen/solo.rb'
  log_file = 'c:/outlyer/agent.log'
  node_json_path = 'c:/Users/vagrant/Desktop/outlyer-agent/node.json'
  pip_cmd = 'c:/outlyer/embedded/bin/python.exe c:/outlyer/embedded/bin/Scripts/pip.exe'
  ruby_bin = 'c:/opscode/chef/embedded/bin/ruby.exe'
  service_start = chef_apply_bin + ' -e "service \'outlyer-agent\' do action :start end"'
  service_stop = chef_apply_bin + ' -e "service \'outlyer-agent\' do action :stop end"'
  service_restart = chef_apply_bin + ' -e "service \'outlyer-agent\' do action :restart end"'
end

copy_node_json = ruby_bin + ' -r fileutils -e "FileUtils.copy(\'' + node_json_path + '.tmpl\', \'' + node_json_path + '\')"'
update_node_json = ruby_bin + ' -r fileutils -e "text=File.read(\'' + node_json_path + '.tmpl\'); content = text.gsub(/<TEMP_ID>/, \'' + test_id + '\'); File.open(\'' + node_json_path + '\', \'w\') {|f| f << content }"'
update_template = chef_solo_cmd + ' -j ' + node_json_path + ' -o "recipe[outlyer-agent]"'

# might go away when https://github.com/chef/inspec/issues/2483 is implemented
windows_service_ps_cmd = "Get-WmiObject -Class Win32_Service -Filter  \"name = 'outlyer-agent'\" |fl * -Force"
windows_service_regex = {
  disabled: /StartMode\s*:\sDisabled/,
  auto: /StartMode\s*:\sAuto/,
  stopped: /State\s*:\sStopped/,
  running: /State\s*:\sRunning/
}

control "agent" do
  impact 1.0
  title "Agent and it's requirements are installed"

  # pip packages are actually installed - based on requirements.txt in bourne
  describe command(pip_cmd + ' show aiofiles') do
    its('stdout') { should match 'Version: 0.3.2' }
  end
  describe command(pip_cmd + ' show apscheduler') do
    its('stdout') { should match 'Version: 3.4.0' }
  end
  describe command(pip_cmd + ' show avro-python3') do
    its('stdout') { should match 'Version: 1.8.2' }
  end
  describe command(pip_cmd + ' show docker') do
    its('stdout') { should match 'Version: 2.6.1' }
  end
  describe command(pip_cmd + ' show jmxquery') do
    its('stdout') { should match 'Version: 0.2.0' }
  end
  describe command(pip_cmd + ' show kubernetes') do
    its('stdout') { should match 'Version: 4.0.0' }
  end
  describe command(pip_cmd + ' show nose') do
    its('stdout') { should match 'Version: 1.3.7' }
  end
  describe command(pip_cmd + ' show psutil') do
    its('stdout') { should match 'Version: 5.3.1' }
  end
  describe command(pip_cmd + ' show PyYaml') do
    its('stdout') { should match 'Version: 3.12' }
  end
  describe command(pip_cmd + ' show requests') do
    its('stdout') { should match 'Version: 2.18.4' }
  end
  describe command(pip_cmd + ' show websocket-client') do
    its('stdout') { should match 'Version: 0.37.0' }
  end

  if os[:family] != 'windows'
    describe command(pip_cmd + ' show circus') do
      its('stdout') { should match 'Version: 0.14.0' }
    end
  end

  # agent is installed
  if os[:family] != 'windows'
    describe package('outlyer-agent') do
      it { should be_installed }
    end
    describe file('/opt/outlyer/agent/agent.py') do
      it { should exist }
    end
  end

  if os[:family] == 'windows'
    describe file('c:/outlyer/agent/agent.py') do
      it { should exist }
    end
  end

end

control "agent-service-non-windows" do
  only_if { os[:family] != 'windows' }
  impact 1.0
  title "Agent service is installed and running"

  # agent service is installed, up and running
  describe systemd_service('outlyer-agent') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control "agent-service-windows" do
  only_if { os[:family] == 'windows' }
  impact 1.0
  title "Agent service is installed and running"

  describe powershell(windows_service_ps_cmd) do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(windows_service_regex[:auto]) }
    its('stdout') { should match(windows_service_regex[:running]) }
  end
end

control "agent-socket-connection" do
  impact 1.0
  title "Agent can connect"

  # agent can connect to the server
  describe file(log_file) do
   its('content') { should match 'INFO outlyer_agent.transport - socket connection established' }
  end

end


control "public-api" do
  impact 1.0
  title "Public API is available and lists the agent"

  # check whether the public api is available
  describe http(API_URL + '/v2/user', headers: {Authorization: AUTH_TOKEN}, enable_remote_worker: false) do
    its('status') { should cmp 200 }
  end

  describe i = sys_info do
    hostname = i.hostname
  end

  # fetch public api to confirm whether we have data at /hosts
  describe 'public-api host' do
    it 'should be visible in 10 seconds', retry: 10, retry_wait: 1 do
      r = http(API_URL + '/v2/accounts/' + ACCOUNT + '/infra/hosts', headers: {Authorization: AUTH_TOKEN}, enable_remote_worker: false)
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if not r.body.include? hostname.downcase
        fail "expected body to include the hostname: " + hostname.downcase + ", got: \n" + r.body
        return 0
      end
      next
    end
  end

end


control "change-agent-config" do
  impact 1.0
  title "Change agent config"

  # make sure that the label is not there yet from a previous test
  describe http(API_URL + '/v2/accounts/' + ACCOUNT + '/infra/hosts', headers: {Authorization: AUTH_TOKEN}) do
    its('body') { should_not match 'test333' }
  end

  describe r = command(copy_node_json) do
    its('exit_status') { should eq 0 }
  end

  describe r = command(update_node_json) do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }
  end

  describe r = command(update_template) do
    its('exit_status') { should eq 0 }
    its('stderr') { should eq '' }
  end

  describe r = command(service_restart) do
    its('exit_status') { should eq 0 }
  end

  if os[:family] != 'windows'
    describe systemd_service('outlyer-agent') do
      it { should be_running }
    end
  end

  if os[:family] == 'windows'
    describe powershell(windows_service_ps_cmd) do
      its('exit_status') { should eq 0 }
      its('stdout') { should match(windows_service_regex[:running]) }
    end
  end

  # put a label on box X and the plugin being pushed down start/scheduled afterwards
  describe 'public-api new-label' do
    it 'should shows up in 10 seconds', retry: 10, retry_wait: 1 do
      r = http(API_URL + '/v2/accounts/' + ACCOUNT + '/infra/hosts', headers: {Authorization: AUTH_TOKEN})
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if r.body.include? 'test333'
        fail "expected body NOT to include old label, got: \n" + r.body
        return 0
      end
      if not r.body.include? test_id
        fail "expected body to include new label: " + test_id + ", got: \n" + r.body
        return 0
      end
      next
    end
  end

end

control "deregister-agent" do
  only_if { false }
  impact 1.0
  title "Deregister agent"

  describe r = command(service_stop) do
    its('exit_status') { should eq 0 }
  end

  if os[:family] != 'windows'
    describe systemd_service('outlyer-agent') do
      it { should_not be_running }
    end
  end

  if os[:family] == 'windows'
    describe powershell(windows_service_ps_cmd) do
      its('exit_status') { should eq 0 }
      its('stdout') { should match(windows_service_regex[:stopped]) }
    end
  end

  # deregister agent
  describe 'public-api host' do
    it 'should disappear in 10 seconds', retry: 0, retry_wait: 1 do
      r = http(API_URL + '/v2/accounts/' + ACCOUNT + '/infra/hosts', headers: {Authorization: AUTH_TOKEN})
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if r.body.include? hostname.downcase
        fail "expected body NOT to include the hostname: " + hostname.downcase + ", got: \n" + r.body
        return 0
      end
      next
    end
  end

  # start the service again for subsequent tests
  describe r = command(service_start) do
    its('exit_status') { should eq 0 }
  end

end

# base system data 5 mins
control "metrics" do
  impact 1.0
  title "Metrics"

  # TODO RAM, network, etc
  params = {
    q: 'name,sys.cpu.pct,:eq,role,' + test_id + ',:eq,:and,:avg',
    s: (Time.now.to_i - 3600)* 1000,
    e: Time.now.to_i * 1000,
    width: 100,
  }
  puts params

  describe 'public-api series' do
    it 'data should appear in 10 seconds', retry: 30, retry_wait: 3 do
      r = http(API_URL + '/v2/accounts/' + ACCOUNT + '/series', headers: {Authorization: AUTH_TOKEN}, params: params)
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if not r.body.include? '"metrics":["sys.cpu.pct"]'
        fail "expected body to have the right metrics just queried, got: \n" + r.body
        return 0
      end
      if not r.body.include? '"values":[['
        fail "expected body to have some values, got: \n" + r.body
        return 0
      end
      next
    end
  end

end

# TODO or maybe separately?: crud alerts/checks/dashboards/plugins etc

