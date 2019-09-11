class env::base::configure_dhclient () {

  file_line { 'dhclient_interval':
    ensure => present,
    path   => '/etc/dhcp/dhclient.conf',
    line   => 'initial-interval 1; # retry more frequently in case packets get lost',
    match  => '.*initial-interval.*',
  }

  file_line { 'dhclient_timeout':
    ensure => present,
    path   => '/etc/dhcp/dhclient.conf',
    line   => 'timeout 90; # slow clusters can take more than 60s (bug #10716, grisou)',
    match  => '.*timeout .*',
  }
}
