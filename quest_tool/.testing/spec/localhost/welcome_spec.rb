require 'spec_helper'

describe "Task 1:" do
  it 'Use puppet -V to check the puppet version' do 
    file('/root/.bash_history').should contain 'puppet -V'
  end
end

describe "Task 2:" do
  it 'View the options for the quest tool' do
    file('/root/.bash_history').should contain "quest --help"
  end
end

describe "Task 3:" do
  it 'Check the quest progress' do 
    file('/root/.bash_history').should contain "quest --progress"
  end
end
