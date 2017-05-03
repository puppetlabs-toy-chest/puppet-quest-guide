$facts['docker_hosts'].each |$name, $ip| {
  dockeragent::node { $name:
    ensure              => absent,
    require_dockeragent => false,
  }
  exec { "/opt/puppetlabs/bin/puppet cert clean ${name}": }
}
