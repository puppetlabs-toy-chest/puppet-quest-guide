require 'serverspec'
require 'pathname'
### include requirements ###

set :backend, :exec

PROD_PATH = '/etc/puppetlabs/code/environments/production/'
MODULE_PATH = "#{PROD_PATH}modules/"
