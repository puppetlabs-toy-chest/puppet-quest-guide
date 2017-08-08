require_relative './spec_helper'

describe "The the_forge quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin the_forge")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("puppet module install puppetlabs-postgresql --version 4.8.0")
      .exit_status
      .should eq 0
  end
  it _('Install the PostgreSQL Puppet module'), :validation do
    file("#{MODULE_PATH}postgresql")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/the_forge/2/db.pp #{MODULE_PATH}/pasture/manifests/db.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the pasture::db wrapper class'), :validation do
    file("#{MODULE_PATH}pasture/manifests/db.pp")
      .should be_file
    file("#{MODULE_PATH}pasture/manifests/db.pp")
      .content
      .should match /class\s+pasture::db\s+\{.*?class\s+\{\s+(['"])postgresql::server\1:/m
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/db.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/the_forge/3/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
    command("puppet job run --nodes pasture-db.puppet.vm")
      .exit_status
      .should eq 0
  end
  it _('Classify the database node and trigger an agent run'), :validation do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])pasture\-db\.puppet\.vm\1\s+\{.*?include\s+pasture::db.*?\}/m
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
    command('docker exec pasture-db.puppet.vm systemctl status postgresql.service | grep -q "active (running)"')
      .exit_status
      .should eq 0
  end
end

describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/the_forge/4/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Update the pasture main manifest with a db parameter'), :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /class\s+pasture\s+\(.*?\$db\s+=\s+undef,/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$pasture_config_hash\s+=\s+\{.*?(['"])db\1\s+=>\s+\$db,/m
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 5:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/the_forge/5/pasture_config.yaml.epp #{MODULE_PATH}/pasture/templates/pasture_config.yaml.epp")
      .exit_status
      .should eq 0
    command("cp #{SOLUTION_PATH}/the_forge/5/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Update the pasture configuration file template with a db parameter'), :validation do
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .content
      .should match /<%\-\s+\|\s+.*?\$db,.*?\|\s+\-%>/m
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .content
      .should match /<%\-?\s+if\s+\$db\s+{\s+\-%>.*?:db:\s+<%=\s+\$db\s+%>.*?<%\-?\s+}\s+\-%>/m
    command("puppet epp validate #{MODULE_PATH}pasture/template/pasture_config.yaml.epp")
      .exit_status
      .should be_zero
    file("#{PROD_PATH}/manifests/site.pp")
      .content
      .should match /node\s+(['"])pasture\-app\.puppet\.vm\1\s+{.*?class\s+{\s+(['"])pasture\1:.*?sinatra_server\s+=>\s+(['"])thin\1,.*?db\s+=>\s+(['"])postgres:\/\/pasture:m00m00@pasture\-db\.puppet\.vm\/pasture\1,/m
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 6:"), host: :pastureapp do
  it _("has a working solution"), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
    command("curl -X POST 'localhost/api/v1/cowsay/sayings?message=Hello!'")
      .exit_status
      .should eq 0
  end
  it _('Trigger an agent run on pasture-app.puppet.vm and test service'), :validation do
    package('thin')
      .should be_installed
      .by('gem')
    process('pasture')
      .should be_running
    port('80')
      .should be_listening
    file('/etc/pasture_config.yaml')
      .content
      .should match /^:db:\s+postgres:\/\/pasture:m00m00@pasture\-db\.puppet\.vm\/pasture$/
    command('ruby -e "require \'yaml\';puts YAML.load_file(\'/etc/pasture_config.yaml\')" >/dev/null 2>&1')
      .exit_status
      .should be_zero
    command("curl 'localhost/api/v1/cowsay/sayings'")
      .stdout
      .should match /"id":\d+,"message":"Hello!"/
  end
end
