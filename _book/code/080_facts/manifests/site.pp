node 'pasture.puppet.vm' {
  include motd
  class { 'pasture':
    default_character => 'cow',
  }
}
