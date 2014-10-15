require 'spec_helper'

describe "The puppet resource command" do
  it 'should be used to inspect user root' do
    file('/root/.bash_history').should contain 'puppet resource user root'
  end
end

describe "The puppet describe command" do
  it 'should be used to get a description of the user type' do
    file('/root/.bash_history').should contain 'puppet describe user'
  end
end

describe "The user galatea" do
  it 'should exist on the system' do
    file('/etc/passwd').should contain "galatea"
  end
end

describe "The user galatea" do
  it 'should have the comment Galatea of Cyprus' do
    file('/etc/passwd').should contain 'Galatea of Cyprus'
  end
end
