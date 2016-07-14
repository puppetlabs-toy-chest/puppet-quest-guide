class { "dockeragent":
  create_no_agent_image => true,
}

dockeragent::node { 'hello.puppetlabs.vm':
  image => 'no_agent',
}
