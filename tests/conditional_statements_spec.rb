require_relative './spec_helper'

describe "The conditional_statements quest" do
  it 'begins', :solution do
    command("quest begin conditional_statements")
      .exit_status
      .should eq 0
  end
end

describe "Task 1:", host: :localhost do
  it 'has a working solution', :solution do
    command("cp #{SOLUTION_PATH}/conditional_statements/1/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it 'Add the sinatra_server parameter to the pasture main manifest', :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /class\s+pasture\s+\(.*?\$sinatra_server\s+=\s+(['"])webrick\1,/m
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /\$pasture_config_hash\s+=\s+\{.*?(['"])sinatra_server\1\s+=>\s+\$sinatra_server,/m
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 2:", host: :localhost do
  it 'has a working solution', :solution do
    command("cp #{SOLUTION_PATH}/conditional_statements/2/pasture_config.yaml.epp #{MODULE_PATH}/pasture/templates/pasture_config.yaml.epp")
      .exit_status
      .should eq 0
  end
  it 'Add the sinatra_server parameter to the pasture config file template', :validation do
    file("#{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .content
      .should match /:sinatra_settings:.*?:server:\s+<%=\s+\$sinatra_server\s+%>/m
    command("puppet epp validate #{MODULE_PATH}pasture/templates/pasture_config.yaml.epp")
      .exit_status
      .should be_zero
  end
end


describe "Task 3:", host: :localhost do
  it 'has a working solution', :solution do
    command("cp #{SOLUTION_PATH}/conditional_statements/3/init.pp #{MODULE_PATH}/pasture/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it 'Conditionally manage the Sinatra server package', :validation do
    file("#{MODULE_PATH}pasture/manifests/init.pp")
      .content
      .should match /if\s+\$sinatra_server\s+==\s+(['"])thin\1\s+or\s+(['"])mongrel\1\s+\{.*?package\s+\{\s+\$sinatra_server:/m
    command("puppet parser validate #{MODULE_PATH}pasture/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe "Task 4:", host: :localhost do
  it 'has a working solution', :solution do
    command("cp #{SOLUTION_PATH}/conditional_statements/4/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it 'Classify nodes', :validation do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])pasture\-dev\.puppet\.vm\1\s+\{.*?include\s+pasture.*?\}/m
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])pasture\-prod\.puppet\.vm\1\s+\{.*?class\s+\{\s+(['"])pasture\1:.*?sinatra_server\s+=>\s(['"])thin\1,.*?\}.*?\}/m
  end
end

describe "Task 5:", host: :localhost do
  it 'has a working solution', :solution do
    command("curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H \"Content-Type: application/json\" -X POST -d '{\"login\":\"learning\",\"display_name\":\"Learning\",\"password\":\"puppet\",\"role_ids\":[2],\"email\":\"learning@puppet.vm\"}' https://localhost:4433/rbac-api/v1/users")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
    command("puppet job run --nodes pasture-dev.puppet.vm,pasture-prod.puppet.vm")
      .exit_status
      .should eq 0
  end
  it 'Generate token and use puppet job run command', :validation do
    file('/root/.puppetlabs/token')
      .should be_file
    command('docker exec pasture-dev.puppet.vm grep :server: /etc/pasture_config.yaml | grep -q webrick')
      .exit_status
      .should eq 0
    command('docker exec pasture-prod.puppet.vm grep :server: /etc/pasture_config.yaml | grep -q thin')
      .exit_status
      .should eq 0
    command('docker exec pasture-dev.puppet.vm journalctl -u pasture | grep -qi webrick')
      .exit_status
      .should eq 0
    command('docker exec pasture-prod.puppet.vm journalctl -u pasture | grep -qw Thin')
      .exit_status
      .should eq 0
  end
end
