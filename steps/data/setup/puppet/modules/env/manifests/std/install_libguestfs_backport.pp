class env::std::install_libguestfs_backport {

  if $env::deb_arch == 'arm64' {
    case $lsbdistcodename {
      'buster': {
        env::common::g5kpackages {
         'libguestfs-backport-arm64':
           packages => 'libguestfs-tools',
           ensure  => $::env::common::software_versions::libguestfs_backport_arm64;
        }
      }
      default: {
        err "${lsbdistcodename} not supported."
      }
    }
  }
  else {
    err "${env::deb_arch} not supported"
  }
}
