$container_name = 'hello.learning.puppetlabs.vm'
$container_alias = 'hello'

class { "dockeragent":
  create_no_agent_image => true,
}

dockeragent::node { $container_name:
  image => 'no_agent',
}

host { $container_name:
  ip           => generate("/bin/docker", "inspect", "-f", "'{{ .NetworkSettings.IPAddress }}'", $container_name).match(/[\d\.]+/),
  host_aliases => $container_alias,
}
