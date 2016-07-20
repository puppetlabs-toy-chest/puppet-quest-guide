describe "Task 1:", host: :localhost do
  it 'List the subcommands for the quest tool' do
    file('/root/.bash_history')
      .content
      .should match /quest\s+(-h|--help)/
  end
end

describe "Task 2:", host: :localhost do
  it 'Check the list of available quests' do
    file('/root/.bash_history')
      .content
      .should match /quest\s+list/
  end
end

describe "Task 3:", host: :hello do
  it 'Install the Puppet agent' do
    file('/opt/puppetlabs/bin/puppet')
      .should be_file
  end
end

describe "Task 4:", host: :hello do
  it 'Investigate the root user resource' do
    file('/root/.bash_history')
      .content
      .should match /puppet resource user root/
  end
end

describe "Task 5:", host: :hello do
  it 'Create the galatea user with the useradd command' do
    file('/root/.bash_history')
      .content
      .should match /useradd galatea/
  end
end

describe "Task 6:", host: :hello do
  it "Modify the galatea user's commnet" do
    file('/root/.bash_history')
      .content
      .should match /usermod galatea -c "Galatea of Cyprus"/
  end
end

describe "Task 7:", host: :hello do
  it 'Use the puppet resource tool to remove the galatea user' do
    file('/root/.bash_history')
      .content
      .should match /puppet resource user galatea ensure=absent/
  end
end

describe "Task 8:", host: :hello do
  it 'Use the puppet resource tool to recreate the galatea user' do
    file('/root/.bash_history')
      .content
      .should match /puppet resource user galatea ensure=present/
  end
end

describe "Task 9:", host: :hello do
  it "Use puppet resource -e to modify the galatea user's comment field" do
    file('/root/.bash_history')
      .content
      .should match /puppet resource -e user galatea/
    file('/etc/passwd')
      .content
      .should match /Galatea of Cyprus/
  end
end

describe "Task 10:", host: :hello do
  it 'View the os fact' do
    file('/root/.bash_history')
      .content
      .should match /facter os/
  end
end

describe "Task 11:", host: :hello do
  it 'View the os.family fact' do
    file('/root/.bash_history')
      .content
      .should match /facter os.family/
  end
end

describe "Task 12:", host: :hello do
  it 'Attempt a puppet agent run' do
    file('/root/.bash_history')
      .content
      .should match /puppet agent -t/
  end
end


describe "Task 13:", host: :localhost do
  it 'Sign the cert for hello.learning.puppetlabs.vm' do
    file('/etc/puppetlabs/puppet/ssl/ca/signed/hello.learning.puppetlabs.vm.pem')
      .should be_file
  end
end

describe "Task 14:", host: :hello do
  it 'Trigger a puppet agent run on your agent node' do
    file('/etc/puppetlabs/puppet/ssl/certs/hello.learning.puppetlabs.vm.pem')
      .should be_file
  end
end

describe "Task 15:", host: :localhost do
  it 'Add a resource declaration for the galatea user to your site.pp' do
    file('/etc/puppetlabs/code/environment/production/manifests/site.pp')
      .content
      .should match /node\s+hello\.learning\.puppetlabs\.vm\s+\{\s+
                      user\s+\{\s+'galatea':\s+
                      ensure\s+=\>\s+'present',\s+
                      comment\s+=\>\s+'Galatea of Cyprus',\s+
                      \}\s+
                      file\s+\{\s+'\/home\/galatea':\s+
                      ensure\s+=\>\s+'present',\s+
                      owner\s+=\>\s+'galatea',\s+
                      \}\s+
                      \}/mx
  end
end

describe "Task 16:", host: :hello do
  it 'Validate your site.pp code' do
    file('/root/.bash_history')
      .content
      .should match "puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp"
  end
end

describe "Task 17:", host: :hello do
  it 'Trigger a puppet agent run on your agent node' do
    file('/home/galatea')
      .should be_directory
  end
end
