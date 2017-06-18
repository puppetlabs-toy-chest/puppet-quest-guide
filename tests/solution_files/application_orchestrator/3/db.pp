define pasture_app::db (
  $user,
  $password,
  $host     = $::fqdn,
  $database = $name,
){
  class { 'postgresql::server':
    listen_addresses => '*',
  }
  postgresql::server::db { $name:
    user     => $user,
    password => postgresql_password($user, $password),
  }
  postgresql::server::pg_hba_rule { 'allow pasture app access':
    type        => 'host',
    database    => $database,
    user        => $user,
    address     => '172.18.0.2/24',
    auth_method => 'password',
  }
}
Pasture_App::Db produces Sql {
  user     => $user,
  password => $password,
  host     => $fqdn,
  database => $database,
}
