require 'spec_helper'


# Task 1
describe "The sshd directory and manifests, tests, and files subdirectories" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/modules/sshd').should be_directory
    file('/etc/puppetlabs/puppet/modules/sshd/manifests').should be_directory
    file('/etc/puppetlabs/puppet/modules/sshd/tests').should be_directory
    file('/etc/puppetlabs/puppet/modules/sshd/files').should be_directory
  end
end

# Task 2
describe "The file sshd_config file" do
  it 'should be copied into the files directory' do
    file('/etc/puppetlabs/puppet/modules/sshd/files/sshd_config').should be_file
  end
end

# Task 3
describe "The manifests/init.pp manifest should define the sshd class" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/modules/sshd/manifests/init.pp').should contain "source => '/root/examples/sshd_config'"
  end
end

# Task 4
describe "GSSAPIAuthentication" do
  it 'should be disabled in the sshd config file' do
    file('/etc/ssh/sshd_config').should contain /^GSSAPIAuthentication no/
  end
end

# Task 5
describe "A test manifest for the sshd class" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/modules/sshd/manifests/init.pp').should contain "sshd"
  end
end

# Task 6
describe "The file /root/sshd.pp" do
  it 'should contain a package declaration' do
    file('/root/sshd.pp').should contain /package {/
  end
end
