class env::install_metapackage ( $variant ) {
    case $operatingsystem {
    'Debian','Ubuntu': {

      $g5kmetapackages = "g5k-meta-packages-${::lsbdistcodename}-$variant"

      package {
        $g5kmetapackages:
          ensure => installed;
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
