class env::big::install_ceph (
  $version = 'hammer'
) {

  case $operatingsystem {
    'Debian': {

      case "${::lsbdistcodename}" {
        "jessie" : {

          $ceph_packages = [ 'ceph-common', 'ceph-fs-common', 'ceph-fuse' ]
          $ceph_packages_g5k_repository_dep = [ 'python-setuptools' ]

          # Add ceph repositories.
          class {
            'env::big::install_ceph::apt':
              version => $version;
          }

          # Install ceph and deps
          package {
            $ceph_packages :
              ensure   => installed,
              require  => [Class['env::big::install_ceph::apt'], Exec['/usr/bin/apt-get update']];
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

        "stretch", "buster" : {

          case "${::lsbdistcodename}" {
            "buster" : {
              $ceph_packages = [ 'ceph-common', 'ceph-fuse' ]
            }
            "stretch" : {
              $ceph_packages = [ 'ceph-common', 'ceph-fs-common', 'ceph-fuse' ]
            }
          }

          # Install ceph and deps
          package {
            $ceph_packages :
              ensure   => installed,
          }
        }
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
