node 'pasture-dev.puppet.vm' {
  include pasture
}
node 'pasture-prod.puppet.vm' {
  class { 'pasture':
    sinatra_server => 'thin',
  }
}
