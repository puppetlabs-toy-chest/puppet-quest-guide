require_relative './spec_helper'

describe "The hello_bolt quest", host: :localhost do
  it 'begins', :solution do
    command('quest begin hello_bolt')
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it 'has a working solution', :solution do
    command('rpm -Uvh https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm')
      .exit_status
      .should eq 0
    command('yum install -y puppet-bolt')
      .exit_status
      .should eq 0
  end
  it _('Install bolt'), :validation do
    package('puppet6-release')
      .should be_installed
    package('puppet-bolt')
      .should be_installed
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command('bolt --help')
      .exit_status
      .should eq 0
    command('bolt --version')
      .exit_status
      .should eq 0
  end
  it _('Verify the bolt tool installation') do
    file('/root/.bash_history')
      .content
      .should match /bolt\s+(-h|--help)/
    file('/root/.bash_history')
      .content
      .should match /bolt\s+\-\-version/
  end
end

describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
    command('bolt command run "free -th" --nodes localhost')
      .exit_status
      .should eq 0
    command('bolt command run hostname --nodes docker://bolt.puppet.vm')
      .exit_status
      .should eq 0
    command('bolt command run "cat /etc/hosts" --nodes docker://bolt.puppet.vm')
      .exit_status
      .should eq 0
  end
  it _('Execute bolt commands') do
    file('/root/.bash_history')
      .content
      .should match /bolt\s+command\s+run\s+\'free\s+-th\'\s+\-\-nodes\s+localhost/
    file('/root/.bash_history')
      .content
      .should match /bolt\s+command\s+run\s+hostname\s+\-\-nodes\s+docker:\/\/bolt\.puppet\.vm/
    file('/root/.bash_history')
      .content
      .should match /bolt\s+\-\-format\s+json\s+command\s+run\s+\'cat\s+\/etc\/hosts\'\s+\-\-nodes\s+docker:\/\/bolt.puppet.vm/
    file('/root/.bash_history')
      .content
      .should match /bolt\s+command\s+run\s+\'cat\s+\/etc\/hosts\'\s+\-\-nodes\s+docker:\/\/bolt.puppet.vm/
  end
end
