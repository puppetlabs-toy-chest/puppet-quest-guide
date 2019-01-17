node 'pasture.puppet.vm' {
  class { 'pasture':
    default_character => 'cow',
  }
}
