require_relative './spec_helper'

describe "The facts quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin facts")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :pasture do
  it _('Use the facter command') do
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

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/motd/{manifests,templates}")
      .exit_status
      .should eq 0
  end
  it _('Create motd module directories'), :validation do
    file("#{MODULE_PATH}motd/manifests")
      .should be_directory
    file("#{MODULE_PATH}motd/templates")
      .should be_directory
  end
end

describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/facts/3/init.pp #{MODULE_PATH}/motd/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the motd module main manifest'), :validation do
    file("#{MODULE_PATH}motd/manifests/init.pp")
      .should be_file
    file("#{MODULE_PATH}motd/manifests/init.pp")
      .content
      .should match /class\s+motd\s+\{.*?\$motd_hash\s+=\s+\{.*?(['"])fqdn\1\s+=>\s+\$facts\[(['"])networking\1\]\[(['"])fqdn\1\],/m
    file("#{MODULE_PATH}motd/manifests/init.pp")
      .content
      .should match /content\s+=>\s+epp\((['"])motd\/motd\.epp\1,\s+\$motd_hash\),/
  end
end

describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/facts/4/motd.epp #{MODULE_PATH}/motd/templates/motd.epp")
      .exit_status
      .should eq 0
  end
  it _('Create the motd.epp template'), :validation do
    file("#{MODULE_PATH}motd/templates/motd.epp")
      .should be_file
    file("#{MODULE_PATH}motd/templates/motd.epp")
      .content
      .should match /This\s+is\s+a\s+<%=\s+\$os_family\s+%>\s+system\s+running\s+<%=\s+\$os_name\s+%>\s+<%=\s+\$os_release\s+%>/
  end
end

describe _("Task 5:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/facts/5/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Classify the node with the motd class'), :validation do
    file("#{PROD_PATH}manifests/site.pp")
      .content
      .should match /node\s+(['"])?pasture\.puppet\.vm\1\s+\{.*?include\s+motd/m
  end
end

describe _("Task 6:"), host: :pasture do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Run the agent and update the /etc/motd file') do
    file('/etc/motd')
      .content
      .should match /Welcome\s+to\s+pasture\.puppet\.vm.*?This\s+is\s+a\s+RedHat/m
  end
end
