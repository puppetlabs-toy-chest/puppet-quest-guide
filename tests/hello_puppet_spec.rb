require_relative './spec_helper'

describe "The hello_puppet quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin hello_puppet")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :hello do
  it _('has a working solution'), :solution do
    command("curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash")
      .exit_status
      .should eq 0
  end
  it _('Install the Puppet agent'), :validation do
    file('/opt/puppetlabs/puppet/bin/puppet')
      .should be_file
  end
end

describe _("Task 2:"), host: :hello do
  it _('has a working solution'), :solution do
    command("sudo puppet resource file /tmp/test")
      .exit_status
      .should eq 0
  end
  it _('Investigate the /tmp/test file resource') do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource file \/tmp\/test/
  end
end

describe _("Task 3:"), host: :hello do
  it _('has a working solution'), :solution do
    command("touch /tmp/test")
      .exit_status
      .should eq 0
  end
  it _('Create the /tmp/test file resource'), :validation do
    file('/tmp/test')
      .should be_file
  end
end

describe _("Task 4:"), host: :hello do
  it _('has a working solution'), :solution do
    command("puppet resource file /tmp/test content='Hello Puppet!'")
      .exit_status
      .should eq 0
  end
  it _('Change the content of the /tmp/test file resource'), :validation do
    file('/tmp/test')
      .content
      .should match /Hello Puppet!/m
  end
end

describe _("Task 5:"), host: :hello do
  it _('has a working solution'), :solution do
    command("sudo puppet resource package httpd ensure=present")
      .exit_status
      .should eq 0
  end
  it _('Investigate the package provider'), :validation do
    package('httpd')
      .should be_installed
  end
end
