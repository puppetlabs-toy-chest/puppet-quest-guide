require 'serverspec'
require 'pathname'
require 'highline/import'
require 'net/ssh'
### include requirements ###

PROD_PATH = '/etc/puppetlabs/code/environments/production/'
MODULE_PATH = "#{PROD_PATH}modules/"

set :backend, :exec

### enable both :should and :expect syntax ###
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.before(:example, :host => :agent) do
    set :backend, 'ssh'
    set :host, 'agent.puppet.vm'
    options = {password: 'puppet', user: 'root'}
    set :ssh_options, options
  end
  config.before(:example, :host => :hello) do
    set :backend, 'ssh'
    set :host, 'hello.puppet.vm'
    options = {password: 'puppet', user: 'root'}
    set :ssh_options, options
  end
  config.before(:example, :host => :localhost) do
    set :backend, 'exec'
    set :host, 'localhost'
  end
end
