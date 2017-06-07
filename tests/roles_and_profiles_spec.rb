describe "Task 1:", host: :localhost do
  it 'Create the profile module directories' do
    file("#{MODULE_PATH}profile/manifests")
      .should be_directory
    file("#{MODULE_PATH}profile/manifests/pasture")
      .should be_directory
  end
end

describe "Task 2:", host: :localhost do
  it 'Create the profile::pasture::app class' do
    file("#{MODULE_PATH}profile/manifests/pasture/app.pp")
      .should be_file
    file("#{MODULE_PATH}profile/manifests/pasture/app.pp")
      .content
      .should match /class\s+{\s+(['"])pasture\1:.*?default_message\s+=>\s+(['"])Hello\s+Puppet!\1,/mi
    command("puppet parser validate #{MODULE_PATH}profile/manifests/pasture/app.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 3:", host: :localhost do
  it 'Create the profile::pasture::db class' do
    file("#{MODULE_PATH}profile/manifests/pasture/db.pp")
      .should be_file
    file("#{MODULE_PATH}profile/manifests/pasture/db.pp")
      .content
      .should match /class\s+profile::pasture::db\s+{.*?include\s+pasture::db.*?}/m
    command("puppet parser validate #{MODULE_PATH}profile/manifests/pasture/db.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 4:", host: :localhost do
  it 'Create the profile::base::motd class' do
    file("#{MODULE_PATH}profile/manifests/base")
      .should be_directory
    file("#{MODULE_PATH}profile/manifests/base/motd.pp")
      .should be_file
    file("#{MODULE_PATH}profile/manifests/base/motd.pp")
      .content
      .should match /class\s+profile::base::motd\s+{.*?include\s+motd.*?}/m
    command("puppet parser validate #{MODULE_PATH}profile/manifests/base/motd.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 5:", host: :localhost do
  it 'Create the role classes' do
    file("#{MODULE_PATH}role/manifests")
      .should be_directory
    file("#{MODULE_PATH}role/manifests/pasture_app.pp")
      .should be_file
    file("#{MODULE_PATH}role/manifests/pasture_app.pp")
      .content
      .should match /include\s+profile::pasture::app.*?include\s+profile::base::motd/m
    command("puppet parser validate #{MODULE_PATH}role/manifests/pasture_app.pp")
      .exit_status
      .should be_zero
    file("#{MODULE_PATH}role/manifests/pasture_db.pp")
      .should be_file
    file("#{MODULE_PATH}role/manifests/pasture_db.pp")
      .content
      .should match /include\s+profile::pasture::db.*?include\s+profile::base::motd/m
    command("puppet parser validate #{MODULE_PATH}role/manifests/pasture_db.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 6:", host: :localhost do
  it 'Classify nodes with role classes' do
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+\/\^pasture\-app\/\s+{.*?include\s+role::pasture_app.*?}/m
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+\/\^pasture\-db\/\s+{.*?include\s+role::pasture_db.*?}/m
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should_not match /node\s+(['"])pasture\-db\.puppet\.vm\1\s+{/
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should_not match /node\s+(['"])pasture\-app\.puppet\.vm\1\s+{/
  end
end

describe "Task 7:", host: :localhost do
  it 'Trigger the puppet agent on database and app servers' do
    command('docker exec pasture-db.puppet.vm grep -q "Welcome to pasture-db" /etc/motd')
      .exit_status
      .should eq 0
    command('docker exec pasture-db.puppet.vm systemctl status postgresql.service | grep -q "active (running)"')
      .exit_status
      .should eq 0
    command('docker exec pasture-app-small.puppet.vm grep -q "Welcome to pasture-app-small" /etc/motd')
      .exit_status
      .should eq 0
    command('docker exec pasture-app-small.puppet.vm grep -q sheep /etc/pasture_config.yaml')
      .exit_status
      .should eq 0
    command('docker exec pasture-app-small.puppet.vm systemctl status pasture.service | grep -q "active (running)"')
      .exit_status
      .should eq 0
    command('docker exec pasture-app-large.puppet.vm grep -q "Welcome to pasture-app-large" /etc/motd')
      .exit_status
      .should eq 0
    command('docker exec pasture-app-large.puppet.vm grep -q elephant /etc/pasture_config.yaml')
      .exit_status
      .should eq 0
    command('docker exec pasture-app-large.puppet.vm systemctl status pasture.service | grep -q "active (running)"')
      .exit_status
      .should eq 0
    command("curl 'pasture-app-small.puppet.vm/api/v1/cowsay/sayings'")
      .stdout
      .should match /^501:\s+/
    command("curl 'pasture-app-large.puppet.vm/api/v1/cowsay/sayings'")
      .stdout
      .should match /^\[.*?\]$/
  end
end
