describe "Task 1:", host: :localhost do
  it 'Add parameters to the pasture class' do
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .content
      .should match /class\s+pasture\s+\(.*?\$port\s+=\s+(['"])80\1,/m
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .content
      .should match /\$default_character\s+=\s+(['"])sheep\1,/
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .content
      .should match /\$default_message\s+=\s+(['"])\1,/
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .content
      .should match /\$pasture_config_file\s+=\s+(['"])\/etc\/pasture_config\.yaml\1,/
    command('puppet parser validate /etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .exit_status
      .should be_zero
  end
end

describe "Task 2:", host: :localhost do
  it 'Use resource-like syntax for classification' do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?class\s+\{\s+(['"])pasture\1:.*?default_character\s+=>\s+(['"])cow\1,.*?\}.*?\}/m
    command('puppet parser validate /etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .exit_status
      .should be_zero
  end
end

describe "Task 3:", host: :pasture do
  it 'Run the agent and test the changes' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet agent -t/
    file('/home/learning/.bash_history')
      .content
      .should match /curl \'pasture\.puppet\.vm\/api\/v1\/cowsay\?message=Hello!\'/
  end
end
