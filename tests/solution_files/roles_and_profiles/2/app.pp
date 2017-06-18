class profile::pasture::app {
  if $facts['fqdn'] =~ 'large' {
    $default_character = 'elephant'
    $db                = 'postgres://pasture:m00m00@pasture-db.puppet.vm/pasture'
  } elsif $facts['fqdn'] =~ 'small' {
    $default_character = undef
    $db                = undef
  } else {
    fail("The ${facts['fqdn']} node name must match 'large' or 'small'.")
  }
  class { 'pasture':
    default_message   => 'Hello Puppet!',
    sinatra_server    => 'thin',
    default_character => $default_character,
    db                => $db,
  }
}
