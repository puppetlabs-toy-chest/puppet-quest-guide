describe "Task 1:", host: :localhost do
  it 'Install the PostgreSQL Puppet module' do
    file("#{MODULE_PATH}postgresql")
      .should be_directory
    file('/root/.bash_history')
      .content
      .should match /puppet module list/
  end
end

describe "Task 2:", host: :localhost do
  it 'Create the pasture::db wrapper class' do
    file("#{MODULE_PATH}pasture/manifests/db.pp")
      .should be_file
    file("#{MODULE_PATH}pasture/manifests/db.pp")
      .content
      .should match /class\s+pasture::db\s+\{.*?class\s+\{\s+(['"])postgresql::server\1:/m
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/db.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 3:", host: :localhost do
  it 'Classify the database node' do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])pasture\-db\.puppet\.vm\1\s+\{.*?include\s+pasture::db.*?\}/m
    command("puppet parser validate #{PROD_PATH}manifests/site.pp")
      .exit_status
      .should be_zero
    command('docker exec pasture-db.puppet.vm systemctl status postgresql.service | grep -q "active (running)"')
      .exit_status
      .should eq 0
  end
end

describe "Task 4:", host: :localhost do
  it 'Update the pasture main manifest with a db parameter' do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /class\s+pasture\s+\(.*?\$db\s+=\s+undef,/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$pasture_config_hash\s+=\s+\{.*?(['"])db\1\s+=>\s+\$db,/m
  end
end
