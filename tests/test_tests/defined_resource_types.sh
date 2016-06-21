#!/bin/bash
HIST=~/.bash_history
quest begin defined_resource_types
#Task 1
cd /etc/puppetlabs/code/environments/production/modules
mkdir -p web_user/{manifests,examples}
#Task 2
cat << "EOL" > web_user/manifests/user.pp
define web_user::user {
  $home_dir = "/home/${title}"
  user { $title:
    ensure => present,
  }
  file { $home_dir:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
}
EOL
#Task 3
cat << "EOL" > web_user/examples/user.pp
web_user::user { 'shelob': }
EOL
#Task 4
puppet apply web_user/examples/user.pp
#Task 5
cat << "EOL" > web_user/manifests/user.pp
define web_user::user {
  $home_dir    = "/home/${title}"
  $public_html = "${home_dir}/public_html"
  user { $title:
    ensure     => present,
  }
  file { [$home_dir, $public_html]:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
  file { "${public_html}/index.html":
    ensure  => file,
    owner   => $title,
    group   => $title,
    replace => false,
    content => "<h1>Welcome to ${title}'s home page!</h1>",
    mode    => '0664',
  }
}
EOL
#Task 6
puppet apply web_user/examples/user.pp
#Task 7
cat << "EOL" > web_user/manifests/user.pp
 define web_user::user (
    $content  = "<h1>Welcome to ${title}'s home page!</h1>",
    $password = undef,
  ) {
  $home_dir    = "/home/${title}"
  $public_html = "${home_dir}/public_html"
  user { $title:
    ensure     => present,
  }
  file { [$home_dir, $public_html]:
    ensure  => directory,
    owner   => $title,
    group   => $title,
    mode    => '0775',
  }
  file { "${public_html}/index.html":
    ensure  => file,
    owner   => $title,
    group   => $title,
    replace => false,
    content => "<h1>Welcome to ${title}'s home page!</h1>",
    mode    => '0664',
  }
}
EOL
#Task 8
cat << "EOL" > web_user/examples/user.pp
web_user::user { 'shelob': }
web_user::user { 'frodo':
  content  => 'Custom Content!',
  password => pw_hash('sting', 'SHA-512', 'mysalt'),
}
EOL
#Task 9
puppet apply web_user/examples/user.pp
