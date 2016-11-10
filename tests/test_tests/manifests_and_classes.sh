#!/bin/bash
HIST=~/.bash_history
quest begin manifests_and_classes
#Task 1
cd /etc/puppetlabs/code/environments/production/modules/
mkdir -p cowsayings/{manifests,tests}
cat << EOF > cowsayings/manifests/cowsay.pp
class cowsayings::cowsay {
  package { 'cowsay':
    ensure   => present,
    provider => 'gem',
  }
}
EOF
puppet parser validate cowsayings/manifests/cowsay.pp
#Task 2
echo "include cowsayings::cowsay" > cowsayings/examples/cowsay.pp
#Task 3
puppet apply cowsayings/examples/cowsay.pp
cowsay Puppet is awesome!
#Task 4
cat << EOF > cowsayings/manifests/fortune.pp
class cowsayings::fortune {
  package { 'fortune-mod':
    ensure => present,
  }
}
EOF
#Task 5
echo "include cowsayings::fortune" > cowsayings/examples/fortune.pp
#Task 6
puppet apply cowsayings/examples/fortune.pp
fortune | cowsay
#Task 7
cat << EOF > cowsayings/manifests/init.pp
class cowsayings {
  include cowsayings::cowsay
  include cowsayings::fortune
}
EOF
puppet parser validate cowsayings/manifests/init.pp
#Task 8
echo "include cowsayings" > cowsayings/examples/init.pp
#Task 9
puppet apply cowsayings/examples/init.pp
