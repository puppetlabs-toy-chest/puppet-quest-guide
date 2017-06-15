describe _("Task 1:", host: :localhost) do
  it _('Create the pasture module directories') do
    file("#{MODULE_PATH}pasture/manifests")
      .should be_directory
    file("#{MODULE_PATH}pasture/files")
      .should be_directory
  end
end

describe _("Task 2:", host: :localhost) do
  it _('Create the pasture main manifest') do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .should be_file
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 3:", host: :localhost) do
  it _('Update site.pp with classification for pasture.puppet.vm') do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?include\s+pasture.*?\}/mi
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 4:", host: :pasture) do
  it _('Run the agent') do
    package('pasture')
      .should be_installed
      .by('gem')
  end
end

describe _("Task 5:", host: :pasture) do
  it _('Start the pasture service') do
    file('/home/learning/.bash_history')
      .content
      .should match /pasture start &/
  end
end

describe _("Task 6:", host: :pasture) do
  it _('Test the pasture service') do
    file('/home/learning/.bash_history')
      .content
      .should match /curl 'localhost:4567\/api\/v1\/cowsay\?message=Hello!'/
    file('/home/learning/.bash_history')
      .content
      .should match /curl 'localhost:4567\/api\/v1\/cowsay\?message=Hello!\&character=elephant'/
  end
end

describe _("Task 7:", host: :pasture) do
  it _('Stop the pasture service') do
    file('/home/learning/.bash_history')
      .content
      .should match /^fg$/
  end
end

describe _("Task 8:", host: :localhost) do
  it _('Create the pasture configuration file') do
    file("#{MODULE_PATH}pasture/files/pasture_config.yaml")
      .should be_file
    file("#{MODULE_PATH}pasture/files/pasture_config.yaml")
      .content
      .should match /^---.*?:default_character:\s+elephant/m
  end
end

describe _("Task 9:", host: :localhost) do
  it _('Manage the pasture configuration file') do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+(['"])\/etc\/pasture_config\.yaml\1:/
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 10:", host: :localhost) do
  it _('Create the pasture service unit file') do
    file("#{MODULE_PATH}pasture/files/pasture.service")
      .should be_file
    file("#{MODULE_PATH}pasture/files/pasture.service")
      .content
      .should match /\[Unit\].*?Description=Run the pasture service/m
  end
end

describe _("Task 11:", host: :localhost) do
  it _('Manage the pasture configuration file and service') do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+(['"])\/etc\/systemd\/system\/pasture.service\1:/
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /service\s+{\s+(['"])pasture\1:/
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 12:", host: :localhost) do
  it _('Add relationship metaparameters to the pasture main manifest') do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /^class\s+pasture\s+{.*?package\s+{\s+(['"])pasture\1:.*?before\s+=>\s+File\[(['"])\/etc\/pasture_config\.yaml\1\],/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+(['"])\/etc\/pasture_config\.yaml\1:.*?notify\s+=>\s+Service\[(['"])pasture\1\],/m
  end
end

describe _("Task 13:", host: :pasture) do
  it _('') do
    file('/etc/pasture_config.yaml')
      .should be_file
    file('/etc/systemd/system/pasture.service')
      .should be_file
    process('pasture')
      .should be_running
    file('/root/.bash_history')
      .content
      .match /curl 'pasture.puppet.vm:4567\/api\/v1\/cowsay\?message=Hello!'/
    command('ruby -e "require \'yaml\';puts YAML.load_file(\'/etc/pasture_config.yaml\')" >/dev/null 2>&1')
      .exit_status
      .should be_zero
  end
end
