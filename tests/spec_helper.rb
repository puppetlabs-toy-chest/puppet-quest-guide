require 'serverspec'
require 'pathname'
require 'highline/import'
require 'net/ssh'
require 'gettext-setup'
### include requirements ###

PROD_PATH = '/etc/puppetlabs/code/environments/production/'
MODULE_PATH = "#{PROD_PATH}modules/"
SOLUTION_PATH = File.expand_path('../solution_files/', __FILE__)

GettextSetup.initialize(File.expand_path('./locales', File.dirname(__FILE__)))
GettextSetup.negotiate_locale!(GettextSetup.candidate_locales)

def docker_hosts
  hosts = {}
  containers = `docker ps`.split("\n")
  containers.shift
  containers.each do |line|
    name = line.split.last
    hosts[name] = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' #{name}`.chomp
  end
  return hosts
end

def poll_nodes(poll_name, max_retries=10, interval=2, initial_sleep=0)
  sleep initial_sleep
  docker_hosts.each do |name, _|
    retries = 0
    while !yield(name) do
      sleep interval
      retries += 1
      fail "Timed out waiting for #{poll_name}." if retries > max_retries
    end
  end
end

def wait_for_pxp_service
  poll_nodes("pxp-agent service", max_retries=20) do |name|
    system("docker exec -it #{name} systemctl status pxp-agent.service | grep 'running'")
  end
end

set :backend, :exec

### enable both :should and :expect syntax ###
RSpec.configure do |config|
  config.filter_run_excluding :solution => true
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.before(:example, :host => :agent) do
    set :backend, 'ssh'
    set :host, 'agent.puppet.vm'
    options = {password: 'puppet', user: 'learning'}
    set :ssh_options, options
  end
  config.before(:example, :host => :cowsay) do
    set :backend, 'ssh'
    set :host, 'cowsay.puppet.vm'
    options = {password: 'puppet', user: 'learning'}
    set :ssh_options, options
  end
  config.before(:example, :host => :hello) do
    set :backend, 'ssh'
    set :host, 'hello.puppet.vm'
    options = {password: 'puppet', user: 'learning'}
    set :ssh_options, options
  end
  config.before(:example, :host => :pasture) do
    set :backend, 'ssh'
    set :host, 'pasture.puppet.vm'
    options = {password: 'puppet', user: 'learning'}
    set :ssh_options, options
  end
  config.before(:example, :host => :pastureapp) do
    set :backend, 'ssh'
    set :host, 'pasture-app.puppet.vm'
    options = {password: 'puppet', user: 'learning'}
    set :ssh_options, options
  end
  config.before(:example, :host => :pastureappsmall) do
    set :backend, 'ssh'
    set :host, 'pasture-app-small.puppet.vm'
    options = {password: 'puppet', user: 'learning'}
    set :ssh_options, options
  end
  config.before(:example, :host => :localhost) do
    set :backend, 'exec'
    set :host, 'localhost'
  end
end
