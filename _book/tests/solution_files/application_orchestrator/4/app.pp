define pasture_app::app (
  $db_user,
  $db_password,
  $db_host,
  $db_name,
) {

  class { 'pasture':
    sinatra_server  => 'thin',
    db              => "postgres://${db_user}:${db_password}@${db_host}/${db_name}",
    default_message => "Hi! I'm connected to ${db_host}!",
  }

}
Pasture_App::App consumes Sql {
  db_user     => $user,
  db_password => $password,
  db_host     => $host,
  db_name     => $database,
}
