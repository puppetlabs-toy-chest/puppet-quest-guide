describe "Task 1:", host: :hello do
  it 'Install the Puppet agent' do
    file('/opt/puppetlabs/puppet/bin/puppet')
      .should be_file
  end
end

describe "Task 2:", host: :hello do
  it 'Investigate the /tmp/test file resource' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource file \/tmp\/test/
  end
end

describe "Task 3:", host: :hello do
  it 'Create the /tmp/test file resource' do
    file('/tmp/test')
      .should be_file
    file('/home/learning/.bash_history')
      .content
      .should match /touch \/tmp\/test.*sudo puppet resource file \/tmp\/test/m
  end
end

describe "Task 4:", host: :hello do
  it 'Create the /tmp/test file resource' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource file \/tmp\/test content='Hello Puppet!'.*cat \/tmp\/test/m
  end
end

describe "Task 5:", host: :hello do
  it 'Create the /tmp/test file resource' do
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource package httpd/
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource package bogus-package ensure=present/
    file('/home/learning/.bash_history')
      .content
      .should match /sudo puppet resource package bogus-package ensure=present provider=gem/
    package('httpd')
      .should be_installed
  end
end
