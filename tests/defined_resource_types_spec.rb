describe "Task 1:", host: :localhost do
  it 'Create the directory structure for your accounts module' do
    file("#{MODULE_PATH}user_accounts")
      .should be_directory
    file("#{MODULE_PATH}user_accounts/manifests")
      .should be_directory
  end
end
describe "Task 2:", host: :localhost do
  it 'Define the user_accounts::ssh_user defined resource type' do
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
describe "Task 3:", host: :localhost do
  it 'Create an ssh key' do
    file("/root/.ssh/id_rsa.pub")
      .should be_file
  end
end
describe "Task 4:", host: :localhost do
  it 'Create a profile::pasture::dev_users profile class' do
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
describe "Task 5:", host: :localhost do
  it 'Add profile::pasture::dev_users to the role::pasture_app class' do
    file("#{MODULE_PATH}role/manifests/pasture_app.pp")
      .content
      .should match /include\s+profile::pasture::dev_users/mi
    command("puppet parser validate #{MODULE_PATH}role/manifests/pasture_app.pp")
      .exit_status
      .should be_zero
  end
end
describe "Task 6:", host: :pastureappsmall do
  it 'Trigger a Puppet run on pasture-app-small.puppet.vm to enforce your changes' do
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
