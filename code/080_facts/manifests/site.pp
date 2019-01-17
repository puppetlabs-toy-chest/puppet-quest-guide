#!/opt/puppetlabs/puppet/bin/puppet apply
node 'pasture.puppet.vm' {
  include motd
  class { 'pasture':
    default_character => 'cow',
  }
}
