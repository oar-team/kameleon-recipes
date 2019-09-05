class env::base::configure_dhclient () {

  file_line { 'dhclient_interval':
    ensure => present,
    path   => '/etc/dhcp/dhclient.conf',
    line   => 'initial-interval 1;',
    match  => '.*initial-interval.*',
  }
}
