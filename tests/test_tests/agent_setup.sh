#!/bin/bash
HIST=~/.bash_history
quest begin agent_setup
#Task 1
cat << "EOL" > /etc/puppetlabs/code/environments/production/manifests/site.pp
File { backup => false }
node 'learning.puppetlabs.vm' {
  include multi_node
}
EOL
#Task 2
puppet agent -t
#Task 3
docker exec -it webserver sh -c "curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash"
docker exec -it database sh -c "curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash"
#Task 4
docker exec -it database sh -c "puppet resource file /tmp/test ensure=file"
docker exec -it database sh -c "puppet apply /tmp/test.pp"
#Task 5
puppet cert sign webserver.learning.puppetlabs.vm
puppet cert sign database.learning.puppetlabs.vm
#Task 6
cat << "EOL" > /etc/puppetlabs/code/environments/production/manifests/site.pp
File { backup => false }
node 'learning.puppetlabs.vm' {
  include multi_node
}
node default {
  notify { "This is ${::fqdn}, running the ${::operatingsystem} operating system": }
}
EOL
docker exec -it database sh -c "puppet agent -t"

