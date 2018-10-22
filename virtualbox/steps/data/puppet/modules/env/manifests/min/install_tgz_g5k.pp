class env::min::install_tgz_g5k {
  case $operatingsystem {
    'Debian','Ubuntu': {

      include env::common::software_versions

      env::common::g5kpackages {
        'tgz-g5k':
          ensure => $::env::common::software_versions::tgz_g5k;
      }
    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}

