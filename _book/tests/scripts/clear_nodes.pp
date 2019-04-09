$facts['docker_hosts'].each |$name, $ip| {
  service { "docker-${name}.service":
    ensure => stopped,
  }
  exec { "/bin/find /etc/docker/ssl_dir -name ${name}.pem -delete": }
  exec { "/opt/puppetlabs/bin/puppet cert clean ${name}": }
}
