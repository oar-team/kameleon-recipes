class env::min::generate_etc_motd {

  case "${::lsbdistcodename}" {
    'buster': {
      $userdistribname = "debian10"
    }
    'stretch': {
      $userdistribname = "debian9"
    }
    default: {
      $userdistribname = "${::lsbdistcodename}"
    }
  }

  file {
    '/etc/motd':
      ensure  => file,
      owner   => root,
      group   => root,
      content => template('env/min/motd.erb'),
      mode    => '0755';
  }
}
