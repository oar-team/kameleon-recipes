class env::big::install_g5k_jupyterlab {
  case $operatingsystem {
    'Debian': {
      include env::common::software_versions

      if $::env::deb_arch != 'ppc64el' {
        # We are stuck on building wheel for bcrypt on ppc64
        # See https://intranet.grid5000.fr/bugzilla/show_bug.cgi?id=14311
        env::common::g5kpackages {
          'g5k-jupyterlab':
            ensure  => "${::env::common::software_versions::g5k_jupyterlab}",
            release => "${::lsbdistcodename}";
        }
      }
    }
    default: {
      fail "${operatingsystem} not supported."
    }
  }
}

