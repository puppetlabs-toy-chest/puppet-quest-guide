require_relative './spec_helper'

describe "The control_repository quest", host: :localhost do
  it 'begins', :solution do
    command("quest begin control_repository")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cd && mkdir -p control_repo/{site,manifests}")
      .exit_status
      .should eq 0
  end
  it _('Create the control_repo directory'), :validation do
    file("/root/control_repo")
      .should be_directory
    file("/root/control_repo/site")
      .should be_directory
    file("/root/control_repo/manifests")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cp -r /etc/puppetlabs/code/environments/production/modules/{pasture,motd,user_accounts,role,profile} ./control_repo/site/")
      .exit_status
      .should eq 0
    command("cp -r /etc/puppetlabs/code/environments/production/manifests/site.pp ./control_repo/manifests/")
      .exit_status
      .should eq 0
  end
  it _('Copy your modules and site.pp to the control repository'), :validation do
    file("/root/control_repo/site/pasture")
      .should be_directory
    file("/root/control_repo/site/motd")
      .should be_directory
    file("/root/control_repo/site/user_accounts")
      .should be_directory
    file("/root/control_repo/site/role")
      .should be_directory
    file("/root/control_repo/site/profile")
      .should be_directory
    file("/root/control_repo/manifests/site.pp")
      .should be_file
  end
end

describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cd /root/control_repo && git init")
      .exit_status
      .should eq 0
    command("cd /root/control_repo && git add *")
      .exit_status
      .should eq 0
    command("cd /root/control_repo && git commit -m 'Initial commit of existing modules'")
      .exit_status
      .should eq 0
    command("cd /root/control_repo && git branch -m master production")
      .exit_status
      .should eq 0
  end
  it _('Create the data directory tree'), :validation do
    command("cd /root/control_repo && git status")
      .stdout
      .should match /#\sOn\sbranch production\s*
      nothing\sto\scommit,\sworking\sdirectory\sclean/mx
  end
end
