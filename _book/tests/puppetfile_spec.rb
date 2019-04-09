require_relative './spec_helper'

MASTER_GID = get_master_group_id
LEARNING_UID = get_learning_user_id

describe "The puppetfile quest", host: :localhost do
  it 'begins', :solution do
    command("quest begin puppetfile")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git checkout master && git pull upstream master && git checkout -b puppetfile')
      .exit_status
      .should eq 0
  end
  it _('Check out a new puppetfile branch'), :validation do
    command("cd /root/control-repo && git status")
      .stdout
      .should match /puppetfile/
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/puppetfile/2/Puppetfile /root/control-repo/Puppetfile")
      .exit_status
      .should eq 0
  end
  it _('Create a Puppetfile in your control repository'), :validation do
    file("/root/control-repo/Puppetfile")
      .content
      .should match /mod\s"puppetlabs\/postgresql",\s'5\.12\.1'/
  end
end

describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/puppetfile/3/Puppetfile /root/control-repo/Puppetfile")
      .exit_status
      .should eq 0
  end
  it _('Add dependencies to your Puppetfile'), :validation do
    file("/root/control-repo/Puppetfile")
      .content
      .should match /mod\s"puppetlabs\/stdlib",\s'5\.2\.0'/
  end
end

describe _("Task 4:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git add Puppetfile')
      .exit_status
      .should eq 0
    command("cd /root/control-repo && git commit -m 'Add Puppetfile with puppetlabs-postgresql module' && git push upstream puppetfile")
      .exit_status
      .should eq 0
  end
  it _('Commit your code and push the branch upstream'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches")
      .stdout
      .should match /puppetfile/
  end
end

describe _("Task 5:"), host: :localhost do
  it 'has a working solution', :solution do
    # Again, pushing to master branch rather than production for solution
    command('cd /root/control-repo && git checkout master && git merge puppetfile && git push -f upstream master')
      .exit_status
      .should eq 0
  end
  it _('Merge your change to the upstream production branch'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches")
      .stdout
      .should match /postgresql/
  end
end

describe _("Task 6:"), host: :localhost do
  it 'has a working solution', :solution do
    # We can't deploy production without being able to change the default branch
    # in gitea, so to test, deploy master branch, copy it to production, and
    # manually reset the production environment cache via the API.
    command('puppet code deploy master --wait && yes | cp -rf /etc/puppetlabs/code/environments/master /etc/puppetlabs/code/environments/production && chown -R pe-puppet /etc/puppetlabs/code/environments/production')
      .exit_status
      .should_not eq 1
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -X DELETE 'https://localhost:8140/puppet-admin-api/v1/environment-cache?environment=production'")
      .exit_status
      .should_not eq 1
  end
  it _('Deploy your production code'), :validation do
    file("/etc/puppetlabs/code/environments/production/Puppetfile")
      .should be_file
  end
end

describe _("Task 7:"), host: :localhost do
  it 'has a working solution', :solution do
    command('puppet job run --nodes pasture-app.auroch.vm,pasture-db.auroch.vm')
      .exit_status
      .should_not eq 1
    command("curl -X POST 'pasture-app.auroch.vm/api/v1/cowsay/sayings?message=Hello!'")
      .exit_status
      .should eq 0
  end
  it _('Trigger a second puppet run on the pasture-app.auroch.vm node'), :validation do
    command("curl pasture-app.auroch.vm/api/v1/cowsay/sayings/1")
      .stdout
      .should match /Hello/
  end
end
