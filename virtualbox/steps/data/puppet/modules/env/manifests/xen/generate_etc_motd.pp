class env::xen::generate_etc_motd {

  if "${::lsbdistcodename}" == "stretch" {
    $userdistribname = "debian9"
  } else {
    $userdistribname = "${::lsbdistcodename}"
  }

  file {
    '/etc/motd':
      ensure  => file,
      owner   => root,
      group   => root,
      content => template('env/xen/motd.erb'),
      mode    => '0755';
  }
}
