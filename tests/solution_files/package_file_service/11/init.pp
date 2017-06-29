class pasture {

  package {'pasture':
    ensure   => present,
    provider => 'gem',
  }

  file { '/etc/pasture_config.yaml':
    source => 'puppet:///modules/pasture/pasture_config.yaml',
  }

  file { '/etc/systemd/system/pasture.service':
    source => 'puppet:///modules/pasture/pasture.service',
  }

  service { 'pasture':
    ensure => running,
  }

}
