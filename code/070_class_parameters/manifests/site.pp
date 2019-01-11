#!/opt/puppetlabs/puppet/bin/puppet apply
node 'pasture.puppet.vm' {
  class { 'pasture':
    default_character => 'cow',
  }
}
