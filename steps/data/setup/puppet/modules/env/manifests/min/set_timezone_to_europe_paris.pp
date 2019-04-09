class env::min::set_timezone_to_europe_paris {

  # Set timezone
  file {
    '/etc/localtime':
      ensure   => present,
      source   => '/usr/share/zoneinfo/Europe/Paris';
  }

}
