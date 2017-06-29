class role::pasture_app {
  include profile::pasture::app
  include profile::pasture::dev_users
  include profile::base::motd
}
