class env::min::install_metapackage ( $variant ) {

    require env::min::add_grid5000_apt_repo

    case $operatingsystem {
    'Debian','Ubuntu': {

      $g5kmetapackages = "g5k-meta-packages-${::lsbdistcodename}-$variant"

      package {
        $g5kmetapackages:
          ensure => installed,
      }->
      exec { 'run apt-mark hold for g5k metapackage':
        command => "/usr/bin/apt-mark hold $g5kmetapackages",
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
