#!/opt/puppetlabs/puppet/bin/puppet apply
node 'agent.puppet.vm' {
  notify { 'Hello Puppet!': }
}
