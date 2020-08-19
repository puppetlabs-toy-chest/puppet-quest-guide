define user_accounts::ssh_user (
  $pub_key,
  $group   = undef,
  $shell   = undef,
  $comment = undef,
){
  ssh_authorized_key { "${title}@puppet.vm":
    ensure => present,
    user   => $title,
    type   => 'ssh-rsa',
    key    => $pub_key,
  }
  file { "/home/${title}/.ssh":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0700',
    before => Ssh_authorized_key["${title}@puppet.vm"],
  }
  user { $title:
    ensure  => present,
    groups  => $group,
    shell   => $shell,
    home    => "/home/${title}",
    comment => $comment,
  }
  file { "/home/${title}":
    ensure => directory,
    owner  => $title,
    group  => $title,
    mode   => '0755',
  }
}
