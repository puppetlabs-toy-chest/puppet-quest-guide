require 'spec_helper'


describe "Task 1:" do
  it 'Create the sshd module directory with manifests, tests, and files subdirectories' do
    file("#{MODULE_PATH}sshd").should be_directory
    file("#{MODULE_PATH}sshd/manifests").should be_directory
    file("#{MODULE_PATH}sshd/tests").should be_directory
    file("#{MODULE_PATH}sshd/files").should be_directory
  end
end

describe "Task 2:" do
  it "Copy the sshd_config file to the module's files direcotry" do
    file("#{MODULE_PATH}sshd/files/sshd_config").should be_file
  end
end

describe "Task 3:" do
  it 'Define the sshd class' do
    file("#{MODULE_PATH}sshd/manifests/init.pp").content.should match /source\s=>\s\'puppet:\/\/\/modules\/sshd\/sshd_config\',/
  end
end

describe "Task 4:" do
  it "Disable GSSAPIAuthentication in the module's sshd_config file" do
    file("#{MODULE_PATH}sshd/files/sshd_config").should contain "GSSAPIAuthentication no"
  end
end

describe "Task 5:" do
  it 'Include the sshd class in a test manifest' do
    file("#{MODULE_PATH}sshd/tests/init.pp").should contain "sshd"
  end
end

describe "Task 6:" do
  it 'Add an openssh-server package declaration to your sshd class' do
    file("#{MODULE_PATH}sshd/manifests/init.pp").should contain "package {"
  end
end
