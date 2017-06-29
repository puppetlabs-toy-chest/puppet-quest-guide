require_relative './spec_helper'

describe "The hello_puppet quest", :solution do
  it 'begins' do
    command("quest begin hello_puppet")
      .exit_status
      .should eq 0
  end
end

describe "Task 1:", host: :hello do
  it 'has a working solution', :solution do
    command("curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash")
      .exit_status
      .should eq 0
  end
  it 'Install the Puppet agent', :validation do
    file('/opt/puppetlabs/puppet/bin/puppet')
      .should be_file
  end
end

describe "Task 2:", host: :hello do
  it 'has a working solution', :solution do
    command("sudo puppet resource file /tmp/test")
      .exit_status
      .should eq 0
  end
  it 'Investigate the /tmp/test file resource' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource file \/tmp\/test/
  end
end

describe "Task 3:", host: :hello do
  it 'has a working solution', :solution do
    command("touch /tmp/test")
      .exit_status
      .should eq 0
  end
  it 'Create the /tmp/test file resource', :validation do
    file('/tmp/test')
      .should be_file
  end
end

describe "Task 4:", host: :hello do
  it 'has a working solution', :solution do
    command("puppet resource file /tmp/test content='Hello Puppet!'")
      .exit_status
      .should eq 0
  end
  it 'Create the /tmp/test file resource', :validation do
    file('/tmp/test')
      .content
      .should match /Hello Puppet!/m
  end
end

describe "Task 5:", host: :hello do
  it 'has a working solution', :solution do
    command("sudo puppet resource package httpd ensure=present")
      .exit_status
      .should eq 0
  end
  it 'Investigate the package provider', :validation do
    package('httpd')
      .should be_installed
  end
end
