require_relative './spec_helper'

describe "The defined_resource_types quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin defined_resource_types")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/user_accounts/manifests")
      .exit_status
      .should eq 0
  end
  it _('Create the directory structure for your accounts module'), :validation do
    file("#{MODULE_PATH}user_accounts")
      .should be_directory
    file("#{MODULE_PATH}user_accounts/manifests")
      .should be_directory
  end
end

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/defined_resource_types/2/ssh_user.pp #{MODULE_PATH}/user_accounts/manifests/ssh_user.pp")
      .exit_status
      .should eq 0
  end
  it _('Define the user_accounts::ssh_user defined resource type'), :validation do
    file("#{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .content
      .should match /define\s+user_accounts::ssh_user\s*\(\s+
                      \$key\s+=\s+undef,\s+
                      \$group\s+=\s+undef,\s+
                      \$shell\s+=\s+undef,\s+
                      \$comment\s+=\s+undef,\s+
                    \)\{/mx
    file("#{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .content
      .should match /file\s*{\s*\[?\s*"\/home\/\$\{title\}\".*?
                      ensure\s+=>\s+directory,\s+
                    /mx
    file("#{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .content
      .should match /file\s*{\s*\[?\s*"\/home\/\$\{title\}\/\.ssh\".*?
                      ensure\s+=>\s+directory,.*?
                      before\s+=>\s+Ssh_authorized_key\["\$\{title\}@puppet\.vm"\],\s+
                    /mx
    file("#{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .content
      .should match /if\s+\$key\s*\{\s+
                      ssh_authorized_key\s+\{\s*\"\$\{title\}@puppet\.vm\"
                    /mx
    command("puppet parser validate #{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("echo | ssh-keygen -t rsa -P puppet")
      .exit_status
      .should be_zero
  end
  it _('Create an ssh key'), :validation do
    file("/root/.ssh/id_rsa.pub")
      .should be_file
  end
end
describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("awk 'BEGIN{\"cut -f2 -d'\"'\"' '\"'\"' /root/.ssh/id_rsa.pub\" | getline l}/<PASTE KEY HERE>/{gsub(\"<PASTE KEY HERE>\",l)}1' #{SOLUTION_PATH}/defined_resource_types/4/dev_users.pp > #{MODULE_PATH}/profile/manifests/pasture/dev_users.pp")
      .exit_status
      .should eq 0
  end
  it _('Create a profile::pasture::dev_users profile class'), :validation do
    file("#{MODULE_PATH}profile/manifests/pasture/dev_users.pp")
      .content
      .should match /user_accounts::ssh_user\s*{\s*(['"])bert\1:\s+
                      comment\s+=>\s+(['"])Bert\1,\s+
                    /mx
    file("#{MODULE_PATH}profile/manifests/pasture/dev_users.pp")
      .content
      .should match /user_accounts::ssh_user\s*{\s*(['"])ernie\1:\s+
                      comment\s+=>\s+(['"])Ernie\1,\s+
                    /mx
    command("puppet parser validate #{MODULE_PATH}profile/manifests/pasture/dev_users.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 5:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/defined_resource_types/5/pasture_app.pp #{MODULE_PATH}/role/manifests/pasture_app.pp")
      .exit_status
      .should eq 0
    command("puppet job run --nodes pasture-app-small.puppet.vm")
      .exit_status
      .should be_zero
  end
  it _('Add profile::pasture::dev_users to the role::pasture_app class'), :validation do
    file("#{MODULE_PATH}role/manifests/pasture_app.pp")
      .content
      .should match /include\s+profile::pasture::dev_users/mi
    command("puppet parser validate #{MODULE_PATH}role/manifests/pasture_app.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 6:"), host: :pastureappsmall do
  it _('Trigger a Puppet run on pasture-app-small.puppet.vm to enforce your changes'), :validation do
    file('/home/bert')
      .should be_owned_by('bert')
    file('/home/bert')
      .should be_directory
    file('/home/bert')
      .should be_mode(755)
    file('/home/bert/.ssh')
      .should be_owned_by('bert')
    file('/home/bert/.ssh')
      .should be_directory
    file('/home/bert/.ssh')
      .should be_mode(700)
    file('/home/bert/.ssh/authorized_keys')
      .should be_owned_by('bert')
    file('/home/bert/.ssh/authorized_keys')
      .should be_file
    file('/home/bert/.ssh/authorized_keys')
      .should be_mode(600)
    file('/home/ernie')
      .should be_owned_by('ernie')
    file('/home/ernie')
      .should be_directory
    file('/home/ernie')
      .should be_mode(755)
    file('/home/ernie/.ssh')
      .should be_owned_by('ernie')
    file('/home/ernie/.ssh')
      .should be_directory
    file('/home/ernie/.ssh')
      .should be_mode(700)
    file('/home/ernie/.ssh/authorized_keys')
      .should be_owned_by('ernie')
    file('/home/ernie/.ssh/authorized_keys')
      .should be_file
    file('/home/ernie/.ssh/authorized_keys')
      .should be_mode(600)
  end
end
