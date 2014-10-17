require 'spec_helper'

# Task 1
describe "The directory structure for your accounts module" do
  it 'should be created' do
    file('/etc/puppetlabs/puppet/modules/accounts').should be_directory
    file('/etc/puppetlabs/puppet/modules/accounts/tests').should be_directory
    file('/etc/puppetlabs/puppet/modules/accounts/manifests').should be_directory
  end
end

# Task 2
describe "The accounts/manifests/init.pp manifest" do
  it 'should define the accounts class' do
    file('/etc/puppetlabs/puppet/modules/accounts/manifests/init.pp').content.should match /class accounts \(\s*(\$name|\$uid),\s*(\$name|\$uid)\s*\)\s*\{\s+if\s+\$::operatingsystem\s==\s\'\w+\'\s+\{/
    file('/etc/puppetlabs/puppet/modules/accounts/manifests/init.pp').content.should match /user\s+\{\s+\$name:\s+ensure\s+=>\s+\'present\',(.|\s)+(\$groups,)\s+\}/
  end
end

# Task 3
describe "The accounts/tests/init.pp manifest" do
  it 'should declare the accounts class' do 
    file('/etc/puppetlabs/puppet/modules/accounts/tests/init.pp').content.should match /class\s+\{\s+\'?accounts\'?/
  end
end

# Task 4
describe "The accounts test manifest" do
  it 'should be applied with the FACTER_operatingsystem=Debian and the --noop flag' do 
    file('/root/.bash_history').content.should match /FACTER_operatingsystem=debian\spuppet\sapply\s--noop\s(\w*\/)*init.pp/i
  end
end

# Task 5
describe "The accounts test manifest" do
  it 'should be applied with FACTER_operatingsystem set to an unsupported value and the --noop flag' do 
    file('/root/.bash_history').content.should match /FACTER_operatingsystem=((?!(centos|debian)).)*\spuppet\sapply\s--noop\s(\w*\/)*init.pp/i
  end
end

# Task 6
describe 'The user dana' do
  it 'should be present and be in the wheel group' do
    shell("groups dana | grep wheel").exit_code.should be_zero
  end
end
