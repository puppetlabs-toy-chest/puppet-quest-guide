#!/opt/puppetlabs/puppet/bin/puppet apply
class cowsay::fortune {
  package { 'fortune-mod':
    ensure => present,
  }
}
