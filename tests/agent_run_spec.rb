describe "Task 8:", host: :agent do
  it 'Run the pre-installed agent' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet agent -t/
  end
end

describe "Task 9:", host: :localhost do
  it 'Sign the agent certificate' do
    file('/root/.bash_history')
      .content
      .should match /puppet cert list/
    file('/root/.bash_history')
      .content
      .should match /puppet cert sign agent.puppet.vm/
  end
end

describe "Task 10:", host: :agent do
  it 'Check for successful agent run' do
    file('/var/opt/lib/pe-puppet/lib/shared/pe_server_version.rb')
      .should be_file
  end
end

describe "Task 11:", host: :localhost do
  it 'Check for site.pp classification' do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+'agent\.puppet\.vm'\s+\{.*?notify\s+\{\s+'Hello\s+Puppet!':\s+\}.*?\}/mi
  end
end

describe "Task 12:", host: :agent do
  it 'Check for successful agent run with classification' do
    file('/var/opt/lib/pe-puppet/state/resources.txt')
      .should be_file
    file('/var/opt/lib/pe-puppet/state/resources.txt')
      .content
      .should match /notify\[Hello Puppet!\]/
  end
end
