class env::big::install_g5k_jupyterlab {
  case $operatingsystem {
    'Debian': {
      if "${::lsbdistcodename}" != 'stretch' {

        include env::common::software_versions

        env::common::g5kpackages {
          'g5k-jupyterlab':
            ensure  => "${::env::common::software_versions::g5k_jupyterlab}",
            release => "${::lsbdistcodename}";
        }
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}

