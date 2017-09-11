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
