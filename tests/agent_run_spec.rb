require_relative './spec_helper'

describe "The agent_run quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin agent_run")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :agent do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should eq 1
  end
  it _('Run the pre-installed agent'), :validation do
    file('/etc/puppetlabs/puppet/ssl/private_keys/agent.puppet.vm.pem')
      .should be_file
  end
end

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("puppet cert sign agent.puppet.vm")
      .exit_status
      .should eq 0
  end
  it _('Sign the agent certificate'), :validation do
    file('/etc/puppetlabs/puppet/ssl/ca/signed/agent.puppet.vm.pem')
      .should be_file
  end
end

describe _("Task 3:"), host: :agent do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Check for successful agent run'), :validation do
    file('/var/opt/lib/pe-puppet/lib/shared/pe_server_version.rb')
      .should be_file
  end
end

describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/agent_run/4/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Check for site.pp classification'), :validation do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+(['"])?agent\.puppet\.vm\1\s+\{.*?notify\s+\{\s+'Hello\s+Puppet!':\s+\}.*?\}/mi
  end
end

describe _("Task 5:"), host: :agent do
  it _('Check for successful agent run with classification') do
    file('/var/opt/lib/pe-puppet/state/resources.txt')
      .should be_file
    file('/var/opt/lib/pe-puppet/state/resources.txt')
      .content
      .should match /notify\[Hello Puppet!\]/
  end
end
