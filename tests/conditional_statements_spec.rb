require 'spec_helper'

describe "Task 1:" do
  it 'Create the directory structure for your accounts module' do
    file("#{MODULE_PATH}accounts").should be_directory
    file("#{MODULE_PATH}accounts/examples").should be_directory
    file("#{MODULE_PATH}accounts/manifests").should be_directory
  end
end

describe "Task 2:" do
  it 'Define the accounts class' do
    file("#{MODULE_PATH}accounts/manifests/init.pp").content.should match /class accounts \(\s*\$user_name\s*\)\s*\{\s+if\s+\$::operatingsystem\s==\s\'\w+\'\s+\{/
    file("#{MODULE_PATH}accounts/manifests/init.pp").content.should match /user\s+\{\s*\$user_name:\s+ensure\s+=>\s+\'?present\'?,(.|\s)+(\$groups,)\s+\}/
  end
end

describe "Task 3:" do
  it 'Declare the accounts class in a test manifest' do 
    file("#{MODULE_PATH}accounts/examples/init.pp").content.should match /class\s+\{\s*\'?accounts\'?/
  end
end

describe "Task 4:" do
  it 'Run a noop with operatingsystem set to debian' do 
    file('/root/.bash_history').content.should match /FACTER_operatingsystem=debian\spuppet\sapply\s--noop\s(\w*\/)*init.pp/i
  end
end

describe "Task 5:" do
  it 'Run a noop with operatingsystem set to an unsupported value' do 
    file('/root/.bash_history').content.should match /FACTER_operatingsystem=((?!(centos|debian)).)*\spuppet\sapply\s--noop\s(\w*\/)*init.pp/i
  end
end

describe 'Task 6:' do
  it 'Apply your manifest to ensure the user dana is present and in the wheel group' do
    user('dana').should belong_to_group 'wheel'
  end
end
