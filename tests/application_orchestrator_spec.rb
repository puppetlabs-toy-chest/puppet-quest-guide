describe 'Task 1:' do
  it 'Create application module directories' do
    file("#{MODULE_PATH}pasture_app/manifests")
      .should be_directory
    file("#{MODULE_PATH}pasture_app/lib/puppet/type")
      .should be_directory
  end
end

describe 'Task 2:' do
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

describe 'Task 3:' do
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

describe 'Task 4:' do
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

describe 'Task 5:' do
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

describe "Task 6:" do
  it "Create a sql type" do
    file("#{MODULE_PATH}lamp/lib/puppet/type/sql.rb")
      .content
      .should match /Puppet::Type\.newtype\s+:sql,\s+:is_capability\s+=>\s+true\s+do/
  end
end

describe "Task 7:" do
  it "Define a lamp::mysql component" do
    # Need a better test!
    file("#{MODULE_PATH}lamp/manifests/mysql.pp")
      .should be_file
  end
end

describe "Task 8:" do
  it "Define a lamp::webapp component" do
    # Need a better test!
    file("#{MODULE_PATH}lamp/manifests/webapp.pp")
      .should be_file
  end
end

describe "Task 9:" do
  it "Define the lamp application" do
    # Need a better test!
    file("#{MODULE_PATH}lamp/manifests/init.pp")
      .should be_file
  end
end

describe "Task 10:" do
  it "Declare an application instance in your site.pp manifest" do
    # Need a better test!
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /Node\[\s*['"]database\.learning\.puppetlabs\.vm['"],?\s*\]\s*=>\s*Lamp::Mysql\[\s*['"]app1['"],?\s*\],/
  end
end

describe "Task 11:" do
  it "Trigger a puppet job run to deploy your application" do
    command('docker exec webserver curl localhost/index.php')
      .stdout
      .should match /successfully/
  end
end
