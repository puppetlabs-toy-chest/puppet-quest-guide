describe "Task 1:", host: :localhost do
  it 'Create the pasture module directories' do
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests')
      .should be_directory
    file('/etc/puppetlabs/code/environments/production/modules/pasture/files')
      .should be_directory
  end
end

describe "Task 2:", host: :localhost do
  it 'Create the pasture default manifest' do
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .should be_file
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .content
      .should match /^class\s+pasture\s+{.*?package\s+{\s+(['"])pasture\1:/m
    command('puppet parser validate /etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .exit_status
      .should be_zero
  end
end

describe "Task 3:", host: :localhost do
  it 'Update site.pp with classification for pasture.puppet.vm' do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?include\s+pasture.*?\}/mi
  end
end

describe "Task 4:", host: :pasture do
  it 'Run the agent' do
    package('pasture')
      .should be_installed
      .by('gem')
  end
end

describe "Task 5:", host: :pasture do
  it 'Start the pasture service' do
    file('/home/learning/.bash_history')
      .content
      .should match /pasture start &/
  end
end

describe "Task 6:", host: :pasture do
  it 'Test the pasture service' do
    file('/home/learning/.bash_history')
      .content
      .should match /curl 'localhost:4567\/api\/v1\/cowsay\?message=Hello!'/
    file('/home/learning/.bash_history')
      .content
      .should match /curl 'localhost:4567\/api\/v1\/cowsay\?message=Hello!\&character=elephant'/
  end
end

describe "Task 7:", host: :pasture do
  it 'Stop the pasture service' do
    file('/home/learning/.bash_history')
      .content
      .should match /^fg$/
  end
end

describe "Task 8:", host: :localhost do
  it 'Create the pasture configuration file' do
    file('/etc/puppetlabs/code/environments/production/modules/pasture/files/pasture_config.yaml')
      .should be_file
    file('/etc/puppetlabs/code/environments/production/modules/pasture/files/pasture_config.yaml')
      .content
      .should match /^---.*?\s\s:default_character:\s+elephant/m
  end
end

describe "Task 9:", host: :localhost do
  it 'Create the pasture configuration file' do
    file('/etc/puppetlabs/code/environments/production/modules/pasture/manifests/init.pp')
      .content
      .should match /file\s+{\s+(['"])\/etc\/pasture_config\.yaml\1:/
  end
end
