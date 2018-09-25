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
        apt::source { 'ceph-deploy':
          key      => {
            'id'      => '3C38BDEAA05D4A7BED7815E5B1F34F56797BF2D1',
            'content' => file('env/min/apt/grid5000-archive-key.asc')
          },
          comment  => 'Grid5000 repository for ceph-deploy',
          location => 'http://packages.grid5000.fr/deb/ceph-deploy/',
          release  => "/",
          repos    => '',
          include  => { 'deb' => true, 'src' => false }
        }
        package {
          'ceph-deploy':
            ensure  => '1.5.28~bpo70+1',
            require  => [Class['apt::update'], Package[$ceph_packages_g5k_repository_dep] ];
          $ceph_packages_g5k_repository_dep:
            ensure   => installed;
        }


        # Ensure service does not start at boot
        service {
          'ceph':
            enable  => false,
            require => Package['ceph'];
        }
      } else {
        # Stretch use distribution binaries

        # Install ceph and deps
        package {
          $ceph_packages :
            ensure   => installed,
        }
        # Ensure service does not start at boot
        service {
          'ceph':
            enable  => false,
            require => Package['ceph'];
        }
      }

    }
    default: {
      err "${operatingsystem} not suported."
    }
  }
}
