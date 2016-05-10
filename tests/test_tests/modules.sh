#!/bin/bash
HIST=~/.bash_history
quest begin modules
#Task 1
puppet master --configprint modulepath
echo "puppet master --configprint modulepath" >> $HIST
#Task 2
cd /etc/puppetlabs/code/environments/production/modules
mkdir vimrc
#Task 3
mkdir vimrc/{manifests,examples,files}
#Task 4
cp ~/.vimrc vimrc/files/vimrc
#Task 5
echo "set number" >> vimrc/files/vimrc
#Task 6
cat << EOL > vimrc/manifests/init.pp
class vimrc {
  file { '/root/.vimrc':
    ensure => present,
    source => 'puppet:///modules/vimrc/vimrc',
  }
}
EOL
puppet parser validate vimrc/manifests/init.pp
#Task 7
echo "include vimrc" > vimrc/examples/init.pp
#Task 8
puppet apply vimrc/examples/init.pp
