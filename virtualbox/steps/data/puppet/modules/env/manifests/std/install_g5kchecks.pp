class env::std::install_g5kchecks {

  include 'env::std::ipmitool' # ipmitool is required by g5k-checks
  include 'env::std::dell'     # dell tools are required by g5k-checks

  $g5kchecks_version = "0.7.12"

  $g5kchecks_deps = [ 'ruby-rest-client', 'ohai', 'ruby-popen4', 'fio', 'ruby-json', 'x86info' ]
  case $operatingsystem {
    'Debian','Ubuntu': {
      require env::commonpackages::rake
      require env::commonpackages::rubyrspec
      exec {
        "retrieve_g5kchecks":
          command  => "/usr/bin/wget --no-check-certificate -q https://www.grid5000.fr/packages/debian/g5kchecks_${g5kchecks_version}_all.deb -O /tmp/g5kchecks_${g5kchecks_version}_all.deb",
          creates  => "/tmp/g5kchecks_${g5kchecks_version}_all.deb";
      }
      package {
        "g5kchecks":
          ensure   => installed,
          provider => dpkg,
          source   => "/tmp/g5kchecks_${g5kchecks_version}_all.deb",
          require  => [ Exec["retrieve_g5kchecks"], Package[$g5kchecks_deps], Package['rake'], Package['ntp'] ];
        $g5kchecks_deps:
          ensure   => installed;
      }
      file {
        '/etc/g5k-checks.conf':
          ensure   => present,
          owner    => root,
          group    => root,
          mode     => '0644',
          source   => 'puppet:///modules/env/std/g5kchecks/g5k-checks.conf',
          require  => Package["g5kchecks"];
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}


