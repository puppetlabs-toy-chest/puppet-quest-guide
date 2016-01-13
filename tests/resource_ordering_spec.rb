require 'spec_helper'


describe "Task 1:" do
  it 'Create the sshd module directory with manifests, examples, and files subdirectories' do
    file("#{MODULE_PATH}sshd").should be_directory
    file("#{MODULE_PATH}sshd/manifests").should be_directory
    file("#{MODULE_PATH}sshd/examples").should be_directory
    file("#{MODULE_PATH}sshd/files").should be_directory
  end
end

describe "Task 2:" do
  it 'Define the sshd class' do
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /class sshd \{/
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /package { 'openssh-server':/
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /service { 'sshd':/
  end
end

describe "Task 3:" do
  it "Create a test manifest, and apply it with `--noop` and `--graph` flags" do
    file("#{MODULE_PATH}sshd/examples/init.pp").should contain "include sshd"
    file("/opt/puppetlabs/puppet/cache/state/graphs/relationships.dot").should contain "sshd"
  end
end

describe "Task 4:" do
  it "Use the `dot` tool to generate an image of your resource relationships graph" do
    file("/var/www/html/questguide/relationships.png").should be_file
  end
end

describe "Task 5:" do
  it "Copy the sshd_config file to the module's files direcotry" do
    file("#{MODULE_PATH}sshd/files/sshd_config").should be_file
  end
end

describe "Task 6:" do
  it "Disable GSSAPIAuthentication in the module's sshd_config file" do
    file("#{MODULE_PATH}sshd/files/sshd_config").content.should match /^GSSAPIAuthentication no/
    file("#{MODULE_PATH}sshd/files/sshd_config").content.should_not match /^GSSAPIAuthentication yes/
  end
end

describe "Task 7:" do
  it 'Add a `file` resource to manage the `sshd` configuration file' do
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /file\s+\{\s+'\/etc\/ssh\/sshd_config':/
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /source\s+=>\s+'puppet:\/\/\/modules\/sshd\/sshd_config',/
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /require\s+=>\s+Package\['openssh-server'\]/
  end
end

describe "Task 8:" do
  it "Apply your test manifest with the `--noop` and `--graph` flags" do
    file("/opt/puppetlabs/puppet/cache/state/graphs/relationships.dot").should contain "sshd_config"
  end
end


describe "Task 9:" do
  it 'Add a `subscribe` metaparameter to your `sshd` resource' do
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /subscribe\s+=>\s+File\['\/etc\/ssh\/sshd_config'\]/
  end
end
