require 'rspec/retry'

AUTH_TOKEN = attribute('auth_token', default: '', description: 'authentication token')

control "agent-installed" do
  impact 1.0
  title "Agent and it's requirements are installed"

  # pip packages are actually installed - based on requirements.txt in bourne
  describe pip('aiofiles', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '0.3.2' }
  end
  describe pip('apscheduler', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '3.4.0' }
  end
  describe pip('avro-python3', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '1.8.2' }
  end
  describe pip('docker', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '2.6.1' }
  end
  describe pip('kubernetes', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '4.0.0' }
  end
  describe pip('circus', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '0.14.0' }
  end
  describe pip('nose', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '1.3.7' }
  end
  describe pip('psutil', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '5.3.1' }
  end
  describe pip('PyYaml', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '3.12' }
  end
  describe pip('requests', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '2.18.4' }
  end
  describe pip('websocket-client', '/opt/outlyer/embedded/bin/pip3') do
    it { should be_installed }
    its('version') { should eq '0.37.0' }
  end

  # agent is installed
  describe package('outlyer-agent') do
    it { should be_installed }
  end

end

control "agent-socket-connection" do
  impact 1.0
  title "Agent service is installed and running"

  # agent service is installed, up and running
  describe systemd_service('outlyer-agent') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

end

control "agent-socket-connection" do
  impact 1.0
  title "Agent can connect"

  # agent can connect to the server
  describe file('/var/log/outlyer/agent.log') do
   its('content') { should match 'INFO outlyer_agent.transport - socket connection established' }
  end

end


control "public-api" do
  impact 1.0
  title "Public API is available and lists the agent"

  # check whether the public api is available
  describe http('https://alpha-api.outlyer.com/v2/user', headers: {Authorization: AUTH_TOKEN}) do
    its('status') { should cmp 200 }
  end

  # fetch public api to confirm whether we have data at /hosts
  describe 'public-api host' do
    it 'should be visible in 10 seconds', retry: 10, retry_wait: 1 do
      r = http('https://alpha-api.outlyer.com/v2/accounts/int-tests/infra/hosts', headers: {Authorization: AUTH_TOKEN})
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if not r.body.include? 'outlyer-agent-centos-72.vagrantup.com'
        fail "expected body to include the hostname, got: \n" + r.body
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
  describe http('https://alpha-api.outlyer.com/v2/accounts/int-tests/infra/hosts', headers: {Authorization: AUTH_TOKEN}) do
    its('body') { should_not match 'test31' }
  end

  describe r = command('sed -i "s/test31/test32/" /etc/outlyer/agent.yaml') do
    its('exit_status') { should eq 0 }
  end

  describe r = command('systemctl restart outlyer-agent') do
    its('exit_status') { should eq 0 }
  end

  describe r = command('systemctl restart outlyer-agent') do
    its('exit_status') { should eq 0 }
  end

  describe systemd_service('outlyer-agent') do
    it { should be_running }
  end

  # put a label on box X and the plugin being pushed down start/scheduled afterwards
  describe 'public-api new-label' do
    it 'should shows up in 10 seconds', retry: 10, retry_wait: 1 do
      r = http('https://alpha-api.outlyer.com/v2/accounts/int-tests/infra/hosts', headers: {Authorization: AUTH_TOKEN})
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if r.body.include? 'test31'
        fail "expected body NOT to include old label, got: \n" + r.body
        return 0
      end
      if not r.body.include? 'test32'
        fail "expected body to include new label, got: \n" + r.body
        return 0
      end
      next
    end
  end

end

control "deregister-agent" do
  impact 1.0
  title "Deregister agent"

  describe r = command('systemctl stop outlyer-agent') do
    its('exit_status') { should eq 0 }
  end

  describe systemd_service('outlyer-agent') do
    it { should_not be_running }
  end

  # deregister agent
  describe 'public-api host' do
    it 'should disappear in 10 seconds', retry: 10, retry_wait: 1 do
      r = http('https://alpha-api.outlyer.com/v2/accounts/int-tests/infra/hosts', headers: {Authorization: AUTH_TOKEN})
      if r.status != 200
        fail 'expected status code is 200'
        return 0
      end
      if r.body.include? 'outlyer-agent-centos-72.vagrantup.com'
        fail "expected body NOT to include the hostname, got: \n" + r.body
        return 0
      end
      next
    end
  end

end

# base system data 5 mins
control "metrics" do
  impact 1.0
  title "Metrics"

  # TODO RAM, network, etc
  params = {
    q: 'name%2Csys.cpu.pct%2C%3Aeq%2C%3Aavg',
    s: (Time.now.to_i - 300)* 1000,
    e: Time.now.to_i * 1000,
    width: 100,
  }
  puts params

  describe 'public-api series' do
    it 'data should appear in 10 seconds', retry: 10, retry_wait: 1 do
      r = http('https://alpha-api.outlyer.com/v2/accounts/int-tests/series', headers: {Authorization: AUTH_TOKEN}, params: params)
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

