require 'spec_helper'

describe "Task 1:" do
  it 'Insert include multi_node into your learning.puppetlabs.vm node declaration' do
    file("#{PROD_PATH}manifests/site.pp").should contain 'include multi_node'
  end
end

describe "Task 2:" do
  it "Run puppet to apply the multi_node class" do
    command('docker ps').stdout.should match /webserver/
  end
end

describe "Task 3:" do
  it "Prepare your puppet master to provide the ubuntu agent installer" do
    file("/opt/puppetlabs/server/data/packages/public/2015.3.1/ubuntu-14.04-amd64").should be_directory
  end
end

describe "Task 4:" do
  it "Install the Puppet agent on your database and webserver nodes" do
    command('docker exec webserver puppet').stdout.should match /subcommands/
    command('docker exec database puppet').stdout.should match /subcommands/
  end
end

describe "Task 5:" do
  it "Use the puppet resourse file to create a test file on your agent node" do
    command('docker exec database ls /tmp/test').exit_status.should eq 0
  end
end

describe "Task 6:" do
  it "Sign the certs for your new nodes" do
    file('/etc/puppetlabs/puppet/ssl/ca/signed/database.learning.puppetlabs.vm.pem').should be_file
    file('/etc/puppetlabs/puppet/ssl/ca/signed/webserver.learning.puppetlabs.vm.pem').should be_file
  end
end

describe "Task 7:" do
  it "Create a notify resource in your default node group" do
    file("#{PROD_PATH}manifests/site.pp").content.should match /notify\s+{\s+"This is \${::fqdn}, running the \${::operatingsystem} operating system":\s+}/
  end
end
