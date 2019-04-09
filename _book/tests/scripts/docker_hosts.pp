$hosts_template = @(END)
127.0.0.1 <%= $fqdn %>  learning localhost localhost.localdomain localhost4
::1 localhost localhost.localdomain localhost6 localhost6.localdomain6
<% $docker_hosts.each |$hostname, $ip| {  -%>
<%= $ip %> <%= $hostname %>
<% } -%>
END
$hosts_hash = {
  'docker_hosts' => $facts['docker_hosts'],
  'fqdn'         => $facts['fqdn']
}
file { '/etc/hosts':
  content => inline_epp($hosts_template, $hosts_hash),
}
