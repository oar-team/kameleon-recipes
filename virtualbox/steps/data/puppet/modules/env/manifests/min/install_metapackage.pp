class env::min::install_metapackage ( $variant ) {

  include env::common::software_versions

  case $operatingsystem {
    'Debian','Ubuntu': {
      if "${::lsbdistcodename}" == "stretch" {
        $g5kmetapackages = "g5k-meta-packages-debian9-$variant"
        } else {
          $g5kmetapackages = "g5k-meta-packages-${::lsbdistcodename}-$variant"
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
