$::docker_hosts.each |String $container_name, String $ipaddress | {
  host { $container_name:
    ip           => $ipaddress,
    host_aliases => $container_name,
  }
}
