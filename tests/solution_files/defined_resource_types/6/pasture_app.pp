class role::pasture_app {
  include profile::pasture::app
  include profile::base::dev_users
  include profile::base::motd
}
