describe "Task 1:", host: :pasture do
  it 'Use the facter command' do
    file('/home/learning/.bash_history')
      .content
      .should match /facter\s+\-p\s+\|\s+less/
    file('/home/learning/.bash_history')
      .content
      .should match /facter\s+\-p\s+os/
    file('/home/learning/.bash_history')
      .content
      .should match /facter\s+\-p\s+os\.family/
  end
end

describe "Task 2:", host: :localhost do
  it 'Create motd module directories' do
    file('/etc/puppetlabs/code/environments/production/modules/motd/manifests')
      .should be_directory
    file('/etc/puppetlabs/code/environments/production/modules/motd/templates')
      .should be_directory
  end
end

describe "Task 3:", host: :localhost do
  it 'Create the motd module main manifest' do
    file('/etc/puppetlabs/code/environments/production/modules/motd/manifests/init.pp')
      .should be_file
    file('/etc/puppetlabs/code/environments/production/modules/motd/manifests/init.pp')
      .content
      .should match /class\s+motd\s+\{.*?\$motd_hash\s+=\s+\{.*?(['"])fqdn\1\s+=>\s+\$facts\[(['"])networking\1\]\[(['"])fqdn\1\],/m
    file('/etc/puppetlabs/code/environments/production/modules/motd/manifests/init.pp')
      .content
      .should match /content\s+=>\s+epp\((['"])motd\/motd\.epp\1,\s+\$motd_hash\),/
  end
end

describe "Task 4:", host: :localhost do
  it 'Create the motd.epp template' do
    file('/etc/puppetlabs/code/environments/production/modules/motd/templates/motd.epp')
      .should be_file
    file('/etc/puppetlabs/code/environments/production/modules/motd/templates/motd.epp')
      .content
      .should match /This\s+is\s+a\s+<%=\s+\$os_family\s+%>\s+system\s+running\s+<%=\s+\$os_name\s+%>\s+<%=\s+\$os_release\s+%>/
  end
end

describe "Task 5:", host: :localhost do
  it 'Classify the node with the motd class' do
    file('/etc/puppetlabs/code/environments/production/manifests/site.pp')
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?include\s+motd/m
  end
end

describe "Task 6:", host: :pasture do
  it 'Run the agent and update the /etc/motd file' do
    file('/etc/motd')
      .content
      .should match /Welcome\s+to\s+pasture\.puppet\.vm.*?This\s+is\s+a\s+RedHat/m
  end
end
