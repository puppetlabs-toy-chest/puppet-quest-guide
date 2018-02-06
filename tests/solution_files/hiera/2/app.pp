class profile::pasture::app {
  class { 'pasture':
    default_message   => lookup('profile::pasture::app::default_message'),
    sinatra_server    => lookup('profile::pasture::app::sinatra_server'),
    default_character => lookup('profile::pasture::app::default_character'),
    db                => lookup('profile::pasture::app::db'),
  }
}
