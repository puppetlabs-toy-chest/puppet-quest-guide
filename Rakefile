# Use bin and gems in /opt/quest to avoid conflicts with puppet's
# bin and gems contents

ENV['PATH'] +=  ':/opt/quest/bin'
ENV['GEM_PATH'] = '/opt/quest/gems'

require 'open3'
require 'yaml'
require 'rspec'
require 'rspec/core/formatters/base_text_formatter'
require 'pp'

# GitHub repository data
# Set ENV variables to override repository information for testing.
GH_DEV  = ENV['GH_DEV'] || 'puppetlabs'
GH_REPO = ENV['GH_REPO'] || 'courseware-lvm'
GH_REMOTE = ENV['GH_REMOTE'] || 'upstream'
GH_BRANCH = ENV['GH_BRANCH'] || 'master'

# Directories

DIR = File.dirname(__FILE__)

QUEST_GUIDE =      File.join(DIR, 'Quest_Guide')

HOME_DIR_SOURCE =  File.join(DIR, 'quest_tool/.')
SITE_ROOT_SOURCE = File.join(DIR, 'Quest_Guide/_site/.')

HOME_DIR =  "/root/"
TEST_DIR = File.join(HOME_DIR, ".testing/spec/localhost/")
SITE_ROOT = "/var/www/html/questguide/"

# Tasks

task :deploy => :build do
  unless system("rm -rf #{TEST_DIR}*.rb")
    raise "There was an error deleting existing tests"
  end
  unless system("cp -R #{HOME_DIR_SOURCE} #{HOME_DIR}")
    raise "There was an error copying the home directory files"
  end
  unless system("cp -R #{SITE_ROOT_SOURCE} #{SITE_ROOT}")
    raise "There was an error copying the Quest Guide files"
  end
end

task :build do
  Dir.chdir QUEST_GUIDE do
    system('jekyll build --quiet')
  end
end

task :update => [:fetch, :deploy]

task :fetch => :config do
  # If we're dealing with the master branch, we want to get the
  # latest tagged release.
  if GH_BRANCH == 'master'
    tag = latest_tag
    puts "Checking out #{GH_REPO} release #{tag}"
    checkout_tag(tag)
  # Otherwise, check out head of the specified branch.
  else
    checkout(GH_BRANCH)
    pull(GH_REMOTE, GH_BRANCH)
  end
end

task :config do
  ensure_branch(GH_BRANCH)
  ensure_remote(GH_REMOTE, "https://github.com/#{GH_DEV}/#{GH_REPO}.git")
end

task :test_all do
  Dir.chdir "/root/.testing" do
    test_all
  end
end

# Helper Functions

def latest_tag
  unless system("git fetch --tags")
    raise "There was an error fetching the latest tags"
  end
  `git describe --tags --abbrev=0`
end

def ensure_remote(remote, url)
  unless system("git config --get remote.#{remote}.url > /dev/null")
    # Add the remote if it doesn't already exist
    unless system("git remote add #{remote} #{url}")
      raise "Could not add the '#{remote}' remote."
    end
  end
end

def ensure_branch(branch)
  unless system("git rev-parse --verify #{branch} > /dev/null")
    # Create branch if it doesn't already exist
    unless system("git branch #{branch} 2> /dev/null")
      raise "There was an error creating branch #{branch}"
    end
  end
end

def checkout(branch)
  unless system("git checkout #{branch} > /dev/null")
    raise "Your current branch has unsaved changes."
  end
end

def checkout_tag(tag)
  system("git clean -df")
  system("git checkout -- . > /dev/null")
  system("git checkout tags/#{tag} > /dev/null")
end

def pull(remote, branch)
  unless system("git pull #{remote} #{branch} > /dev/null")
    raise "Could not pull #{remote} #{branch}"
  end
end

def solve_quest(name)

  quest = name.downcase == 'welcome' ? 'index' : "quests/#{name.downcase.split.join('_')}"

  f = File.open(File.join(QUEST_GUIDE, "#{quest}.md"))
  task_specs = f.read.scan(/{%\stask\s(\d+)\s%}(.*?){%\sendtask\s%}/m)
  tasks = task_specs.collect do |m|
    begin
      YAML.load(m[1])
    rescue Psych::SyntaxError => e
      puts "There was an error parsing the solution for Task #{m[0]}"
      puts "Validate that the following is valid YAML: #{m[1]}"
      raise
    end
  end
  f.close
  tasks.each do |t|
    t.each do |s|
      if s['execute']
        # Capture an environment variable if present.
        # Note that this will only currently work for one
        # environment variable.
        m = /^(\S+)=(\S+)\s(.*)/.match(s['execute'])
        # If there is an environment variable, pass that to the
        # process as a hash, preceding the string otherwise pass
        # the raw string.
        a = m ? [{m[1] => m[2]}, m[3]] : [s['execute']]
        Open3.popen3(*a) do |i, o, e, t|
          if s['input']
            s['input'].each { |w| i.write(w) }
          end
          i.close
          o.read
        end
        # Some task spec tests just check bash history
        open('/root/.bash_history', 'a') { |f|
          f.puts s['execute']
        }
      end
      if s['file']
        open(s['file'], 'w') { |f|
          f.puts s['content']
        }
      end
    end
  end
end

def test_all
  quests = ['welcome',
            'power_of_puppet',
            'resources',
            'manifests_and_classes',
            'modules',
            'ntp',
            'mysql',
            'variables_and_parameters',
            'conditional_statements',
            'resource_ordering']
  failures = false
  quests.each do |q|
    solve_quest(q)
    config = RSpec.configuration
    config.output_stream = File.open('/var/log/quest_spec', 'a')
    formatter = RSpec::Core::Formatters::BaseTextFormatter.new(config.output_stream)
    reporter = RSpec::Core::Reporter.new(formatter)
    config.instance_variable_set(:@reporter, reporter)
    unless RSpec::Core::Runner.run(["/root/.testing/spec/localhost/#{q}_spec.rb"]) == 0
      failures = true
    end
    RSpec.reset
  end
  abort if failures
end
