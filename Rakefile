# Use bin and gems in /opt/quest to avoid conflicts with puppet's
# bin and gems contents

ENV['PATH'] +=  ':/opt/quest/bin'
ENV['GEM_PATH'] = '/opt/quest/gems'

require 'open3'
require 'yaml'
require 'rspec'
require 'pp'

# GitHub repository data

GH_DEV  = 'puppetlabs'
GH_REPO = 'courseware-lvm'

# Directories

DIR = File.dirname(__FILE__)

QUEST_GUIDE =      File.join(DIR, 'Quest_Guide')

HOME_DIR_SOURCE =  File.join(DIR, 'quest_tool/.')
SITE_ROOT_SOURCE = File.join(DIR, 'Quest_Guide/_site/.')

TARGET_PREFIX = ENV['HOSTNAME'] == "learning.puppetlabs.vm" ? '' : '/tmp/learningvm'

HOME_DIR =  "#{TARGET_PREFIX}/root/"
SITE_ROOT = "#{TARGET_PREFIX}/var/www/html/questguide/"
# PE webserver will serve out static files

# Tasks

task :deploy => :build do
  unless ENV['HOSTNAME'] == "learning.puppetlabs.vm"
    puts "HOSTNAME != learning.puppetlabs.vm. Deploy tasks will target /tmp/learningvm for testing purposes."
    unless system("mkdir -p /tmp/learningvm/{root,var/www/questguide}")
      raise "There was an error creating the /tmp/learningvm directory"
    end
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
    system('jekyll build')
  end
end

task :update_stable => [:fetch, :deploy]
task :update_newest => [:fetch_newest, :deploy]

task :fetch => :config do
  checkout('release')
  pull('upstream', 'release')
end

task :fetch_newest => :config do
  checkout('master')
  pull('upstream', 'master')
end

task :config do
  ensure_branch('release')
  ensure_remote('upstream', "https://github.com/#{GH_DEV}/#{GH_REPO}.git")
end

task :test_all do
  unless ENV['HOSTNAME'] == "learning.puppetlabs.vm"
    raise "Aborting test. Tests should only be run on the Learning VM itself."
  end
  Dir.chdir "/root/.testing" do
    test_all
  end
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

def ensure_branch(branch)
  system("git branch #{branch} > /dev/null")
end

def checkout(branch)
  unless system("git checkout #{branch} --quiet")
    raise "Your current branch has unsaved changes."
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
    json_formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
    reporter = RSpec::Core::Reporter.new(formatter)
    config.instance_variable_set(:@reporter, reporter)
    RSpec::Core::Runner.run(["/root/.testing/spec/localhost/#{q}_spec.rb"])
    unless RSpec::Core::Runner.run(["/root/.testing/spec/localhost/#{q}_spec.rb"]) == 0
      failures = true
    end
    RSpec.reset
  end
  abort if failures
end
