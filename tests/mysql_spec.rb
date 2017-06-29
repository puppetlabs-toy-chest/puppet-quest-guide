describe _("Task 1:") do
  it _('Install the puppetlabs-mysql module') do
    file("#{MODULE_PATH}mysql")
      .should be_directory
    file("#{MODULE_PATH}mysql/metadata.json")
      .should contain 'puppetlabs-mysql'
  end
end

describe _("Task 2:") do
  it _('Define the mysql class') do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /class\s*{\s*['"](::)?mysql::server['"]\s*:/
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /\s*root_password\s*=>\s*/
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /\s*override_options\s*=>\s*/
  end
end

describe _("Task 3:") do
  it _('Trigger a puppet agent run to install MySQL') do
    file('/usr/bin/mysql')
      .should be_file
  end
end

describe _("Task 4:") do
  it _("Apply the mysql::server::account_security class") do
    file('/usr/bin/mysql')
      .should be_file
    command("mysql -e 'show databases;' -u root -pstrongpassword | grep lvm")
      .stdout
      .should_not match /test/
  end
end

describe _("Task 5:") do
  it _("Create a new database, user, and grant") do
    command("mysql -e 'show databases;' -u root -pstrongpassword | grep lvm")
      .exit_status
      .should be_zero
    command("mysql -e 'SELECT User FROM mysql.user;' -u root -pstrongpassword | grep lvm_user")
      .exit_status
      .should be_zero
    command("mysql -e 'show grants for lvm_user@localhost;' -u root -pstrongpassword | grep lvm.*")
      .exit_status
      .should be_zero
  end
end
