class env::std::install_g5kchecks {

  include 'env::std::ipmitool' # ipmitool is required by g5k-checks
  if $env::deb_arch == 'amd64' {
    include 'env::std::dell'     # dell tools are required by g5k-checks
  }

  case $operatingsystem {

    'Debian','Ubuntu': {

      require env::commonpackages::rake
      require env::commonpackages::rubyrspec

      if "${::lsbdistcodename}" != "jessie" {

        env::common::g5kpackages {
          'g5k-checks':
            ensure  => $::env::common::software_versions::g5k_checks,
            release => "${::lsbdistcodename}";
        }

        file {
          '/etc/g5k-checks.conf':
            ensure   => present,
            owner    => root,
            group    => root,
            mode     => '0644',
            source   => "puppet:///modules/env/std/g5kchecks/g5k-checks.conf",
            require  => Package["g5k-checks"];
        }
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}
