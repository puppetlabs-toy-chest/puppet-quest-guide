require 'spec_helper'

# Task 1
describe "The Puppet Labs NTP module" do
  it 'should be installed' do
    file('/etc/puppetlabs/puppet/modules/ntp').should be_directory
    file('/etc/puppetlabs/puppet/modules/ntp/metadata.json').should contain 'puppetlabs-ntp'
  end
end

# Task 2
describe "The site.pp manifest" do
  it 'should include the ntp class in the default node definition' do
    file('/etc/puppetlabs/puppet/manifests/site.pp').should contain 'ntp'
  end
end

# Task 3
describe "The ntpd service" do
  it 'should be running' do
    service('ntpd').should be_running
  end
end

# Task 4 
describe "The site.pp manifest" do
  it "should declare the ntp class with the servers parameter set" do
    file('/etc/puppetlabs/puppet/manifests/site.pp').content.should match /\s*servers\s*=>\s*\[\'/
  end
end

# Task 5
describe 'The /etc/ntp.conf file' do
  it 'should contain non-default servers' do
    file('/etc/ntp.conf').content.should_not match /(\s*server \d.centos.pool.ntp.org\s*){3}/
    file('/etc/ntp.conf').content.should match /(\s+.*\.\w{3}$){3}/
  end
end
