#!/bin/bash
HIST=~/.bash_history
quest begin resource_ordering
#Task 1
cd /etc/puppetlabs/code/environments/production/modules
mkdir -p sshd/{examples,manifests,files}
#Task 2
cat << "EOL" > sshd/manifests/init.pp
class sshd {
  package { 'openssh-server':
    ensure => present,
    before => Service['sshd'],
  }

  service { 'sshd':
    ensure   => running,
    enable   => true,
  }
}
EOL
#Task 3
cat << "EOL" > sshd/examples/init.pp
include sshd
EOL
puppet apply sshd/examples/init.pp --noop --graph
#Task 4
dot -Tpng /opt/puppetlabs/puppet/cache/state/graphs/relationships.dot -o /var/www/quest/relationships.png
#Task 5
cp /etc/ssh/sshd_config sshd/files/sshd_config
chown pe-puppet:pe-puppet sshd/files/sshd_config
#Task 6
cat << "EOL" > sshd/files/sshd_config
# File is managed by Puppet
AcceptEnv LANG LC_*
ChallengeResponseAuthentication no
GSSAPIAuthentication no
PermitRootLogin yes
PrintMotd no
Subsystem sftp /usr/libexec/openssh/sftp-server
UseDNS no
UsePAM yes
X11Forwarding yes
EOL
#Task 7
cat << "EOL" > sshd/manifests/init.pp
class sshd {
  package { 'openssh-server':
    ensure => present,
    before => Service['sshd'],
  }

  service { 'sshd':
    ensure   => running,
    enable   => true,
  }

  file { '/etc/ssh/sshd_config':
    ensure     => present,
    source     => 'puppet:///modules/sshd/sshd_config',
    require    => Package['openssh-server'],
  }
}
EOL
#Task 8
puppet apply sshd/examples/init.pp --noop --graph
dot -Tpng /opt/puppetlabs/puppet/cache/state/graphs/relationships.dot -o /var/www/quest/relationships.png
#Task 9
cat << "EOL" > sshd/manifests/init.pp
class sshd {
  package { 'openssh-server':
    ensure => present,
    before => Service['sshd'],
  }

  service { 'sshd':
    ensure   => running,
    enable   => true,
    subscribe => File['/etc/ssh/sshd_config'],
  }

  file { '/etc/ssh/sshd_config':
    ensure     => present,
    source     => 'puppet:///modules/sshd/sshd_config',
    require    => Package['openssh-server'],
  }
}
EOL
puppet apply sshd/examples/init.pp --noop --graph
dot -Tpng /opt/puppetlabs/puppet/cache/state/graphs/relationships.dot -o /var/www/quest/relationships.png
puppet apply sshd/examples/init.pp
