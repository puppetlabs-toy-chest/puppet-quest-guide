describe _("Task 1:") do
  it _('Install the puppetlabs-ntp module') do
    file("#{MODULE_PATH}ntp")
      .should be_directory
    file("#{MODULE_PATH}ntp/metadata.json")
      .should contain 'puppetlabs-ntp'
  end
end

describe _("Task 2:") do
  it _("Include the ntp class in your 'learning.puppetlabs.vm' node definition") do
    file("#{PROD_PATH}manifests/site.pp")
      .should contain 'ntp'
  end
end

describe _("Task 3:") do
  it _('Trigger a puppet run to install and configure NTP') do
    service('ntpd')
      .should be_running
  end
end

describe _("Task 4:") do
  it _("Set the servers parameter to specify non-default servers") do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /\s*servers\s*=>\s*\[/
  end
end

describe _('Task 5:') do
  it _('Trigger a puppet run to apply your server configuration changes') do
    file('/etc/ntp.conf')
      .content
      .should_not match /(\s*server\s+\d+.centos.pool.ntp.org\s*){3}/
    file('/etc/ntp.conf')
      .content
      .should match /(\s+.*\.\w{2,}$){3}/
  end
end
