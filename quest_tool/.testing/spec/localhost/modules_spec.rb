require 'spec_helper'

# Task 1
describe "Find the modulepath" do 
  it 'using puppet agent --configprint' do
    file('/root/.bash_history').should contain "puppet agent --configprint modulepath"
  end
end

# Task 2
describe "The directory for the new vimrc module" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc').should be_directory
  end
end

# Task 3
describe "The directories for manifests, tests, and files" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/manifests').should be_directory
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/tests').should be_directory
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/files').should be_directory
  end
end

# Task 4
describe "The vimrc file" do
  it 'should be copied into the module files directory' do
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/files/vimrc').should be_file
  end
end

# Task 5
describe "The vimrc/files/vimrc file" do
  it "should contain the 'set number' command" do
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/files/vimrc').should contain /set nu/
  end
end

# Task 6
describe 'The vimrc/manifests/init.pp manifest' do
  it 'should define the vimrc class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/manifests/init.pp').should contain 'class vimrc'
  end
end

# Task 7
describe 'The test manifest for the users class' do
  it 'should include the vimrc class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/vimrc/tests/init.pp').should contain 'include vimrc'
  end
end

# Task 8
describe 'The /root/.vimrc configuration file' do
  it "should contain the 'set number' command" do
    file('/root/.vimrc').should contain /set nu/
  end
end
