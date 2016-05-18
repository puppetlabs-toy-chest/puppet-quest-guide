#!/bin/bash
HIST=~/.bash_history
quest begin ntp
#Task 1
puppet module install puppetlabs-ntp
#Task 2
cat << EOL >> /etc/puppetlabs/code/environments/production/manifests/site.pp
node 'learning.puppetlabs.vm' {
  include ntp
}
EOL
#Task 3
puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp
puppet agent -t
#Task 4
ntp=$(cat <<EOL
class { 'ntp':
  servers => [
    'nist-time-server.eoni.com',
    'nist1-lv.ustiming.org',
    'ntp-nist.ldsbc.edu'
  ]
}
EOL
)
escaped_ntp=$(printf '%s\n' "$ntp" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/include ntp/$escaped_ntp/g" /etc/puppetlabs/code/environments/production/manifests/site.pp
#Task 5
puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp
puppet agent -t
