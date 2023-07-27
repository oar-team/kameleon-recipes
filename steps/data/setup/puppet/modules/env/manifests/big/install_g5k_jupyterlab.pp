class env::big::install_g5k_jupyterlab {
  case $operatingsystem {
    'Debian': {
      include env::common::software_versions

      env::common::g5kpackages {
        'g5k-jupyterlab':
          ensure  => "${::env::common::software_versions::g5k_jupyterlab}",
          release => "${::lsbdistcodename}";
      }
    }
    default: {
      fail "${operatingsystem} not supported."
    }
  }
}

