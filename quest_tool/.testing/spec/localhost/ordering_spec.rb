require 'spec_helper'


# Task 1
describe "The sshd directory and manifests, tests, and files subdirectories" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd').should be_directory
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/manifests').should be_directory
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/tests').should be_directory
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/files').should be_directory
  end
end

# Task 2
describe "The file sshd_config file" do
  it 'should be copied into the files directory' do
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/files/sshd_config').should be_file
  end
end

# Task 3
describe "The manifests/init.pp manifest should" do
  it 'should define the sshd class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/manifests/init.pp').content.should match /source\s=>\s\'puppet:\/\/\/modules\/sshd\/sshd_config\',/
  end
end

# Task 4
describe "GSSAPIAuthentication" do
  it 'should be disabled in the sshd config file' do
    file('/etc/ssh/sshd_config').should contain "GSSAPIAuthentication no"
  end
end

# Task 5
describe "A test manifest for the sshd class" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp').should contain "sshd"
  end
end

# Task 6
describe "The sshd/manifests/init.pp manifest" do
  it 'should contain a package declaration' do
    file('/etc/puppetlabs/puppet/environments/production/modules/sshd/tests/init.pp').should contain "package {"
  end
end
