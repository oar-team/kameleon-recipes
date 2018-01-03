class env::min::install_metapackage ( $variant ) {

    require env::min::add_grid5000_apt_repo

    case $operatingsystem {
    'Debian','Ubuntu': {

      if "${::lsbdistcodename}" == "stretch" {
        $g5kmetapackages = "g5k-meta-packages-debian9-$variant" 
      } else {
        $g5kmetapackages = "g5k-meta-packages-${::lsbdistcodename}-$variant"
      }

      package {
        $g5kmetapackages:
          ensure => installed,
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
