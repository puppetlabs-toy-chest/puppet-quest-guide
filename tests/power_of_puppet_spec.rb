describe _('Task 1:') do
  it _('Use the puppet module tool to search for graphite') do
    file('/root/.bash_history')
      .content
      .should match /puppet\s+module\s+search\s+graphite/
  end
end

describe _('Task 2:') do
  it _('Install the dwerder-graphite module') do 
    file("#{MODULE_PATH}graphite")
      .should be_directory
    file("#{MODULE_PATH}graphite/metadata.json")
      .content
      .should match /"name"\s*:\s*"dwerder-graphite"/
  end
end

describe _('Task 3:') do
  it _("Use facter to find the Learning VM's IP address") do
    file('/root/.bash_history')
      .content
      .should match /facter\s+ipaddress/
  end
end

describe _("Task 4:") do
  it _('Trigger a puppet agent run to install and configure Graphite') do 
    service('carbon-cache')
      .should be_running
  end
end
