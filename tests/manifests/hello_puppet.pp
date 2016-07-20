class { "dockeragent":
  create_no_agent_image => true,
}

dockeragent::node { 'hello.learning.puppetlabs.vm':
  image => 'no_agent',
}
