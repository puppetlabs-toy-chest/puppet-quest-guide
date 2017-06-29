describe _("Task 1:") do
  it _('Create the sshd module directory with manifests, examples, and files subdirectories') do
    file("#{MODULE_PATH}sshd")
      .should be_directory
    file("#{MODULE_PATH}sshd/manifests")
      .should be_directory
    file("#{MODULE_PATH}sshd/examples")
      .should be_directory
    file("#{MODULE_PATH}sshd/files")
      .should be_directory
  end
end

describe _("Task 2:") do
  it _('Define the sshd class') do
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /class\s+sshd\s*\{/
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /package\s*{\s*['"]openssh-server['"]\s*:/
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /service\s*{\s*['"]sshd['"]\s*:/
  end
end

describe _("Task 3:") do
  it _("Create a test manifest, and apply it with `--noop` and `--graph` flags") do
    file("#{MODULE_PATH}sshd/examples/init.pp")
      .should contain "include sshd"
    file("/opt/puppetlabs/puppet/cache/state/graphs/relationships.dot")
      .should contain "sshd"
  end
end

describe _("Task 4:") do
  it _("Use the `dot` tool to generate an image of your resource relationships graph") do
    file("/var/www/quest/relationships.png")
      .should be_file
  end
end

describe _("Task 5:") do
  it _("Copy the sshd_config file to the module's files direcotry") do
    file("#{MODULE_PATH}sshd/files/sshd_config")
      .should be_file
  end
end

describe _("Task 6:") do
  it _("Disable GSSAPIAuthentication in the module's sshd_config file") do
    file("#{MODULE_PATH}sshd/files/sshd_config")
      .content
      .should match /^\s*GSSAPIAuthentication\s+no/
    file("#{MODULE_PATH}sshd/files/sshd_config")
      .content
      .should_not match /^GSSAPIAuthentication\s+yes/
  end
end

describe _("Task 7:") do
  it _('Add a `file` resource to manage the `sshd` configuration file') do
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /file\s*\{\s*['"]\/etc\/ssh\/sshd_config['"]\s*:/
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /source\s*=>\s*'puppet:\/\/\/modules\/sshd\/sshd_config',/
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /require\s*=>\s*Package\[\s*['"]openssh-server['"]\s*,?\s*\]/
  end
end

describe _("Task 8:") do
  it _("Apply your test manifest with the `--noop` and `--graph` flags") do
    file("/opt/puppetlabs/puppet/cache/state/graphs/relationships.dot")
      .should contain "sshd_config"
  end
end


describe _("Task 9:") do
  it _('Add a `subscribe` metaparameter to your `sshd` resource') do
    file("#{MODULE_PATH}sshd/manifests/init.pp")
      .content
      .should match /subscribe\s*=>\s*File\[\s*['"]\/etc\/ssh\/sshd_config['"]\s*,?\s*\]/
  end
end
