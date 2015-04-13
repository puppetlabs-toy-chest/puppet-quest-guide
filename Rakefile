require 'open3'

# GitHub repository data

GH_DEV  = 'puppetlabs'
GH_REPO = 'courseware-lvm'

# Directories

DIR = File.dirname(__FILE__)

QUEST_GUIDE = File.join(DIR, 'Quest_Guide')

TEST_DIR_SOURCE = File.join(DIR, 'quest_tool/.testing')
BIN_SOURCE = File.join(DIR, 'quest_tool/bin') 
SITE_ROOT_SOURCE = File.join(DIR, 'Quest_Guide/_site')

TARGET_PREFIX = ENV['HOSTNAME'] == "learning.puppetlabs.vm" ? '' : '/tmp/learningvm'

TEST_DIR = "#{TARGET_PREFIX}/root/"
BIN_DIR = "#{TARGET_PREFIX}/root/"
SITE_ROOT = "#{TARGET_PREFIX}/var/www/questguide/"

# Tasks

task :deploy => :build do
  unless ENV['HOSTNAME'] == "learning.puppetlabs.vm"
    puts "HOSTNAME != learning.puppetlabs.vm. Deploy tasks will target /tmp/learningvm for testing purposes."
    unless system("mkdir -p /tmp/learningvm/{root,var/www/questguide}")
      raise "There was an error creating the /tmp/learningvm directory"
    end
  end
  unless system("cp -R #{TEST_DIR_SOURCE} #{TEST_DIR}")
    raise "There was an error copying the test files"
  end
  unless system("cp -R #{SITE_ROOT_SOURCE} #{SITE_ROOT}")
    raise "There was an error copying the Quest Guide files"
  end
  unless system("cp -R #{BIN_SOURCE} #{BIN_DIR}")
    raise "There was an error copying the bin files"
  end
end

task :build do
  Open3.popen3('jekyll', 'build', chdir: QUEST_GUIDE) do |i, o, e, t|
    i.close
    puts e.read
    puts t.value
  end
end

task :fetch => :config do
  pull_upstream_master
end

task :config do
  ensure_remote('upstream', "https://github.com/#{GH_DEV}/#{GH_REPO}.git")
end

# Helper Functions

def ensure_remote(remote, url)
  unless system("git config --get remote.#{remote}.url > /dev/null")
    # Add the remote if it doesn't already exist
    unless system("git remote add #{remote} #{url}")
      raise "Could not add the '#{remote}' remote."
    end
  end
end

def pull(remote, branch)
  unless system("git pull #{remote} #{branch} > /dev/null")
    raise "Could not pull #{remote} #{branch}"
  end
end

def provide_bailout(message)
  print "#{message} Continue? [Y/n]: "
  raise "User cancelled" unless [ 'y', 'yes', '' ].include? STDIN.gets.strip.downcase
end
