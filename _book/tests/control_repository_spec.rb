require_relative './spec_helper'

MASTER_GID = get_master_group_id
LEARNING_UID = get_learning_user_id

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
    command("mkdir -p /root/control-repo/site")
      .exit_status
      .should eq 0
  end
  it _('Create a control-repo directory tree'), :validation do
    file("/root/control-repo")
      .should be_directory
    file("/root/control-repo/site")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -r /etc/puppetlabs/code/environments/production/modules/{cowsay,pasture,motd,user_accounts,role,profile} /root/control-repo/site/")
      .exit_status
      .should eq 0
  end
  it _('Copy site modules to your control repository'), :validation do
    file("/root/control-repo/site/cowsay")
      .should be_directory
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
  end
end

describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/control_repository/3/environment.conf /root/control-repo/environment.conf")
      .exit_status
      .should eq 0
  end
  it _('Copy and edit the environment.conf file'), :validation do
    file("/root/control-repo/environment.conf")
      .content
      .should match /site:modules:\$basemodulepath/
  end
end

describe _("Task 4:"), host: :localhost do
  it 'has a working solution', :solution do
    command("mkdir /root/control-repo/manifests")
      .exit_status
      .should eq 0
    command("yes | cp -f /etc/puppetlabs/code/environments/production/manifests/site.pp /root/control-repo/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Copy the site.pp manifest to the manifests directory'), :validation do
    file("/root/control-repo/manifests/site.pp")
      .should be_file
  end
end

describe _("Task 5:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp /etc/puppetlabs/code/environments/production/hiera.yaml /root/control-repo/hiera.yaml")
      .exit_status
      .should eq 0
    command("yes | cp -r /etc/puppetlabs/code/environments/production/data /root/control-repo/data")
      .exit_status
      .should eq 0
  end
  it _('Copy the Hiera configuration file and data directory'), :validation do
    file("/root/control-repo/hiera.yaml")
      .should be_file
    file("/root/control-repo/data")
      .should be_directory
    file("/root/control-repo/data/nodes")
      .should be_directory
    file("/root/control-repo/data/domain")
      .should be_directory
  end
end

describe _("Task 6:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cd /root/control-repo && git init")
    .exit_status
    .should eq 0
    command("cd /root/control-repo && git config credential.helper store")
    .exit_status
    .should eq 0
    command('echo "http://learning:puppet@localhost%3a3000" > /root/.git-credentials')
    .exit_status
    .should eq 0
    command("cd /root/control-repo && git add * && git status && git commit -m 'Initial commit of existing modules'")
    .exit_status
    .should eq 0
  end
  it _('Initialize the control-repo repository make an initial commit'), :validation do
    command("cd /root/control-repo && git log")
      .stdout
      .should match /commit/
  end
end

describe _("Task 7:"), host: :localhost do
  xit 'has a working solution', :solution do
    command("cd /root/control-repo && git branch -m master production")
    .exit_status
    .should eq 0
  end
  it _('Rename the master branch to production') do
    command("cd /root/control-repo && git branch")
      .stdout
      .should match /production/
  end
end

describe _("Task 8:"), host: :localhost do
  it 'has a working solution', :solution do
    make_gitea_user('learning', 'puppet')
    sleep 30 # We could poll gitea, but for the sake of getting this done, just sleep!
  end
  it _('Create a Gitea user account'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/users/learning")
      .stdout
      .should match /200\sOK/
  end
end

describe _("Task 9:"), host: :localhost do
  it 'has a working solution', :solution do
    make_gitea_repo('learning', 'puppet', 'control-repo')
    sleep 30 # We could poll gitea, but for the sake of getting this done, just sleep!
  end
  it _('Set up an upstream remote in Gitea'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo")
      .stdout
      .should match /200 OK/
  end
end

describe _("Task 10:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cd /root/control-repo && git remote add upstream http://localhost:3000/learning/control-repo.git")
      .exit_status
      .should eq 0
  end
  it _("Add the Gitea repository as upstream remote"), :validation do
    command("cd /root/control-repo && git remote -v")
      .stdout
      .should match /upstream\s+http:\/\/localhost:3000\/learning\/control-repo\.git/
  end
end

describe _("Task 11:"), host: :localhost do
  it 'has a working solution', :solution do
    command("echo http://learning:puppet@localhost%3a3000 > ~/.my-credentials")
      .exit_status
      .should eq 0
    command("cd /root/control-repo && git push upstream HEAD")
      .exit_status
      .should eq 0
  end
  it _("Push your production branch to the upstream remote"), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches")
      .stdout
      .should match /commit/
  end
end

describe _("Task 12:"), host: :localhost do
  xit 'has a working solution', :solution do
  end
  it _("Change the upstream repository's default branch to production") do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo")
      .stdout
      .should match /"default_branch":"production"/
  end
end

describe _("Task 13:"), host: :localhost do
  it 'has a working solution', :solution do
    command("mkdir /etc/puppetlabs/puppetserver/ssh")
      .exit_status
      .should eq 0
    command('ssh-keygen -t rsa -b 4096 -C "learning@puppet.vm" -f /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa -P ""')
      .exit_status
      .should eq 0
    command('chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppetserver/ssh')
      .exit_status
      .should eq 0
  end
  it _('Create a deploy key'), :validation do
    file("/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa")
      .should be_owned_by 'pe-puppet'
  end
end

describe _("Task 14:"), host: :localhost do
  it 'has a working solution', :solution do
    command('curl -i -H "Content-Type: application/json" -X POST -d "{\"Title\": \"Code Manager\",\"Key\": \"$(cut -d\" \" -f 2 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)\"}" http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/keys')
      .exit_status
      .should eq 0
  end
  it _('Add your deploy key to the upstream repository'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/keys")
      .stdout
      .should match /"key":"ssh-rsa/
  end
end

describe _("Task 15:"), host: :localhost do
  it 'has a working solution', :solution do
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H \"Content-Type: application/json\" -X POST -d '{\"classes\":{\"puppet_enterprise::profile::master\":{\"code_manager_auto_configure\":true,\"r10k_remote\":\"http://localhost:3000/learning/control-repo.git\",\"r10k_private_key\":\"/etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa\",\"file_sync_enabled\":true}}}' 'https://localhost:4433/classifier-api/v1/groups/#{MASTER_GID}'")
      .stdout
      .should match /200\sOK/
  end
  it _('Use the PE console node classifier to enable Code Manager'), :validation do
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem 'https://localhost:4433/classifier-api/v1/groups/#{MASTER_GID}'")
      .stdout
      .should match /"code_manager_auto_configure":true,"file_sync_enabled":true,"r10k_private_key":"\/etc\/puppetlabs\/puppetserver\/ssh\/id-control_repo\.rsa","r10k_remote":"http:\/\/localhost:3000\/learning\/control-repo\.git"/
  end
end

describe _("Task 16:"), host: :localhost do
  it 'has a working solution', :solution do
    command('puppet agent -t')
      .exit_status
      .should_not eq 1
  end
  it _('Run the Puppet agent on your master'), :validation do
    file("/etc/puppetlabs/puppetserver/conf.d/code-manager.conf")
      .content
      .should match /http:\/\/localhost:3000\/learning\/control-repo\.git/
  end
end

describe _("Task 17:"), host: :localhost do
  it 'has a working solution', :solution do
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H \"Content-Type: application/json\" -X PUT -d '{\"description\":\"Synchronizes code from version control system to Puppet Servers.\",\"user_ids\":[\"#{LEARNING_UID}\"],\"group_ids\":[],\"display_name\":\"Code Deployers\",\"id\":4,\"permissions\":[{\"object_type\":\"environment\",\"action\":\"deploy_code\",\"instance\":\"*\"}]}' 'https://localhost:4433/rbac-api/v1/roles/4'")
      .stdout
      .should match /200\sOK/
  end
  it _('Add the learning user to the Code Deployers role'), :validation do
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -X GET 'https://localhost:4433/rbac-api/v1/roles/4'")
      .stdout
      .should match /#{LEARNING_UID}/
  end
end

describe _("Task 18:"), host: :localhost do
  it 'has a working solution', :solution do
    # We can't deploy production without being able to change the default branch
    # in gitea, so to test, deploy master branch, copy it to produciton, and
    # manually reset the production environment cache via the API. 
    command('puppet code deploy master --wait && yes | cp -rf /etc/puppetlabs/code/environments/master /etc/puppetlabs/code/environments/production && chown -R pe-puppet /etc/puppetlabs/code/environments/production')
      .exit_status
      .should_not eq 1
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -X DELETE 'https://localhost:8140/puppet-admin-api/v1/environment-cache?environment=production'")
      .exit_status
      .should_not eq 1
  end
  it _('Deploy your production code'), :validation do
    file("/etc/puppetlabs/code/environments/production/site")
      .should be_directory
  end
end

describe _("Task 19:"), host: :localhost do
  it 'has a working solution', :solution do
    command('puppet job run --nodes pasture-app.beauvine.vm')
      .exit_status
      .should_not eq 1
  end
  it _('Trigger a puppet run on the pasture-app.beauvine.vm node'), :validation do
    command("curl 'pasture-app.beauvine.vm/api/v1/cowsay'")
      .stdout
      .should match /Beauvine/
  end
end

describe _("Task 20:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git checkout -b beauvine_default_message')
      .exit_status
      .should eq 0
    command("yes | cp -f #{SOLUTION_PATH}/control_repository/20/beauvine.vm.yaml /root/control-repo/data/domain/beauvine.vm.yaml")
      .exit_status
      .should eq 0
  end
  it _('Modify the beauvine.vm.yaml file'), :validation do
    file("/root/control-repo/data/domain/beauvine.vm.yaml")
      .content
      .should match /Hello\scontrol\srepository/
  end
end

describe _("Task 21:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git add data/domain/beauvine.vm.yaml')
      .exit_status
      .should eq 0
    command("cd /root/control-repo && git commit -m 'Change beauvine default_message in Hiera'")
      .exit_status
      .should eq 0
  end
  it _('Add and commit your change'), :validation do
    command("cd /root/control-repo && git log")
      .stdout
      .should match /Change\sbeauvine\sdefault/
  end
end

describe _("Task 22:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git push upstream beauvine_default_message')
      .exit_status
      .should eq 0
  end
  it _('Push your branch to the upstream remote'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches")
      .stdout
      .should match /beauvine_default_message/
  end
end

describe _("Task 23:"), host: :localhost do
  it 'has a working solution', :solution do
    # Again, pushing to master branch rather than produciton for solution
    command('cd /root/control-repo && git checkout master && git merge beauvine_default_message && git push -f upstream master')
      .exit_status
      .should eq 0
  end
  it _('Merge your change to the upstream production branch'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches")
      .stdout
      .should match /default_message/
  end
end

describe _("Task 24:"), host: :localhost do
  it 'has a working solution', :solution do
    command('puppet code deploy master --wait && yes | cp -rf /etc/puppetlabs/code/environments/master /etc/puppetlabs/code/environments/production && chown -R pe-puppet /etc/puppetlabs/code/environments/production')
      .exit_status
      .should_not eq 1
  end
  it _('Deploy your modified production code'), :validation do
    file("/etc/puppetlabs/code/environments/production/data/domain/beauvine.vm.yaml")
      .content
      .should match /repository/
  end
end

describe _("Task 25:"), host: :localhost do
  it 'has a working solution', :solution do
    command('puppet job run --nodes pasture-app.beauvine.vm')
      .exit_status
      .should_not eq 1
  end
  it _('Trigger a second puppet run on the pasture-app.beauvine.vm node'), :validation do
    command("curl 'pasture-app.beauvine.vm/api/v1/cowsay'")
      .stdout
      .should match /repository/
  end
end
