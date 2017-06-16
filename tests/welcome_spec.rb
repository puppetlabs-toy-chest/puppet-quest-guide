require './spec_helper'

describe "The quest", :solution do
  it 'begins' do
    command('quest begin welcome')
      .exit_status
      .should eq 0
  end
end

describe "Task 1:" do
  it 'has a working solution', :solution do
    command('quest --help')
      .exit_status
      .should eq 0
  end
  it 'View the options for the quest tool' do
    file('/root/.bash_history')
      .content
      .should match /quest\s+(-h|--help)/
  end
end

describe "Task 2:" do
  it 'has a working solution', :solution do
    command('quest list')
      .exit_status
      .should eq 0
  end
  it 'View the list of available quests' do
    file('/root/.bash_history')
      .content
      .should match /quest\s+list/
  end
end
