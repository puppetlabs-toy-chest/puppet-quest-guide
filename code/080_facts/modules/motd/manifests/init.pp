#!/opt/puppetlabs/puppet/bin/puppet apply
class motd {

  $motd_hash = {
    'fqdn'       => $facts['networking']['fqdn'],
    'os_family'  => $facts['os']['family'],
    'os_name'    => $facts['os']['name'],
    'os_release' => $facts['os']['release']['full'],
  }

  file { '/etc/motd':
    content => epp('motd/motd.epp', $motd_hash),
  }

}
