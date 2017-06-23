describe "Task 1:", host: :localhost do
  it 'Add parameters to the pasture class' do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /class\s+pasture\s+\(.*?\$port\s+=\s+(['"])80\1,/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$default_character\s+=\s+(['"])sheep\1,/
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$default_message\s+=\s+(['"])\1,/
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$pasture_config_file\s+=\s+(['"])\/etc\/pasture_config\.yaml\1,/
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 2:", host: :localhost do
  it 'Use resource-like syntax for classification' do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?class\s+\{\s+(['"])pasture\1:.*?default_character\s+=>\s+(['"])cow\1,.*?\}.*?\}/m
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 3:", host: :pasture do
  it 'Run the agent and test the changes' do
    file('/etc/pasture_config.yaml')
      .content
      .should match /:default_character:\s+cow/
    command('ruby -e "require \'yaml\';puts YAML.load_file(\'/etc/pasture_config.yaml\')" >/dev/null 2>&1')
      .exit_status
      .should be_zero
  end
end
