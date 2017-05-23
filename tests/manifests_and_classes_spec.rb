describe "Task 1:", host: :localhost do
  it 'Display the module path' do
    file('/root/.bash_history')
      .content
      .should match /puppet config print modulepath/
  end
end

describe "Task 2:", host: :localhost do
  it 'Make the cowsay module directory' do
    file('/etc/puppetlabs/code/environments/production/modules/cowsay/manifests')
      .should be_directory
  end
end

describe "Task 3:", host: :localhost do
  it 'Create the cowsay default manifest' do
    file('/etc/puppetlabs/code/environments/production/modules/cowsay/manifests/init.pp')
      .should be_file
    command('puppet parser validate /etc/puppetlabs/code/environments/production/modules/cowsay/manifests/init.pp')
      .exit_status
      .should be_zero
  end
end

describe "Task 4:", host: :localhost do
  it 'Update site.pp with classification for cowsay.puppet.vm' do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+(['"])?cowsay\.puppet\.vm\1\s+\{.*?include\s+cowsay.*?\}/mi
  end
end

describe "Task 5:", host: :cowsay do
  it 'Run the agent and test cowsay' do
    package('cowsay')
      .should be_installed
      .by('gem')
    file('/home/learning/.bash_history')
      .content
      .should match /^cowsay/
  end
end

describe "Task 6:", host: :localhost do
  it 'Create the cowsay::fortune class' do
    file('/etc/puppetlabs/code/environments/production/modules/cowsay/manifests/fortune.pp')
      .should be_file
  end
end

describe "Task 7:", host: :localhost do
  it 'Include the cowsay::fortune class into the default class' do
    command('puppet parser validate /etc/puppetlabs/code/environments/production/modules/cowsay/manifests/fortune.pp')
      .exit_status
      .should be_zero
    file('/etc/puppetlabs/code/environments/production/modules/cowsay/manifests/init.pp')
      .content
      .should match /include\s+cowsay::fortune/
    command('puppet parser validate /etc/puppetlabs/code/environments/production/modules/cowsay/manifests/init.pp')
      .exit_status
      .should be_zero
  end
end

describe "Task 8:", host: :cowsay do
  it 'Run the agent and test cowsay with fortune' do
    package('fortune-mod')
      .should be_installed
    file('/home/learning/.bash_history')
      .content
      .should match /^fortune\s+\|\s+cowsay/
  end
end
