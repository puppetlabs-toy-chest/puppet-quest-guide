#!/opt/puppetlabs/puppet/bin/puppet apply
node 'cowsay.puppet.vm' {
  include cowsay
}
