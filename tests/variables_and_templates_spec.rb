describe "Task 1:", host: :localhost do
  it 'Add variables to the pasture main manifest' do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /^class\s+pasture\s+{\s+\$port\s+=\s+(['"])80\1\s+\$default_character\s+=\s+(['"])sheep\2.*\s+\$default_message\s+=\s*(['"])\3\s+\$pasture_config_file\s+=\s+(['"])\/etc\/pasture_config\.yaml\4\s+package\s+{(['"])pasture\5:\s+.*before\s+=>\s+File\[\$pasture_config_file\],/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /file\s+{\s+\$pasture_config_file:.*?notify\s+=>\s+Service\[(['"])pasture\1\],/m
  end
end
describe "Task 2:", host: :localhost do
  it 'Create pasture configuration file template' do
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
describe "Task 3:", host: :localhost do
  it 'Use pasture configuration file template' do
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
describe "Task 4:", host: :localhost do
  it 'Create pasture service unit file template' do
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
describe "Task 5:", host: :localhost do
  it 'Use pasture service unit file template' do
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
describe "Task 6:", host: :pasture do
  it 'Run the agent and test the changes' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet agent -t/
    file('/etc/systemd/system/pasture.service')
      .content
      .should match /ExecStart=\/usr\/local\/bin\/pasture\s+start\s+--config_file\s+\/etc\/pasture_config\.yaml/
  end
end
