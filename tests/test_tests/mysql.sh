#!/bin/bash
HIST=~/.bash_history
quest begin mysql
#Task 1
puppet module install puppetlabs-mysql
#Task 2
cat << EOL > /etc/puppetlabs/code/environments/production/manifests/site.pp
File { backup => false }
node 'learning.puppetlabs.vm' {
  class { '::mysql::server':
    root_password    => 'strongpassword',
    override_options => {
      'mysqld' => { 'max_connections' => '1024' }
    },
  }
}
EOL
#Task 3
puppet agent -t
#Task 4
cat << EOL > /etc/puppetlabs/code/environments/production/manifests/site.pp
File { backup => false }
node 'learning.puppetlabs.vm' {
  class { '::mysql::server':
    root_password    => 'strongpassword',
    override_options => {
      'mysqld' => { 'max_connections' => '1024' }
    },
  }
  include ::mysql::server::account_security
}
EOL
puppet agent -t
#Task 5
cat << EOL > /etc/puppetlabs/code/environments/production/manifests/site.pp
File { backup => false }
node 'learning.puppetlabs.vm' {
  class { '::mysql::server':
    root_password    => 'strongpassword',
    override_options => {
      'mysqld' => { 'max_connections' => '1024' }
    },
  }
  include ::mysql::server::account_security
  mysql_database { 'lvm':
      ensure  => present,
      charset => 'utf8',
  }
  mysql_user { 'lvm_user@localhost':
    ensure => present,
  }
  mysql_grant { 'lvm_user@localhost/lvm.*':
    ensure      => present,
    options     => ['GRANT'],
    privileges  => ['ALL'],
    table       => 'lvm.*',
    user        => 'lvm_user@localhost',
  }
}
EOL
puppet agent -t
