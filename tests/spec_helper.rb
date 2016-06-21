require 'serverspec'
require 'pathname'
### include requirements ###

PROD_PATH = '/etc/puppetlabs/code/environments/production/'
MODULE_PATH = "#{PROD_PATH}modules/"
PE_VERSION = '2016.1.2'
