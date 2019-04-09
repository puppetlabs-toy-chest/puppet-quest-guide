require_relative './spec_helper'

describe "The hiera quest", host: :localhost do
  it 'begins', :solution do
    command("quest begin hiera")
      .exit_status
      .should eq 0
    command("echo 'puppet' | puppet access login --username learning --lifetime 1d")
      .exit_status
      .should eq 0
  end
end

describe _("Task 1:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/hiera/1/hiera.yaml #{PROD_PATH}/hiera.yaml")
      .exit_status
      .should eq 0
  end
  it _('Create the hiera.yaml configuration file'), :validation do
    file("#{PROD_PATH}/hiera.yaml")
      .should be_file
    file("#{PROD_PATH}/hiera.yaml")
      .content
      .should match /---\s
        version:\s*5\s+
        defaults:\s+
        datadir:\s*data\s+
        data_hash:\s*yaml_data\s+
        hierarchy:\s+
        -\sname:\s*"Per-node\sdata"\s+
        path:\s"nodes\/%{trusted.certname}\.yaml"\s+
        -\sname:\s*"Per-domain\sdata"\s+
        path:\s*"domain\/%{facts\.networking.domain}\.yaml"\s+
        -\sname:\s*"Common\sdata"\s+
        path:\s"common\.yaml"/mx
    command("ruby -e \"require 'yaml';require 'pp';pp YAML.load_file('#{PROD_PATH}/hiera.yaml')\"")
        .exit_status
        .should be_zero
  end
end

describe _("Task 2:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/hiera/2/app.pp #{MODULE_PATH}/profile/manifests/pasture/app.pp")
      .exit_status
      .should eq 0
  end
  it _('Modify the profile::pasture::app class to use Hiera lookups'), :validation do
    file("#{MODULE_PATH}/profile/manifests/pasture/app.pp")
      .should be_file
    file("#{MODULE_PATH}/profile/manifests/pasture/app.pp")
      .content
      .should match /lookup\('profile::pasture::app::default_message'\),.*
        lookup\('profile::pasture::app::sinatra_server'\),.*
        lookup\('profile::pasture::app::default_character'\),.*
        lookup\('profile::pasture::app::db'\),?/mx
    command("puppet parser validate #{MODULE_PATH}profile/manifests/pasture/app.pp")
      .exit_status
      .should be_zero
  end
end

describe _("Task 3:"), host: :localhost do
  it 'has a working solution', :solution do
    command("mkdir -p #{PROD_PATH}/data/{domain,nodes}")
      .exit_status
      .should eq 0
  end
  it _('Create the data directory tree'), :validation do
    file("#{PROD_PATH}/data")
      .should be_directory
    file("#{PROD_PATH}/data/domain")
      .should be_directory
    file("#{PROD_PATH}/data/nodes")
      .should be_directory
  end
end

describe _("Task 4:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/hiera/4/common.yaml #{PROD_PATH}/data/common.yaml")
      .exit_status
      .should eq 0
  end
  it _('Create the common.yaml data source'), :validation do
    file("#{PROD_PATH}/data/common.yaml")
      .should be_file
    file("#{PROD_PATH}/data/common.yaml")
      .content
      .should match /---\s+
        profile::pasture::app::default_message:\s*(["'])Baa\1\s+
        profile::pasture::app::sinatra_server:\s*(["'])thin\1\s+
        profile::pasture::app::default_character:\s*(["'])sheep\1\s+
        profile::pasture::app::db:\s*(["'])none\1/mx
  end
end

describe _("Task 5:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/hiera/5/beauvine.vm.yaml #{PROD_PATH}/data/domain/beauvine.vm.yaml")
      .exit_status
      .should eq 0
  end
  it _('Create the beauvine.vm.yaml data source'), :validation do
    file("#{PROD_PATH}/data/domain/beauvine.vm.yaml")
      .should be_file
    file("#{PROD_PATH}/data/domain/beauvine.vm.yaml")
      .content
      .should match /---\s+
        profile::pasture::app::default_message:\s*(["'])Welcome\sto\sBeauvine!\1/mx
  end
end

describe _("Task 6:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/hiera/6/auroch.vm.yaml #{PROD_PATH}/data/domain/auroch.vm.yaml")
      .exit_status
      .should eq 0
  end
  it _('Create the auroch.vm.yaml data source'), :validation do
    file("#{PROD_PATH}/data/domain/auroch.vm.yaml")
      .should be_file
    file("#{PROD_PATH}/data/domain/auroch.vm.yaml")
      .content
      .should match /---\s+
        profile::pasture::app::default_message:\s*(["'])Welcome\sto\sAuroch!\1\s+
        profile::pasture::app::db:\s*(['"])postgres:\/\/pasture:m00m00@pasture-db\.auroch\.vm\/pasture\1\s+/mx
  end
end

describe _("Task 7:"), host: :localhost do
  it 'has a working solution', :solution do
    command("yes | cp -f #{SOLUTION_PATH}/hiera/7/pasture-app-dragon.auroch.vm.yaml #{PROD_PATH}/data/nodes/pasture-app-dragon.auroch.vm.yaml")
      .exit_status
      .should eq 0
  end
  it _('Create the pasture-app-dragon.auroch.vm.yaml data source'), :validation do
    file("#{PROD_PATH}/data/nodes/pasture-app-dragon.auroch.vm.yaml")
      .should be_file
    file("#{PROD_PATH}/data/nodes/pasture-app-dragon.auroch.vm.yaml")
      .content
      .should match /---\s+
        profile::pasture::app::default_character:\s*(["'])dragon\1/mx
  end
end

describe _("Task 8:"), host: :localhost do
  it 'has a working solution', :solution do
    command("puppet job run --nodes pasture-db.auroch.vm,pasture-app-dragon.auroch.vm,pasture-app.auroch.vm,pasture-app.beauvine.vm --concurrency 2")
      .exit_status
      .should eq 0
  end
  it _('Test API endpoints'), :validation do
    command("curl pasture-app-dragon.auroch.vm/api/v1/cowsay/sayings")
      .exit_status
      .should eq 0
  end
end
