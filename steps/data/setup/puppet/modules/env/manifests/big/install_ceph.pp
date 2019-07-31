class env::big::install_ceph (
  $version = 'hammer'
) {

  case $operatingsystem {
    'Debian': {

      # ceph is installed in stretch and buster via meta-packages
      case "${::lsbdistcodename}" {
        "jessie" : {

          $ceph_packages_g5k_repository_dep = [ 'python-setuptools' ]

          # Add ceph repositories.
          class {
            'env::big::install_ceph::apt':
              version => $version;
          }

          # Ceph-deploy is used by dfsg5k to setup easily a ceph fs on g5k nodes.
          env::common::g5kpackages {
            'ceph-deploy':
              ensure  => '1.5.28~bpo70+1',
              require  => Package[$ceph_packages_g5k_repository_dep]
          }

          package {
            $ceph_packages_g5k_repository_dep:
              ensure   => installed;
          }
        }
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
