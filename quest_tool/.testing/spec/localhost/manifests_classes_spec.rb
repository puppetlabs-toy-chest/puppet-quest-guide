require 'spec_helper'

# Task 1
describe "The cowsayings/manifests/cowsay.pp" do
  it 'should define the cowsayings::cowsay class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/cowsay.pp').should be_file
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/cowsay.pp').should contain /class cowsayings::cowsay {/
  end
end

# Task 2
describe "The cowsayings/tests/cowsay.pp" do
  it 'should include the cowsayings::cowsay class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/cowsay.pp').should be_file
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/cowsay.pp').should contain /include cowsayings::cowsay/
  end
end

# Task 3
describe "The cowsay package" do
  it 'should be installed' do
    file('/usr/bin/cowsay').should be_file
  end
end

# Task 4
describe "The cowsayings/manifests/fortune.pp" do
  it 'should define the cowsayings::fortune class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/fortune.pp').should be_file
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/fortune.pp').should contain /class cowsayings::fortune/
  end
end

# Task 5
describe "The cowsayings/tests/fortune.pp" do
  it 'should include the cowsayings::fortune class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/fortune.pp').should be_file
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/fortune.pp').should contain /include cowsayings::fortune/
  end
end

# Task 6
describe "The fortune package" do
  it 'should be installed' do
    file('/usr/bin/fortune').should be_file
  end
end

# Task 7
describe "The cowsayings/manifests/init.pp" do
  it 'should define the cowsayings class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/init.pp').should be_file
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/manifests/init.pp').should contain /class cowsayings {/
  end
end

# Task 8
describe "The cowsayings/tests/init.pp" do
  it 'should include the cowsayings class' do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/init.pp').should be_file
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings/tests/init.pp').should contain /include cowsayings/
  end
end

# Task 9
describe "The cowsayings/test/init.pp test manifest" do
  it "should be applied" do
    file('/etc/puppetlabs/puppet/environments/production/modules/cowsayings.tests.init.pp').should be_file
    file('/usr/bin/cowsay').should be_file
    file('/usr/bin/fortune').should be_file
  end
end
