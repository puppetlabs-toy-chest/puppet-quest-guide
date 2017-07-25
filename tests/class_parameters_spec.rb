require_relative './spec_helper'

describe "The class_parameters quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin class_parameters")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/class_parameters/1/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Add parameters to the pasture class'), :validation do
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

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/class_parameters/2/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Use resource-like syntax for classification'), :validation do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?class\s+\{\s+(['"])pasture\1:.*?default_character\s+=>\s+(['"])cow\1,.*?\}.*?\}/m
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 3:"), host: :pasture do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Run the agent and test the changes'), :validation do
    file('/etc/pasture_config.yaml')
      .content
      .should match /:default_character:\s+cow/
    command('ruby -e "require \'yaml\';puts YAML.load_file(\'/etc/pasture_config.yaml\')" >/dev/null 2>&1')
      .exit_status
      .should be_zero
  end
end
