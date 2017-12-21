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
    command("cd && mkdir -p control-repo/{site,manifests}")
      .exit_status
      .should eq 0
  end
  it _('Create a control-repo directory tree'), :validation do
    file("/root/control-repo")
      .should be_directory
    file("/root/control-repo/site")
      .should be_directory
    file("/root/control-repo/manifests")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cp -r /etc/puppetlabs/code/environments/production/modeles/{pasture,motd,user_accounts,role,profile} ./control-repo/site/")
      .exit_status
      .should eq 0
    command("cp -r /etc/puppetlabs/code/environments/production/manifests/site.pp ./control-repo/manifests/")
      .exit_status
      .should eq 0
  end
  it _('Copy files from your code directory to the control-repo'), :validation do
    file("/root/control-repo/site/pasture")
      .should be_directory
    file("/root/control-repo/site/motd")
      .should be_directory
    file("/root/control-repo/site/user_accounts")
      .should be_directory
    file("/root/control-repo/site/role")
      .should be_directory
    file("/root/control-repo/site/profile")
      .should be_directory
    file("/root/control-repo/manifests/site.pp")
      .should be_file
    file("/root/control-repo/environment.conf")
      .content
      .should match /site:modules:\$basemodulepath/
  end
end

describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cd /root/control-repo && git init && git add * && git status && git commit -m 'Initial commit of existing modules' && git branch -m master production")
    .exit_status
    .should eq 0
  end
  it _('Initialize the control-repo repository make an initial commit'), :validation do
    command("cd /root/control-repo && git branch")
      .stdout
      .should match /production/
    command("cd /root/control-repo && git log")
      .stdout
      .should match /commit/
  end
end

describe _("Task 4:"), host: :localhost do
  it 'has a working solution', :solution do
    make_gitea_user('test_user', 'puppet')
    make_gitea_repo('test_user', 'puppet', 'control-repo')
    command("git remote add upstream http://localhost:3000/test_user/control-repo.git")
      .exit_status
      .should eq 0
    command("cd /root/control-repo && git push upstream production")
      .exit_status
      .should eq 0
  end
  it _('Set up an upstream remote in Gitea'), :validation do
    command("cd /root/control-repo && git remote -v")
      .stdout
      .should match /upstream\s+http:\/\/localhost:3000\/.*\/control-repo\.git\s\(fetch\)/
  end
end

describe _("Task 5:"), host: :localhost do
  it 'has a working solution', :solution do
    command("mkdir /etc/puppetlabs/puppetserver/ssh")
      .exit_status
      .should eq 0
    command('ssh-keygen -t rsa -b 4096 -C "learning@puppet.vm" -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa -P ""')
      .exit_status
      .should eq 0

  end
  it _('Create a deploy key'), :validation do
    file("/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa")
      .should be_owned_by 'pe-puppet'
  end
end
