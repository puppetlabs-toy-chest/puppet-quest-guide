describe _("Task 1:", host: :agent) do
  it _('Run the pre-installed agent') do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet agent -t/
  end
end

describe _("Task 2:", host: :localhost) do
  it _('Sign the agent certificate') do
    file('/etc/puppetlabs/puppet/ssl/ca/signed/agent.puppet.vm.pem')
      .should be_file
  end
end

describe _("Task 3:", host: :agent) do
  it _('Check for successful agent run') do
    file('/var/opt/lib/pe-puppet/lib/shared/pe_server_version.rb')
      .should be_file
  end
end

describe _("Task 4:", host: :localhost) do
  it _('Check for site.pp classification') do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+(['"])?agent\.puppet\.vm\1\s+\{.*?notify\s+\{\s+'Hello\s+Puppet!':\s+\}.*?\}/mi
  end
end

describe _("Task 5:", host: :agent) do
  it _('Check for successful agent run with classification') do
    file('/var/opt/lib/pe-puppet/state/resources.txt')
      .should be_file
    file('/var/opt/lib/pe-puppet/state/resources.txt')
      .content
      .should match /notify\[Hello Puppet!\]/
  end
end
