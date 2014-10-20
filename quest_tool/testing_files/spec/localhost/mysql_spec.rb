require 'spec_helper'

# Task 1
describe "The Puppet Labs MySQL module" do
  it 'should be installed' do
    file('/etc/puppetlabs/puppet/modules/mysql').should be_directory
    file('/etc/puppetlabs/puppet/modules/mysql/metadata.json').should contain 'puppetlabs-mysql'
  end
end

# Task 2
describe "The site.pp manifest" do
  it 'should declare the mysql class' do
    file('/etc/puppetlabs/puppet/manifests/site.pp').should contain "class { '::mysql::server':"
    file('/etc/puppetlabs/puppet/manifests/site.pp').content.should match /\s*root_password\s+=>\s+/
    file('/etc/puppetlabs/puppet/manifests/site.pp').content.should match /\s*override_options\s+=>\s+/
  end
end

# Task 3
describe "A MySQL server" do
  it 'should be installed' do
    file('/usr/bin/mysql').should be_file
  end
end

# Task 4 
describe "The mysql::server::account_security class" do
  it "should be applied" do
    command("mysql -e 'show databases;'|grep test").exit_status.should_not be_zero
  end
end

# Task 5
describe "A database, user, and grant" do
  it "should be created" do
    command("mysql -e 'show databases;'|grep lvm").exit_status.should be_zero
    command("mysql -e 'SELECT User FROM mysql.user;'|grep lvm_user").exit_status.should be_zero
    command("mysql -e 'show grants for lvm_user@localhost;'|grep lvm.*").exit_status.should be_zero
  end
end
