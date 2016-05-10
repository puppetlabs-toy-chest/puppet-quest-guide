#!/bin/bash
HIST=~/.bash_history
quest begin power_of_puppet
#Task 1
puppet module search graphite
echo "puppet module search graphite" >> $HIST
#Task 2
puppet module install dwerder-graphite -v 5.16.1
#Task 3
facter ipaddress
echo "facter ipaddress" >> $HIST
#Task 4
curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -X POST https://localhost:4433/classifier-api/v1/update-classes?environment=production
curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H "Content-Type: application/json" -X POST -d '{"name":"Learning VM", "environment":"production", "parent":"00000000-0000-4000-8000-000000000000", "classes":{"graphite" : {"gr_web_server" : "none", "gr_django_pkg" : "django", "gr_django_provider" : "pip", "gr_django_ver" : "1.5"} },  "rule":["or", ["=", "name", "learning.puppetlabs.vm"]]}' https://localhost:4433/classifier-api/v1/groups
puppet agent -t
