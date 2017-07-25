require_relative './spec_helper'

describe "The manifests_and_classes quest", host: :localhost do
  it _('begins'), :solution do
    command("quest begin manifests_and_classes")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :cowsay do
  it _('has a working solution'), :solution do
    command("echo \"notify\ { 'Hello Puppet!': }\" >> /tmp/hello.pp")
      .exit_status
      .should eq 0
  end
  it _('Create a temporary hello.pp manifest'), :validation do
    file('/tmp/hello.pp')
      .content
      .should match /notify\s*{\s*(['"])[\w\s!]+\1:\s*}/m
  end
end

describe _("Task 2:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("mkdir -p #{MODULE_PATH}/cowsay/manifests")
      .exit_status
      .should eq 0
  end
  it _('Make the cowsay module directory'), :validation do
    file("#{MODULE_PATH}/cowsay/manifests")
      .should be_directory
  end
end

describe _("Task 3:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/manifests_and_classes/3/init.pp #{MODULE_PATH}/cowsay/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the cowsay default manifest'), :validation do
    file("#{MODULE_PATH}/cowsay/manifests/init.pp")
      .should be_file
    file("#{MODULE_PATH}/cowsay/manifests/init.pp")
      .content
      .should match /^class\s+cowsay\s+{.*?package\s+{\s+(['"])cowsay\1:/m
    command("puppet parser validate #{MODULE_PATH}/cowsay/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 4:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/manifests_and_classes/4/site.pp #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should eq 0
  end
  it _('Update site.pp with classification for cowsay.puppet.vm'), :validation do
    file("#{PROD_PATH}/manifests/site.pp")
      .content
      .should match /node\s+(['"])?cowsay\.puppet\.vm\1\s+\{.*?include\s+cowsay.*?\}/mi
    command("puppet parser validate #{PROD_PATH}/manifests/site.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 5:"), host: :cowsay do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Run the agent and test cowsay'), :validation do
    package('cowsay')
      .should be_installed
      .by('gem')
  end
end

describe _("Task 6:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/manifests_and_classes/6/fortune.pp #{MODULE_PATH}/cowsay/manifests/fortune.pp")
      .exit_status
      .should eq 0
  end
  it _('Create the cowsay::fortune class'), :validation do
    file("#{MODULE_PATH}/cowsay/manifests/fortune.pp")
      .should be_file
    file("#{MODULE_PATH}/cowsay/manifests/fortune.pp")
      .content
      .should match /^class\s+cowsay::fortune\s+{.*?package\s*{\s*(['"])fortune\-mod\1:/m
  end
end

describe _("Task 7:"), host: :localhost do
  it _('has a working solution'), :solution do
    command("cp #{SOLUTION_PATH}/manifests_and_classes/7/init.pp #{MODULE_PATH}/cowsay/manifests/init.pp")
      .exit_status
      .should eq 0
  end
  it _('Include the cowsay::fortune class into the default class'), :validation do
    file("#{MODULE_PATH}/cowsay/manifests/init.pp")
      .content
      .should match /include\s+cowsay::fortune/
    command("puppet parser validate #{MODULE_PATH}/cowsay/manifests/init.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 8:"), host: :cowsay do
  it _('has a working solution'), :solution do
    command("sudo puppet agent -t")
      .exit_status
      .should_not eq 1
  end
  it _('Run the agent and test cowsay with fortune'), :validation do
    package('fortune-mod')
      .should be_installed
  end
end
