describe "Task 1:" do
  it 'Use puppet -V to check the puppet version' do 
    file('/root/.bash_history')
      .content
      .should match /puppet\s+(-V|--version)/
  end
end

describe "Task 2:" do
  it 'View the options for the quest tool' do
    file('/root/.bash_history')
      .content
      .should match /quest\s+(-h|--help)/
  end
end

describe "Task 3:" do
  it 'Check the quest status' do 
    file('/root/.bash_history')
      .content
      .should match /quest\s+status/
  end
end
