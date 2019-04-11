class pasture {
  package { 'pasture':
    ensure   => present,
    provider => gem,
  }
}
