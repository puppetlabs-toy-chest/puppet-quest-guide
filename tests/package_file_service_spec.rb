require_relative './spec_helper'

describe "The package_file_service quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin package_file_service")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}pasture/{manifests,files}")
      .exit_status
      .should eq 0
  end
  it _('Create the pasture module directories'), :validation do
    file("#{MODULE_PATH}pasture/manifests")
      .should be_directory
    file("#{MODULE_PATH}pasture/files")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/2/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the pasture main manifest'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .should be_file
    file("#{MODULE_PATH}/pasture/manifests/init.pp")
      .content
      .should match /^class\s+pasture\s+{.*?package\s+{\s+(['"])pasture\1:/m
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/3/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Update site.pp with classification for pasture.puppet.vm'), :validation do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?include\s+pasture.*?\}/mi
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 4:"), host: :pasture do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Run the Puppet agent'), :validation do
    package('pasture')
      .should be_installed
      .by('gem')
  end
end

describe _("Task 5:"), host: :pasture do
  # The solutions for this and the following two
  # tasks are skipped until there's a better way to
  # run the service via rspec
  xit _('has a working solution'), :solution do
    command("pasture start &")
      .exit_status
      .should eq 0
    command("ps -elf")
      .stdout
      .should match /pasture/
  end
  it _('Start the pasture service') do
    file('/home/learning/.bash_history')
      .content
      .should match /pasture start &/
  end
end

describe _("Task 6:"), host: :pasture do
  xit _('has a working solution'), :solution do
    command("curl 'localhost:4567/api/v1/cowsay?message=Hello!'")
      .stdout
      .should match /Hello!/
  end
  it _('Test the pasture service') do
    file('/home/learning/.bash_history')
      .content
      .should match /curl 'localhost:4567\/api\/v1\/cowsay\?message=Hello!'/
    file('/home/learning/.bash_history')
      .content
      .should match /curl 'localhost:4567\/api\/v1\/cowsay\?message=Hello!\&character=elephant'/
  end
end

describe _("Task 7:"), host: :pasture do
  xit _('has a working solution'), :solution do
    command("kill $(ps | grep pasture | cut -f1 -d' ')")
      .exit_status
      .should eq 0
  end
  it _('Stop the pasture service') do
    command('ps')
      .stdout
      .should_not match /pasture/
  end
end

describe _("Task 8:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/8/pasture_config.yaml #{MODULE_PATH}/pasture/files/pasture_config.yaml")
      .exit_status
      .should eq 0
  end
  it _('Create the pasture configuration file'), :validation do
    file("#{MODULE_PATH}/pasture/files/pasture_config.yaml")
      .should be_file
    file("#{MODULE_PATH}/pasture/files/pasture_config.yaml")
      .content
      .should match /^---.*?:default_character:\s+elephant/m
  end
end

describe _("Task 9:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/9/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Manage the pasture configuration file'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+(['"])\/etc\/pasture_config\.yaml\1:/
    command("puppet parser validate #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 10:", host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/10/pasture.service #{MODULE_PATH}/pasture/files/pasture.service")
      .exit_status
      .should eq 0
  end
  it _('Create the pasture service unit file'), :validation do
    file("#{MODULE_PATH}/pasture/files/pasture.service")
      .should be_file
    file("#{MODULE_PATH}/pasture/files/pasture.service")
      .content
      .should match /\[Unit\].*?Description=Run the pasture service/m
  end
end

describe "Task 11:", host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/11/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Manage the pasture configuration file and service'), :validation do
    file("#{MODULE_PATH}/pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+(['"])\/etc\/systemd\/system\/pasture.service\1:/
    file("#{MODULE_PATH}/pasture/manifests/init.pp")
      .content
      .should match /service\s+{\s+(['"])pasture\1:/
    command("puppet parser validate #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 12:", host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/package_file_service/12/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Add relationship metaparameters to the pasture main manifest'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /^class\s+pasture\s+{.*?package\s+{\s*(['"])pasture\1:.*?before\s+=>\s+File\[(['"])\/etc\/pasture_config\.yaml\1\],/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+(['"])\/etc\/pasture_config\.yaml\1:.*?notify\s+=>\s+Service\[(['"])pasture\1\],/m
  end
end

describe "Task 13:", host: :pasture do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Trigger a Puppet agent run'), :validation do
    file('/etc/pasture_config.yaml')
      .should be_file
    file('/etc/systemd/system/pasture.service')
      .should be_file
    process('pasture')
      .should be_running
    command('ruby -e "require \'yaml\';puts YAML.load_file(\'/etc/pasture_config.yaml\')" >/dev/null 2>&1')
      .exit_status
      .should be_zero
  end
end
