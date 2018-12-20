#!/opt/puppetlabs/puppet/bin/puppet apply
class profile::base::motd {
  include motd
}
