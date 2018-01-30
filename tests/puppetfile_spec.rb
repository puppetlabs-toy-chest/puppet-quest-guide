require_relative './spec_helper'

MASTER_GID = get_master_group_id
LEARNING_UID = get_learning_user_id

describe _("Task 1:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git checkout production && git pull upstream production && git checkout -b puppetfile')
      .exit_status
      .should eq 0
  end
  it _('Check out a new puppetfile branch'), :validation do
    file("cd root/control-repo && git status")
      .content
      .should match /puppetfile/
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command("cp -n #{SOLUTION_PATH}/puppetfile/2/Puppetfile /root/control-repo/Puppetfile")
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
    command('cd /root/control-repo && git push upstream update_cowsay_message')
      .exit_status
      .should eq 0
  end
  it _('Push your branch to the upstream remote'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches")
      .stdout
      .should match /beauvine_message_default/
  end
end

describe _("Task 23:"), host: :localhost do
  it 'has a working solution', :solution do
    command('cd /root/control-repo && git checkout production && git merge update_cowsay_message && git push -f upstream production')
      .exit_status
      .should eq 0
  end
  it _('Merge your change to the upstream production branch'), :validation do
    command("curl -i http://learning:puppet@localhost:3000/api/v1/repos/learning/control-repo/branches/production")
      .stdout
      .should match /default_message/
  end
end

describe _("Task 24:"), host: :localhost do
  it 'has a working solution', :solution do
    command('puppet code deploy production --wait')
      .exit_status
      .should_not eq 1
  end
  it _('Deploy your modified production code'), :validation do
    file("/etc/puppetlabs/code/environments/production/data/domain/beauvine.vm.yaml")
      .should be_directory
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
