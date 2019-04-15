class pasture::db {

  class { 'postgresql::server':
    listen_addresses => '*',
  }

  postgresql::server::db { 'pasture':
    user     => 'pasture',
    password => postgresql_password('pasture', 'm00m00'),
  }

  postgresql::server::pg_hba_rule { 'allow pasture app access':
    type        => 'host',
    database    => 'pasture',
    user        => 'pasture',
    address     => '172.18.0.2/24',
    auth_method => 'password',
  }

}
