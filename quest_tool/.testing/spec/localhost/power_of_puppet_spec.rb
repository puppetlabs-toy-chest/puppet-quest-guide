require 'spec_helper'

describe 'Task 1:' do
  it 'Use the puppet module tool to search for graphite' do
    file('/root/.bash_history').should contain "puppet module search graphite"
  end
end

describe 'Task 2:' do
  it 'Install the dwerder-graphite module' do 
    file("#{MODULE_PATH}graphite").should be_directory
    file("#{MODULE_PATH}graphite/metadata.json").should contain '"name": "dwerder-graphite"'
  end
end

describe 'Task 3:' do
  it "Use facter to find the Learning VM's IP address" do
    file('/root/.bash_history').should contain "facter ipaddress"
  end
end

describe "Task 4:" do
  it 'Trigger a puppet agent run to install and configure Graphite' do 
    service('carbon-cache').should be_running
  end
end
