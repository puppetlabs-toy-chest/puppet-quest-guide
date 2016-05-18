#!/bin/bash
HIST=~/.bash_history
quest begin conditional_statements
#Task 1
cd /etc/puppetlabs/code/environments/production/modules/
mkdir -p accounts/{manifests,examples}
#Task 2
cat << "EOL" > accounts/manifests/init.pp
class accounts ($user_name) {

  if $::operatingsystem == 'centos' {
    $groups = 'wheel'
  }
  elsif $::operatingsystem == 'debian' {
    $groups = 'admin'
  }
  else {
    fail( "This module doesn't support ${::operatingsystem}." )
  }

  notice ( "Groups for user ${user_name} set to ${groups}" )

  user { $user_name:
    ensure => present,
    home   => "/home/${user_name}",
    groups => $groups,
  }

}
EOL
#Task 3
cat << "EOL" > accounts/examples/init.pp
class {'accounts':
  user_name => 'dana',
}
EOL
#Task 4
FACTER_operatingsystem=Debian puppet apply --noop accounts/examples/init.pp
echo "FACTER_operatingsystem=Debian puppet apply --noop accounts/examples/init.pp" >> $HIST
#Task 5
FACTER_operatingsystem=Darwin puppet apply --noop accounts/examples/init.pp
echo "FACTER_operatingsystem=Darwin puppet apply --noop accounts/examples/init.pp" >> $HIST
#Task 6
puppet apply accounts/examples/init.pp
