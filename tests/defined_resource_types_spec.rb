require_relative './spec_helper'

describe "The defined_resource_types quest", host: :localhost do
  it 'begins', :solution do
    command("quest begin defined_resource_types")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it 'has a working solution', :solution do
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
  it 'has a working solution', :solution do
    command("cp #{SOLUTION_PATH}/defined_resource_types/2/ssh_user.pp #{MODULE_PATH}/user_accounts/manifests/ssh_user.pp")
      .exit_status
      .should eq 0
  end
  it _('Define the user_accounts::ssh_user defined resource type'), :validation do
    file("#{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .content
      .should match /define\s+user_accounts::ssh_user\s*\(\s+
                      \$key,\s+
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
      .should match /ssh_authorized_key\s+\{\s*\"\$\{title\}@puppet\.vm\"
                    /mx
    command("puppet parser validate #{MODULE_PATH}user_accounts/manifests/ssh_user.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
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
  it 'has a working solution', :solution do
  end
  it _('Add user data to your Hiera data sources'), :validation do
    file("#{PROD_PATH}/data/common.yaml")
      .content
      .should match /profile::base::dev_users::users: \[\]/
    file("#{PROD_PATH}/data/domain/beauvine.vm.yaml")
      .content
      .should match /profile::base::dev_users::users:\s+
        \-\stitle:\s'bessie'\s+
        comment:\s'Bessie\sJohnson'\s+
        pub_key:\s+'.*'\s+
        \-\stitle:\s'gertie'\s+
        comment:\s'Gertie\sPhilips'\s+
        pub_key:\s+'.*'/x
  end
end
describe _("Task 5:"), host: :localhost do
  it 'has a working solution', :solution do
  end
  it _('Create the profile::base::dev_users profile class'), :validation do
    file("#{MODULE_PATH}/profile/manifests/base/dev_users.pp")
      .content
      .should match /class\s+profile::base::dev_users\s+{\s+
        lookup\(profile::base::dev_users::users\).each\s\|\$user\|\s+
        \{\s+
        user_accounts::ssh_user\s+{\s+\$user\[(['"])title\1\]:\s+
        comment\s+=>\s+\$user\[(['"])comment\2\],\s+
        key\s+=>\s+\$user\[(['"])pub_key\3\],\s+
        \}\s+
        \}\s+
        \}/mx
  end
end
describe _("Task 6:"), host: :localhost do
  it 'has a working solution', :solution do
    wait_for_pxp_service
    command("cp #{SOLUTION_PATH}/defined_resource_types/5/pasture_app.pp #{MODULE_PATH}/role/manifests/pasture_app.pp")
      .exit_status
      .should eq 0
  end
  it _('Add profile::base::dev_users to the role::pasture_app class'), :validation do
    file("#{MODULE_PATH}role/manifests/pasture_app.pp")
      .content
      .should match /include\s+profile::base::dev_users/mi
    command("puppet parser validate #{MODULE_PATH}role/manifests/pasture_app.pp")
      .exit_status
      .should be_zero
  end
end
describe _("Task 7:"), host: :pastureappbeauvine do
  it 'has a working solution', :solution do
    command("puppet job run --nodes pasture-app.beauvine.vm")
      .exit_status
      .should be_zero
  end
  it _('Trigger a Puppet run on pasture-app.beauvine.vm to enforce your changes'), :validation do
    file('/home/gertie')
      .should be_owned_by('gertie')
    file('/home/gertie')
      .should be_directory
    file('/home/gertie')
      .should be_mode(755)
    file('/home/gertie/.ssh')
      .should be_owned_by('gertie')
    file('/home/gertie/.ssh')
      .should be_directory
    file('/home/gertie/.ssh')
      .should be_mode(700)
    file('/home/gertie/.ssh/authorized_keys')
      .should be_owned_by('gertie')
    file('/home/gertie/.ssh/authorized_keys')
      .should be_file
    file('/home/gertie/.ssh/authorized_keys')
      .should be_mode(600)
    file('/home/bessie')
      .should be_owned_by('bessie')
    file('/home/bessie')
      .should be_directory
    file('/home/bessie')
      .should be_mode(755)
    file('/home/bessie/.ssh')
      .should be_owned_by('bessie')
    file('/home/bessie/.ssh')
      .should be_directory
    file('/home/bessie/.ssh')
      .should be_mode(700)
    file('/home/bessie/.ssh/authorized_keys')
      .should be_owned_by('bessie')
    file('/home/bessie/.ssh/authorized_keys')
      .should be_file
    file('/home/bessie/.ssh/authorized_keys')
      .should be_mode(600)
  end
end
