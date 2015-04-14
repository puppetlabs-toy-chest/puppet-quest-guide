$:.unshift File.join( %w{ /root .gem ruby 1.9.1 } )
ENV['PATH'] +=  ':/root/.gem/ruby/1.9.1/bin'

require 'open3'

# GitHub repository data

GH_DEV  = 'puppetlabs'
GH_REPO = 'courseware-lvm'

# Directories

DIR = File.dirname(__FILE__)

QUEST_GUIDE =      File.join(DIR, 'Quest_Guide')

TEST_DIR_SOURCE =  File.join(DIR, 'quest_tool/.testing')
BIN_SOURCE =       File.join(DIR, 'quest_tool/bin') 
SITE_ROOT_SOURCE = File.join(DIR, 'Quest_Guide/_site')

TARGET_PREFIX = ENV['HOSTNAME'] == "learning.puppetlabs.vm" ? '' : '/tmp/learningvm'

TEST_DIR =  "#{TARGET_PREFIX}/root/"
BIN_DIR =   "#{TARGET_PREFIX}/root/"
SITE_ROOT = "#{TARGET_PREFIX}/var/www/questguide/"
# PE webserver will serve out static files

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
  Open3.popen3('jekyll', 'build', :chdir => QUEST_GUIDE) do |i, o, e, t|
    i.close
    puts e.read
    puts t.value
  end
end

task :fetch => :config do
  checkout_master
  pull('upstream', 'master')
end

task :config do
  ensure_remote('upstream', "https://github.com/#{GH_DEV}/#{GH_REPO}.git")
end

task :test_all do
  unless ENV['HOSTNAME'] == "learning.puppetlabs.vm"
    raise "Aborting test. Tests should only be run on the Learning VM itself."
  end
  test_all
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

def checkout_master
  unless system("git checkout master --quiet")
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
            s['input'].each { |w| puts w.inspect }
            s['input'].each { |w| i.write(w) }
          end
          i.close
          puts o.read
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
  failures = []
  quests.each do |q|
    solve_quest(q)
    RSpec::Core::Runner.run(["/root/.testing/spec/localhost/#{q}_spec.rb"])
    json_formatter.output_hash[:examples].each do |example|
      if example[:status] == 'failed'
        failures << {:quest => name, :task => example[:full_description]}
      end
    end
  end
  unless failures.empty?
    abort failures.pretty_inspect
  end
end

def test_quest(name)
  solve_quest(name)
  RSpec::Core::Runner.run(["/root/.testing/spec/localhost/#{name}_spec.rb"])
  failures = []
  json_formatter.output_hash[:examples].each do |example|
    if example[:status] == 'failed'
      failures << {:quest => name, :task => example[:full_description]}
    end
  end
  unless failures.empty?
    abort failures.pretty_inspect
  end
end
