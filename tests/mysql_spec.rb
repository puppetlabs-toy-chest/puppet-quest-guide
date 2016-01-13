require 'spec_helper'

describe "Task 1:" do
  it 'Install the puppetlabs-mysql module' do
    file("#{MODULE_PATH}mysql").should be_directory
    file("#{MODULE_PATH}mysql/metadata.json").should contain 'puppetlabs-mysql'
  end
end

describe "Task 2:" do
  it 'Define the mysql class' do
    file("#{PROD_PATH}manifests/site.pp").content.should match /class\s*{\s*'(::)?mysql::server':/
    file("#{PROD_PATH}manifests/site.pp").content.should match /\s*root_password\s+=>\s+/
    file("#{PROD_PATH}manifests/site.pp").content.should match /\s*override_options\s+=>\s+/
  end
end

describe "Task 3:" do
  it 'Trigger a puppet agent run to install MySQL' do
    file('/usr/bin/mysql').should be_file
  end
end

describe "Task 4:" do
  it "Apply the mysql::server::account_security class" do
    file('/usr/bin/mysql').should be_file
    command("mysql -e 'show databases;'|grep test").exit_status.should_not be_zero
  end
end

describe "Task 5:" do
  it "Create a new database, user, and grant" do
    command("mysql -e 'show databases;'|grep lvm").exit_status.should be_zero
    command("mysql -e 'SELECT User FROM mysql.user;'|grep lvm_user").exit_status.should be_zero
    command("mysql -e 'show grants for lvm_user@localhost;'|grep lvm.*").exit_status.should be_zero
  end
end
