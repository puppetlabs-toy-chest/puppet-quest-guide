require_relative './spec_helper'

describe "The quest", host: :localhost do
  it 'begins', :solution do
    command('quest begin hello_bolt')
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:") do
  it 'has a working solution', :solution do
    command('rpm -Uvh https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm')
      .exit_status
      .should eq 0
    command('yum install puppet-bolt')
      .exit_status
      .should eq 0
  end
  it _('Install bolt'), :validation do
    package('puppet6-release-el-7')
      .should be_installed
    package('puppet-bolt')
      .should be_installed
  end
end

describe _("Task 2:") do
  it 'has a working solution', :solution do
    command('quest list')
      .exit_status
      .should eq 0
  end
  it _('View the list of available quests') do
    file('/root/.bash_history')
      .content
      .should match /quest\s+list/
  end
end
