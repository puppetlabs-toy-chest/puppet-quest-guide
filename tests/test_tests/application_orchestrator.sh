#!/bin/bash
HIST=~/.bash_history
quest begin application_orchestrator
#Task 1
cat << "EOL" > /etc/puppetlabs/code/environments/production/manifests/site.pp
File { backup => false
node /^(webserver|database).*$/ {
  pe_ini_setting { 'use_cached_catalog':
    ensure  => present,
    path    => $settings::config,
    section => 'agent',
    setting => 'use_cached_catalog',
    value   => 'true',
  }
  pe_ini_setting { 'pluginsync':
    ensure  => present,
    path    => $settings::config,
    section => 'agent',
    setting => 'pluginsync',
    value   => 'false',
  }
}
EOL
#Task 2
docker exec -it database sh -c "puppet agent -t"
docker exec -it webserver sh -c "puppet agent -t"
#Task 3
mkdir -p ~/.puppetlabs/client-tools
cat << "EOL" > /root/.puppetlabs/client-tools/orchestrator.conf
{
  "options": {
    "url": "https://learning.puppetlabs.vm:8143",
    "environment": "production"
  }
}
EOL
#Task 3
curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H "Content-Type: application/json" -X POST -d '{"permissions": [{"instance":"*","object_type":"orchestration","action":"run_puppet_from_orchestrator"},{"instance":"*","object_type":"tokens", "action":"override_default_expiry"}],"display_name":"Orchestrators","description":"orchestrators", "user_ids":[], "group_ids":[]}' https://localhost:4433/rbac-api/v1/roles
curl -i -k --cacert /etc/puppetlabs/puppet/ssl/ca/ca_crt.pem --key /etc/puppetlabs/puppet/ssl/private_keys/learning.puppetlabs.vm.pem --cert /etc/puppetlabs/puppet/ssl/certs/learning.puppetlabs.vm.pem -H "Content-Type: application/json" -X POST -d '{"login":"orchestrator","display_name":"Orchestrator","password":"puppet"}' https://localhost:4433/rbac-api/v1/users
puppet agent -t
#Task 4
docker exec -it webserver sh -c "curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash"
docker exec -it database sh -c "curl -k https://learning.puppetlabs.vm:8140/packages/current/install.bash | sudo bash"
#Task 5
docker exec -it database sh -c "puppet resource file /tmp/test ensure=file"
docker exec -it database sh -c "puppet apply /tmp/test.pp"
#Task 6
puppet cert sign webserver.learning.puppetlabs.vm
puppet cert sign database.learning.puppetlabs.vm
#Task 1
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

