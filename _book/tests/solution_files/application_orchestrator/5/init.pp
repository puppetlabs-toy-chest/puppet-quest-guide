application pasture_app (
  $db_user,
  $db_password,
) {

  pasture_app::db { $name:
    user     => $db_user,
    password => $db_password,
    export   => Sql[$name],
  }

  pasture_app::app { $name:
    consume => Sql[$name],
  }

}
