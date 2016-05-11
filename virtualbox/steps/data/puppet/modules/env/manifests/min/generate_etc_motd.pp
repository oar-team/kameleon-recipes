class env::min::generate_etc_motd {
  file {
    '/etc/motd':
      ensure  => file,
      owner   => root,
      group   => root,
      content => template('env/min/motd.erb'),
      mode    => '0755';
  }
}
