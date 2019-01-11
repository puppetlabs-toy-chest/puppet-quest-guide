#!/opt/puppetlabs/puppet/bin/puppet apply
class role::pasture_db {
  include profile::pasture::db
  include profile::base::motd
}
