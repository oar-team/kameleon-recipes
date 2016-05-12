class env::base::additional_packages () {

  # Removed : findutils, grep, gzip, man-db, sed, tar, wget, diffutils, multiarch-support
  $utils = [ 'dnsutils', 'dtach', 'host', 'ldap-utils', 'lshw', 'lsof', 'bsd-mailx', 'm4', 'netcat-openbsd', 'screen', 'strace', 'telnet', 'time', 'xstow', 'sudo', 'debian-archive-keyring' ]

  $installed = [ $utils ]

  package {
    $installed:
      ensure => installed;
  }
}
