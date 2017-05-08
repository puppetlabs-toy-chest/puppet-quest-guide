$facts['docker_hosts'].each |$name, $ip| {
  service { "docker-${name}.service":
    ensure => stopped,
  }
  exec { "/opt/puppetlabs/bin/puppet cert clean ${name}": }
}
