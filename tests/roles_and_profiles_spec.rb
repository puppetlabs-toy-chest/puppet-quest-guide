require_relative './spec_helper'

describe "The roles_and_profiles quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin roles_and_profiles")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/profile/manifests/pasture")
      .exit_status
      .should eq 0
  end
  it _('Create the profile module directories'), :validation do
    file("#{MODULE_PATH}profile/manifests")
      .should be_directory
    file("#{MODULE_PATH}profile/manifests/pasture")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/roles_and_profiles/2/app.pp #{MODULE_PATH}/profile/manifests/pasture/app.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the profile::pasture::app class'), :validation do
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

describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/roles_and_profiles/3/db.pp #{MODULE_PATH}/profile/manifests/pasture/db.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the profile::pasture::db class'), :validation do
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

describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/profile/manifests/base")
      .exit_status
      .should eq 0
    command("cp #{SOLUTION_PATH}/roles_and_profiles/4/motd.pp #{MODULE_PATH}/profile/manifests/base/motd.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the profile::base::motd class'), :validation do
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

describe _("Task 5:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/role/manifests")
      .exit_status
      .should eq 0
    command("cp #{SOLUTION_PATH}/roles_and_profiles/5/pasture_app.pp #{MODULE_PATH}/role/manifests/pasture_app.pp")
      .exit_status
      .should eq 0
    command("cp #{SOLUTION_PATH}/roles_and_profiles/5/pasture_db.pp #{MODULE_PATH}/role/manifests/pasture_db.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the role classes'), :validation do
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

describe _("Task 6:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/roles_and_profiles/6/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Classify nodes with role classes'), :validation do
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

describe _("Task 7:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("puppet job run --nodes pasture-db.puppet.vm")
      .exit_status
      .should eq 0
    command("puppet job run --nodes pasture-app-small.puppet.vm,pasture-app-large.puppet.vm")
      .exit_status
      .should eq 0
  end
  it _('Trigger the puppet agent on database and app servers'), :validation do
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
