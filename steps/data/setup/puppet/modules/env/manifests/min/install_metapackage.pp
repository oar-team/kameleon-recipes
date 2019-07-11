class env::min::install_metapackage ( $variant ) {

  include env::common::software_versions

  case $operatingsystem {
    'Debian','Ubuntu': {
      case "${::lsbdistcodename}" {
        'buster': {
          $g5kmetapackages = "g5k-meta-packages-debian10-${variant}"
        }
        'stretch': {
          $g5kmetapackages = "g5k-meta-packages-debian9-${variant}"
        }
        default: {
          $g5kmetapackages = "g5k-meta-packages-${::lsbdistcodename}-${variant}"
        }
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }

  env::common::g5kpackages {
    'g5k-meta-packages':
       packages => $g5kmetapackages,
       ensure => $::env::common::software_versions::g5k_meta_packages;
  }
}
