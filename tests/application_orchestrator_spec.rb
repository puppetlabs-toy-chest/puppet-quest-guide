describe 'Task 1:', host: :localhost do
  it 'Create application module directories' do
    file("#{MODULE_PATH}pasture_app/manifests")
      .should be_directory
    file("#{MODULE_PATH}pasture_app/lib/puppet/type")
      .should be_directory
  end
end

describe 'Task 2:', host: :localhost do
  it 'Create sql resource type file' do
    file("#{MODULE_PATH}pasture_app/lib/puppet/type/sql.rb")
      .should be_file
    command("ruby -c #{MODULE_PATH}pasture_app/lib/puppet/type/sql.rb >/dev/null 2>&1")
      .exit_status
      .should eq 0
    file("#{MODULE_PATH}pasture_app/lib/puppet/type/sql.rb")
      .content
      .should match /Puppet::Type\.newtype\s+:sql,\s+:is_capability\s+=>\s+true\s+do\n(\s\snewparam\s+:(\w)+(,\s+:is_namevar\s+=>\s+(true|false))?\n)+^end$/m
  end
end

describe 'Task 3:', host: :localhost do
  it 'Create the pasture_app::db component' do
    file("#{MODULE_PATH}pasture_app/manifests/db.pp")
      .should be_file
    command("puppet parser validate --app_management #{MODULE_PATH}pasture_app/manifests/db.pp")
      .exit_status
      .should be_zero
    file("#{MODULE_PATH}pasture_app/manifests/db.pp")
      .content
      .should match /define\s+pasture_app::db\s+\(.*?\$user,.*?\$password,.*?\$host\s+=\s+\$::fqdn,.*?/m
    file("#{MODULE_PATH}pasture_app/manifests/db.pp")
      .content
      .should match /Pasture_App::Db\s+produces\s+Sql\s+{.*?user\s+=>\s+\$user,/m
  end
end

describe 'Task 4:', host: :localhost do
  it 'Create the pasture_app::app component' do
    file("#{MODULE_PATH}pasture_app/manifests/app.pp")
      .should be_file
    command("puppet parser validate --app_management #{MODULE_PATH}pasture_app/manifests/app.pp")
      .exit_status
      .should be_zero
    file("#{MODULE_PATH}pasture_app/manifests/app.pp")
      .content
      .should match /define\s+pasture_app::app\s+\(.*?\$db_user,.*?\$db_password,.*?\$db_host,.*?/m
    file("#{MODULE_PATH}pasture_app/manifests/app.pp")
      .content
      .should match /Pasture_App::App\s+consumes\s+Sql\s+{.*?db_user\s+=>\s+\$user,/m
  end
end

describe 'Task 5:', host: :localhost do
  it 'Create the pasture_app application class' do
    file("#{MODULE_PATH}pasture_app/manifests/init.pp")
      .should be_file
    command("puppet parser validate --app_management #{MODULE_PATH}pasture_app/manifests/init.pp")
      .exit_status
      .should be_zero
    file("#{MODULE_PATH}pasture_app/manifests/init.pp")
      .content
      .should match /application\s+pasture_app\s+\(.*?\$db_user,.*?\$db_password,.*?/m
    file("#{MODULE_PATH}pasture_app/manifests/init.pp")
      .content
      .should match /pasture_app::db\s+{\s+\$name:.*?export\s+=>\s+Sql\[\$name\],/m
    file("#{MODULE_PATH}pasture_app/manifests/init.pp")
      .content
      .should match /pasture_app::app\s+{\s+\$name:.*?consume\s+=>\s+Sql\[\$name\],/m
  end
end

describe 'Task 6:', host: :localhost do
  it 'Remove application-related classes from role classes' do
    file("#{MODULE_PATH}role/manifests/pasture_app.pp")
      .content
      .should match /class\s+role::pasture_app\s+{.*?include\s+profile::base::motd.*?include\s+profile::pasture::dev_users.*?}/m
    file("#{MODULE_PATH}role/manifests/pasture_db.pp")
      .content
      .should match /class\s+role::pasture_db\s+{.*?include\s+profile::base::motd.*?include\s+profile::pasture::dev_users.*?}/m
  end
end

describe 'Task 7:', host: :localhost do
  it 'Add the application classification to site.pp' do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /site\s+{.*?pasture_app\s+{\s+(['"])pasture_01\1:.*?Node\[(['"])pasture-app-large\.puppet\.vm\1\]\s+=>\s+Pasture_app::App\[(['"])pasture_01\1\],/m
    command("puppet parser validate --app_management #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
    file('/root/.bash_history')
      .content
      .should match /puppet\s+job\s+plan\s+\-\-application\s+Pasture_app/
    command('env USER=root LOGNAME=root HOME=/root /opt/puppetlabs/bin/puppet-job --no-color plan --application Pasture_app')
      .stdout
      .should match /pasture\-db\.puppet\.vm.*?Pasture_app\[pasture_01\]\s+\-\s+Pasture_app::Db\[pasture_01\]/m
    command('env USER=root LOGNAME=root HOME=/root /opt/puppetlabs/bin/puppet-job --no-color plan --application Pasture_app')
      .stdout
      .should match /pasture\-app\-large\.puppet\.vm.*?Pasture_app\[pasture_01\]\s+\-\s+Pasture_app::App\[pasture_01\]/m
  end
end

describe 'Task 8:', host: :localhost do
  it 'Trigger agent runs with puppet job and test the application' do
    command('docker exec pasture-db.puppet.vm grep -q ernie@puppet.vm /home/ernie/.ssh/authorized_keys')
      .exit_status
      .should be_zero
    command('docker exec pasture-db.puppet.vm grep -q bert@puppet.vm /home/bert/.ssh/authorized_keys')
      .exit_status
      .should be_zero
    command("curl 'pasture-app-large.puppet.vm/api/v1/cowsay'")
      .stdout
      .should match /Hi!\s+I'm\s+connected\s+to\s+pasture\-db\.puppet\.vm!/
  end
end
