#!/opt/puppetlabs/puppet/bin/puppet apply
class role::pasture_app {
  include profile::pasture::app
  include profile::base::motd
}
