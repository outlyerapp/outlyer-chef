# might go away when https://github.com/chef/inspec/issues/2483 is implemented
AMAZONLINUX2 = os[:platform][:name] == 'amazon' && os[:platform][:release] == '2'
windows_service_ps_cmd = "Get-WmiObject -Class Win32_Service -Filter  \"name = 'outlyer-agent'\" |fl * -Force"
windows_service_regex = {
  disabled: /StartMode\s*:\sDisabled/,
  auto: /StartMode\s*:\sAuto/,
  stopped: /State\s*:\sStopped/,
  running: /State\s*:\sRunning/
}

control "agent-is-installed" do
  impact 1.0
  title "Agent and it's requirements are installed"

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

control "agent-service-gnu-linux" do
  only_if { os[:family] != 'windows' and not AMAZONLINUX2 }
  impact 1.0
  title "Agent service is installed and running"

  describe service('outlyer-agent') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end
end

control "agent-service-amazonlinux2" do
  only_if { AMAZONLINUX2 }
  impact 1.0
  title "Agent service is installed and running"

  describe bash("systemctl status outlyer-agent") do
    its('exit_status') { should eq 0 }
  end
  describe bash("systemctl status outlyer-agent | grep 'Active: active (running)'") do
    its('exit_status') { should eq 0 }
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

