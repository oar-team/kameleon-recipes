class env::big::install_ceph (
  $version = 'hammer'
) {

  $ceph_packages = [ 'ceph-common', 'ceph-fs-common', 'ceph-fuse' ]
  $ceph_packages_g5k_repository = [ 'ceph-deploy' ] # Ceph deploy is not distributed on ceph repo for jessie. So we picked wheezy package that works on jessie and distribute it.
  $ceph_packages_g5k_repository_dep = [ 'python-setuptools' ]
  case $operatingsystem {
    'Debian': {
      if "${::lsbdistcodename}" == "jessie" {
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

      } else {
        # Stretch use distribution binaries

        # Install ceph and deps
        package {
          $ceph_packages :
            ensure   => installed,
        }
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
