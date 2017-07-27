require_relative './spec_helper'

describe "The variables_and_templates quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin variables_and_templates")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/variables_and_templates/1/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Add variables to the pasture main manifest'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /^class\s+pasture\s+{\s+\$port\s+=\s+(['"])80\1\s+\$default_character\s+=\s+(['"])sheep\2.*\s+\$default_message\s+=\s*(['"])\3\s+\$pasture_config_file\s+=\s+(['"])\/etc\/pasture_config\.yaml\4\s+package\s+{\s*(['"])pasture\5:\s+.*before\s+=>\s+File\[\$pasture_config_file\],/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+\$pasture_config_file:.*?notify\s+=>\s+Service\[(['"])pasture\1\],/m
  end
end
describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/pasture/templates")
      .exit_status
      .should eq 0
    command("cp #{SOLUTION_PATH}/variables_and_templates/2/pasture_config.yaml.epp #{MODULE_PATH}/pasture/templates/pasture_config.yaml.epp")
      .exit_status
      .should eq 0
  end
  it _('Create pasture configuration file template'), :validation do
    file("#{MODULE_PATH}pasture/templates")
      .should be_directory
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .should be_file
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .content
      .should match /:default_character:\s+<%=\s+\$default_character\s+%>/
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .content
      .should match /:default_message:\s+<%=\s+\$default_message\s+%>/
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .content
      .should match /:sinatra_settings:.*?:port:\s+<%=\s+\$port\s+%>/m
    command("puppet epp validate #{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/variables_and_templates/3/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Use pasture configuration file template'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$pasture_config_hash\s+=\s+{\s+(['"])port\1\s+=>\s+\$port,/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /content\s+=>\s+epp\((['"])pasture\/pasture_config\.yaml\.epp\1,\s+\$pasture_config_hash\),/
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/variables_and_templates/4/pasture.service.epp #{MODULE_PATH}/pasture/templates/pasture.service.epp")
      .exit_status
      .should eq 0
  end
  it _('Create pasture service unit file template'), :validation do
    file("#{MODULE_PATH}pasture/templates/pasture.service.epp")
      .should be_file
    file("#{MODULE_PATH}pasture/templates/pasture.service.epp")
      .content
      .should match /<%-\s+\|\s+\$pasture_config_file\s+=\s+(['"])\/etc\/pasture_config.yaml\1\s+\|\s+\-%>/
    file("#{MODULE_PATH}pasture/templates/pasture.service.epp")
      .content
      .should match /ExecStart=\/usr\/local\/bin\/pasture\s+start\s+\-\-config_file\s+<%=\s+\$pasture_config_file\s+%>/
    command("puppet epp validate #{MODULE_PATH}pasture/templates/pasture.service.epp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 5:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/variables_and_templates/5/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Use pasture service unit file template'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$pasture_service_hash\s+=\s+{.*?(['"])pasture_config_file\1\s+=>\s+\$pasture_config_file,/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /content\s+=>\s+epp\((['"])pasture\/pasture\.service\.epp\1,\s+\$pasture_service_hash\),/
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 6:"), host: :pasture do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Run the agent and test the changes'), :validation do
    file('/etc/systemd/system/pasture.service')
      .content
      .should match /ExecStart=\/usr\/local\/bin\/pasture\s+start\s+--config_file\s+\/etc\/pasture_config\.yaml/
  end
end
