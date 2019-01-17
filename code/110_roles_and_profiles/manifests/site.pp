node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
}

node /^pasture-app/ {
  include role::pasture_app
}

node /^pasture-db/ {
  include role::pasture_db
}
