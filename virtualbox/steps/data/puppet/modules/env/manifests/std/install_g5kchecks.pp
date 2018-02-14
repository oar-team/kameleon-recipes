class env::std::install_g5kchecks {

  include 'env::std::ipmitool' # ipmitool is required by g5k-checks
  include 'env::std::dell'     # dell tools are required by g5k-checks

  if "${::lsbdistcodename}" == "jessie" {
    $g5kchecks_deps = [ 'ruby-rest-client', 'ohai', 'ruby-popen4', 'fio', 'ruby-json', 'x86info' ]
    $g5kchecks_dist = ""
    $g5kchecks_version = "0.7.16"
  }
  if "${::lsbdistcodename}" == "stretch" {
    $g5kchecks_deps = [ 'ruby-rest-client', 'ohai', 'fio', 'ruby-json', 'x86info', 'ethtool' ]
    $g5kchecks_dist = "_stretch"
    $g5kchecks_version = "0.7.18"
  }
  case $operatingsystem {
    'Debian','Ubuntu': {
      require env::commonpackages::rake
      require env::commonpackages::rubyrspec
      exec {
        "retrieve_g5kchecks":
          command  => "/usr/bin/wget --no-check-certificate -q https://www.grid5000.fr/packages/debian/g5kchecks_${g5kchecks_version}_amd64${g5kchecks_dist}.deb -O /tmp/g5kchecks_amd64.deb",
          creates  => "/tmp/g5kchecks_amd64.deb";
      }
      package {
        "g5kchecks":
          ensure   => installed,
          provider => dpkg,
          source   => "/tmp/g5kchecks_amd64.deb",
#          require  => [ Exec["retrieve_g5kchecks"], Package[$g5kchecks_deps], Package['rake'], Package['ntp'] ];
          require  => [ Exec["retrieve_g5kchecks"], Package[$g5kchecks_deps] ];
        $g5kchecks_deps:
          ensure   => installed;
      }
      file {
        '/etc/g5k-checks.conf':
          ensure   => present,
          owner    => root,
          group    => root,
          mode     => '0644',
          source   => "puppet:///modules/env/std/g5kchecks/g5k-checks${g5kchecks_dist}.conf",
          require  => Package["g5kchecks"];
      }
    }
    default: {
      err "${operatingsystem} not supported."
    }
  }
}
